import 'dart:collection';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mcuassitant/network.dart';

// import 'dart:math' as math;
//?-------------------------
//?                 示波器类
//?=========================
class ScopeBox {
  // 构造函数
  ScopeBox();

  double xValue = 0; // x坐标值
  var extremum = SplayTreeMap<int, int>((a, b) => a.compareTo(b));
  List<Line> lines = []; // 显示的数据 | 线的形式
  List<Map<String, bool>> options = [HashMap()];

//? 添加line | ✔打勾时调用
  void addLine(int deviceIndex, String dataName) {
    lines.add(Line(
      deviceIndex: deviceIndex,
      dataName: dataName,
    ));
  }

//? 删除line | 取消打勾时调用
  void deleteLine(int deviceIndex, String dataName) {
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].dataName == dataName) {
        if (lines[i].deviceIndex == deviceIndex) {
          lines.removeAt(i);
          if (lines.isEmpty) {
            // 线全删完后把xValue置零
            xValue = 0;
          }
          return;
        }
      }
    }
  }

//? 更新options
  void updateOptions() {
    for (int i = 0; i < dataNameList.length; i++) {
      //! 这边可能会有BUG，options[i]不存在的情况会出现访问null
      if (options.length < i + 1) {
        options.add(HashMap());
      }
      for (var dataName in dataNameList[i]) {
        if (options[i][dataName] == null) {
          options[i].addAll({dataName: false});
        }
      }
    }
    // for (var devs in dataNameList) {
    //   for (var dataName in devs) {
    //     if (options[dataName] == null) {
    //       options.addAll({dataName: false});
    //     }
    //   }
    // }
  }

  static List<List<String>> dataNameList = [];

//? 构造选项列表函数
  static buildDataNameList() {
    dataNameList.clear();
    for (var device in devices) {
      dataNameList.add([]);
      dataNameList.last = device!.scopeData.keys.toList();
    }
  }
}

//?-------------------------
//?                     线类
//?=========================
class Line {
  Line({
    required this.deviceIndex,
    required this.dataName,
  });
  var points = <FlSpot>[const FlSpot(0, 0)];

  final int deviceIndex;
  final String dataName;
  LineStyle style = LineStyle(
    colors: [
      Colors.lightBlueAccent[700]!.withOpacity(0),
      Colors.lightBlueAccent[700]!,
    ],
    stops: [0.05, 1.0],
    width: 4,
  );

  double? addPoint(double xValue) {
    // 要保证键值对存在才调用此函数
    if (devices[deviceIndex] != null &&
        devices[deviceIndex]!.scopeData[dataName] != null) {
      // devices[deviceIndex]!.scopeData[dataName] = 2 * math.sin(xValue);
      points.add(FlSpot(xValue, devices[deviceIndex]!.scopeData[dataName]!));
      return devices[deviceIndex]!.scopeData[dataName]!;
    }
    return null;
  }
}

class LineStyle {
  LineStyle({
    this.colors,
    this.stops,
    this.width,
  });

  List<Color>? colors;
  List<double>? stops;
  double? width;
}

//! 示波器列表
List<ScopeBox> scopes = [];

//?-------------------------
//?               示波器页面
//?=========================
class ScopePage extends StatefulWidget {
  const ScopePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ScopePage> createState() => _ScopePageState();
}

class _ScopePageState extends State<ScopePage> {
  //? 浮空按键处理函数
  void _handleButton() {
    setState(() {
      scopes.add(ScopeBox());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _handleButton,
      ),
      //? ListView生成示波器列表
      body: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return Scope(index: index);
        },
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(indent: 20, endIndent: 20),
        itemCount: scopes.length,
      ),
    );
  }
}

