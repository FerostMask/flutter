import 'dart:collection';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mcuassitant/network.dart';
import 'dart:math' as math;

List<List<String>> scopes = [];

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
  void _handleButton() {
    setState(() {
      scopes.add([]);
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
//?                     线类
//?=========================
class Line {
  Line({
    required this.sourceValue,
    this.colors,
    this.stops,
    this.width,
  }) {
    List<String> info = sourceValue.split(':');
    deviceIndex = int.parse(info[0]);
    name = info[1];
  }
  var points = <FlSpot>[const FlSpot(0, 0)];
  List<Color>? colors = [
    Colors.lightBlueAccent[700]!.withOpacity(0),
    Colors.lightBlueAccent[700]!,
  ];
  List<double>? stops = [0.1, 1.0];
  double? width = 4;

  late int deviceIndex;
  late String name;

  String sourceValue;

  double? addPoint(double xValue) {
    // 要保证键值对存在才调用此函数
    if (devices[deviceIndex] != null &&
        devices[deviceIndex]!.scopeData[name] != null) {
      devices[deviceIndex]!.scopeData[name] = 2 * math.sin(xValue);
      points.add(FlSpot(xValue, devices[deviceIndex]!.scopeData[name]!));
      return devices[deviceIndex]!.scopeData[name]!;
    }
    return null;
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
  double xValue = 0;
  double step = 0.1; // 步长
  double lineWidth = 4; // 线宽
  var extremum = SplayTreeMap<int, int>((a, b) => a.compareTo(b));

  Timer? timer;

  List<Line> lines = [];
  List<LineChartBarData> data = [];

//? 按键处理函数
  void _handleManage() async {
    // 生成Dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DataSelect();
      },
    );
  }

//? 初始化Widget
  @override
  void initState() {
    super.initState();
    if (scopes[widget.index].isEmpty) {
      return;
    }
    for (int i = 0; i < scopes[widget.index].length; i++) {
      // 添加线
      lines.add(Line(sourceValue: scopes[widget.index][i]));
      // 添加线Widget
      data.add(LineChartBarData(
        spots: lines[i].points,
        dotData: FlDotData(show: false),
        colors: lines[i].colors,
        colorStops: lines[i].stops,
        barWidth: lineWidth,
        isCurved: false,
      ));
    }
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      for (int i = 0; i < lines.length; i++) {
        // 出列超出范围的点
        while (lines[i].points.length > limitCount) {
          String lastPoint = lines[i].points.last.toString();
          lastPoint = lastPoint.substring(2, lastPoint.length - 1);
          List lastValue = lastPoint.split(',');
          int deleteValue = double.parse(lastValue[1]).toInt();
          // 利用有序哈希处理上下界
          if (extremum[deleteValue] != 1) {
            extremum[deleteValue.toInt()] = extremum[deleteValue]! - 1;
          } else {
            extremum.remove(deleteValue);
          }
          lines[i].points.removeAt(0);
        }
      }
      // 添加点、处理上下限、绘制点
      setState(() {
        for (int i = 0; i < lines.length; i++) {
          double? returnValue = lines[i].addPoint(xValue);
          int addValue = 0;
          // 利用有序哈希处理上下界
          if (returnValue != null) {
            addValue = returnValue.toInt();
            if (extremum[addValue] != null) {
              extremum[addValue] = extremum[addValue]! + 1;
            } else {
              extremum.addAll({addValue: 1});
            }
          }
        }
      });
      xValue += step; // 换步
    });
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
              child: lines.isNotEmpty ? _buildScope() : Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScope() {
    return LineChart(
      LineChartData(
          minY: extremum.firstKey() == null ? -1 : extremum.firstKey()! - 2,
          maxY: extremum.lastKey() == null
              ? 1
              : extremum.lastKey()!.toDouble() + 2,
          minX: lines[0].points.first.x,
          // maxX: lines[0].points.last.x,
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
enum Options { manage }

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
          case Options.manage:
            widget.handleManage();
            break;
        }
      },
      icon: const Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Options>>[
        const PopupMenuItem<Options>(
          value: Options.manage,
          child: ListTile(
            leading: Icon(Icons.rule),
            title: Text('Data Manage'),
          ),
        ),
      ],
    );
  }
}

class PanelItem {
  PanelItem({
    required this.headerValue,
    required this.deviceIndex,
    this.isExpanded = false,
  });

  // String expandedValue;
  String headerValue; // 标题
  int deviceIndex;
  bool isExpanded; // 是否展开
}

List<PanelItem> generatePanelItems(int numberOfItems) {
  return List<PanelItem>.generate(numberOfItems, (index) {
    return PanelItem(
      headerValue: devices[index]!.selectDeivce ?? "Unbound Device",
      deviceIndex: index,
      isExpanded: devices[index]!.selectDeivce == null ? false : true,
    );
  });
}

//?-------------------------
//?          Dialog | 选项栏
//?=========================
class DataSelect extends StatefulWidget {
  DataSelect({
    Key? key,
    this.title,
  }) : super(key: key);

  String? title;

  @override
  State<DataSelect> createState() => _DataSelectState();
}

class _DataSelectState extends State<DataSelect> {
  List<Map<String, bool>> showValue = [];
  List<List<String>> dataName = [];
  final List<PanelItem> _deviceList = generatePanelItems(devices.length);

  @override
  Widget build(BuildContext context) {
    _buildOptionList(); // 构造选项列表
    return SimpleDialog(
      title: Text(widget.title ?? "Data Select"),
      children: <Widget>[
        _buildPanel(),
      ],
    );
  }

  void _buildOptionList() {
    // 构建选项列表
    int i = 0;
    for (var element in devices) {
      if (element == null) return;
      if (showValue.length < devices.length) {
        dataName.add([]); // 构造名称列表
        showValue.add(HashMap()); // 给每一个设备留一项列表
      }
      for (var key in element.scopeData.keys) {
        // 添加选项
        showValue[i].addAll({key: false});
      }
      if (scopes.isNotEmpty) {
        // 重新勾选上之前选过的选项
        if (scopes[i].isNotEmpty) {
          for (var name in scopes[i]) {
            if (showValue[i][name] != null) {
              showValue[i][name] = true;
            }
          }
        }
      }
      dataName[i] = showValue[i].keys.toList();
      i++;
      print(dataName);
    }
  }

//? 创建设备面板
  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _deviceList[index].isExpanded = !isExpanded;
        });
      },
      children: _deviceList.map<ExpansionPanel>((PanelItem item) {
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

//? 创建选项列表
  List<Widget> _generateOptions(int deviceIndex) {
    devices[deviceIndex]!.scopeData.addAll({'Test': 0});
    // print(showValue[index].length);
    return List<Widget>.generate(showValue[deviceIndex].length, (int index) {
      return SelectedBox(
        dataName: dataName[deviceIndex][index],
        isSelect: showValue[deviceIndex][dataName[deviceIndex][index]]!,
        onChanged: () {
          setState(() {
            showValue[deviceIndex][dataName[deviceIndex][index]] =
                !showValue[deviceIndex][dataName[deviceIndex][index]]!;
          });
        },
      );
    });
  }
}

class SelectedBox extends StatefulWidget {
  const SelectedBox(
      {Key? key,
      required this.dataName,
      required this.isSelect,
      this.onChanged})
      : super(key: key);

  final bool isSelect;
  final String dataName;
  final Function()? onChanged;

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
        value: widget.isSelect,
        onChanged: widget.onChanged == null
            ? null
            : (bool? isSelect) {
                widget.onChanged!();
                // print(widget.isSelect);
              },
      ),
    );
  }
}
