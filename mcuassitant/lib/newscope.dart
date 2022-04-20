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

  // List<Map<int, String>> showData = []; // 显示的数据
  List<Line> lines = [Line(deviceIndex: 0, dataName: 'test')]; // 显示的数据 | 线的形式

  static List<List<String>> dataNameList = [];
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
    stops: [0.1, 1.0],
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
  double xValue = 0;
  double step = 0.1; // 步长
  double lineWidth = 4; // 线宽
  var extremum = SplayTreeMap<int, int>((a, b) => a.compareTo(b));

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
          if (extremum[deleteValue]! > 1) {
            // 数量大于1，count--
            extremum[deleteValue] = extremum[deleteValue]! - 1;
          } else {
            // 数量小于等于1，从Map中删除键值对
            extremum.remove(deleteValue);
          }
          line.points.removeAt(0);
        }
      }
      // 添加点、处理上下限、绘制点
      setState(() {
        for (var line in scopes[widget.index].lines) {
          double? pushValue = line.addPoint(xValue);
          int addValue = 0;
          // 利用有序哈希处理上下界
          if (pushValue != null) {
            addValue = pushValue.toInt();
            if (extremum[addValue] != null) {
              //count++
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
            const Padding(
              padding: EdgeInsets.only(top: 10, left: 550),
              // child: PopupMenu(
              //   handleManage: _handleManage,
              // ),
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
          minY: extremum.firstKey() == null ? -1 : extremum.firstKey()! - 2,
          maxY: extremum.lastKey() == null
              ? 1
              : extremum.lastKey()!.toDouble() + 2,
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