//?-------------------------
//?               示波器模块
//?=========================
class Scope extends StatefulWidget {
  const Scope({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  State<Scope> createState() => _ScopeState();
}

class _ScopeState extends State<Scope> {
  final limitCount = 100; // 最多显示的点数
  double step = 0.1; // 步长
  double lineWidth = 4; // 线宽

  Timer? timer;

  List<LineChartBarData> data = [];

  void generateLines() {
    //? 生成显示的线
    data.clear();
    for (var line in scopes[widget.index].lines) {
      data.add(LineChartBarData(
        spots: line.points,
        dotData: FlDotData(show: false),
        colors: line.style.colors,
        colorStops: line.style.stops,
        barWidth: line.style.width,
        isCurved: false,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    if (scopes[widget.index].lines.isEmpty) {
      return;
    }
    generateLines();
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      for (var line in scopes[widget.index].lines) {
        while (line.points.length > limitCount) {
          // 获取要删除的点在Map中的Key
          String popPoint = line.points.last.toString();
          popPoint = popPoint.substring(2, popPoint.length - 1); // 去掉括号
          List popPair = popPoint.split(',');
          int deleteValue =
              double.parse(popPair[1]).toInt(); // 因为源数据是浮点型，所以先转浮点型
          // 利用有序哈希处理上下界
          if (scopes[widget.index].extremum[deleteValue]! > 1) {
            // 数量大于1，count--
            scopes[widget.index].extremum[deleteValue] =
                scopes[widget.index].extremum[deleteValue]! - 1;
          } else {
            // 数量小于等于1，从Map中删除键值对
            scopes[widget.index].extremum.remove(deleteValue);
          }
          line.points.removeAt(0);
        }
      }
      // 添加点、处理上下限、绘制点
      setState(() {
        for (var line in scopes[widget.index].lines) {
          double? pushValue = line.addPoint(scopes[widget.index].xValue);
          int addValue = 0;
          // 利用有序哈希处理上下界
          if (pushValue != null) {
            addValue = pushValue.toInt();
            if (scopes[widget.index].extremum[addValue] != null) {
              //count++
              scopes[widget.index].extremum[addValue] =
                  scopes[widget.index].extremum[addValue]! + 1;
            } else {
              scopes[widget.index].extremum.addAll({addValue: 1});
            }
          }
        }
      });
      scopes[widget.index].xValue += step; // 换步
    });
  }

//? 按键处理函数
  void _handleManage() async {
    // 生成Dialog
    ScopeBox.buildDataNameList();
    scopes[widget.index].updateOptions();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return OptionSelect(
          index: widget.index,
          updateLines: generateLines,
        );
      },
    );
  }

//?-------------------------
//?                   示波器
//?=========================
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 400.0,
        padding: const EdgeInsets.all(4.0),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 550),
              child: PopupMenu(
                handleManage: _handleManage,
              ),
            ),
            SizedBox(
              width: 600,
              height: 300,
              child: scopes[widget.index].lines.isNotEmpty
                  ? _buildScope()
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScope() {
    return LineChart(
      LineChartData(
          minY: scopes[widget.index].extremum.firstKey() == null
              ? -1
              : scopes[widget.index].extremum.firstKey()! - 2,
          maxY: scopes[widget.index].extremum.lastKey() == null
              ? 1
              : scopes[widget.index].extremum.lastKey()!.toDouble() + 2,
          minX: scopes[widget.index].lines[0].points.first.x,
          maxX: scopes[widget.index].lines[0].points.last.x,
          lineTouchData: LineTouchData(enabled: false),
          clipData: FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
          ),
          lineBarsData: data,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(showTitles: false),
          )),
    );
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }
}

//?-------------------------
//?            示波器下拉菜单
//?=========================
enum Options { management }

class PopupMenu extends StatefulWidget {
  PopupMenu({Key? key, required this.handleManage}) : super(key: key);

  Function handleManage;

  @override
  State<PopupMenu> createState() => _PopupMenuState();
}

