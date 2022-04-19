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
//?         线类 | 描述线属性
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

  late Timer timer;

  List<Line> lines = [];
  List<LineChartBarData> data = [];

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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onLongPress: null,
        child: Container(
          height: 400.0,
          padding: const EdgeInsets.all(4.0),
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 600,
                height: 300,
                child: lines.isNotEmpty
                    ? LineChart(
                        LineChartData(
                            minY: extremum.firstKey() == null
                                ? -1
                                : extremum.firstKey()! - 2,
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
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