class _PopupMenuState extends State<PopupMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Options>(
      onSelected: (Options result) {
        switch (result) {
          case Options.management:
            widget.handleManage();
            break;
        }
      },
      icon: const Icon(Icons.arrow_drop_down),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Options>>[
        const PopupMenuItem<Options>(
          value: Options.management,
          child: ListTile(
            leading: Icon(Icons.rule),
            title: Text('Data Manage'),
          ),
        ),
      ],
    );
  }
}

//?-------------------------
//?          Dialog | 选项栏
//?=========================
class PanelItem {
  PanelItem({
    required this.headerValue,
    required this.deviceIndex,
    this.isExpanded = false,
  });

  // String expandedValue;
  String headerValue; // 标题
  int deviceIndex; // 当前面板对应设备序号
  bool isExpanded; // 是否展开
}

List<PanelItem> generatePanelItems(int numberOfItems) {
  return List<PanelItem>.generate(numberOfItems, (index) {
    return PanelItem(
      headerValue: devices[index]!.selectDeivce ?? "UNBOUND",
      deviceIndex: index,
      isExpanded: devices[index]!.selectDeivce == null ? false : true,
    );
  });
}

//? 面板Widget
class OptionSelect extends StatefulWidget {
  const OptionSelect({
    Key? key,
    required this.index,
    this.title,
    required this.updateLines,
  }) : super(key: key);

  final String? title;
  final int index;
  final Function updateLines;

  @override
  State<OptionSelect> createState() => _OptionSelectState();
}

class _OptionSelectState extends State<OptionSelect> {
  final List<PanelItem> _panelList = generatePanelItems(
      ScopeBox.dataNameList.length); // dataNameList是根据devices数量创建的

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(widget.title ?? 'Data Select'),
      children: <Widget>[_buildPanel()],
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.updateLines();
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        // 展开面板
        setState(() {
          _panelList[index].isExpanded = !isExpanded;
        });
      },
      children: _panelList.map<ExpansionPanel>((PanelItem item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.headerValue),
            );
          },
          body: Column(
            children: _generateOptions(item.deviceIndex),
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  List<Widget> _generateOptions(int deviceIndex) {
    return List<Widget>.generate(ScopeBox.dataNameList[deviceIndex].length,
        (int index) {
      return SelectedBox(
        dataName: ScopeBox.dataNameList[deviceIndex][index],
        scopeIndex: widget.index,
        deviceIndex: deviceIndex,
      );
    });
  }
}

class SelectedBox extends StatefulWidget {
  const SelectedBox({
    Key? key,
    required this.dataName,
    required this.scopeIndex,
    required this.deviceIndex,
  }) : super(key: key);

  final String dataName;
  final int scopeIndex;
  final int deviceIndex;

  @override
  State<SelectedBox> createState() => _SelectedBoxState();
}

class _SelectedBoxState extends State<SelectedBox> {
  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.focused,
        MaterialState.hovered,
        MaterialState.pressed,
        MaterialState.selected,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.grey;
    }

    return ListTile(
      title: Text(widget.dataName),
      trailing: Checkbox(
        checkColor: Colors.white,
        fillColor: MaterialStateProperty.resolveWith(getColor),
        value: scopes[widget.scopeIndex].options[widget.deviceIndex]
            [widget.dataName],
        onChanged: (bool? isSelect) {
          setState(() {
            if (scopes[widget.scopeIndex].options[widget.deviceIndex]
                    [widget.dataName] ==
                true) {
              // 取消打勾
              scopes[widget.scopeIndex]
                  .deleteLine(widget.deviceIndex, widget.dataName);
            } else {
              // 打勾
              scopes[widget.scopeIndex]
                  .addLine(widget.deviceIndex, widget.dataName);
            }
            scopes[widget.scopeIndex].options[widget.deviceIndex]
                    [widget.dataName] =
                !scopes[widget.scopeIndex].options[widget.deviceIndex]
                    [widget.dataName]!;
          });
        },
      ),
    );
  }
}
