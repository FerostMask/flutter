import 'dart:collection';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mcuassitant/network.dart';
// import 'dart:math' as math;

List<List<String>> scopes = [];

class ScopePage extends StatefulWidget {
  const ScopePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ScopePage> createState() => _ScopePageState();
}

class _ScopePageState extends State<ScopePage> {
  void _handleButton() {
    setState(() {
      scopes.add(['0:Test']);
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

class Line {
  Line({
    required this.sourceValue,
    this.color,
    this.opacity,
    this.range,
    this.width,
  }) {
    // List<String> info = sourceValue.split(':');
    // deviceIndex = int.parse(info[0]);
    // name = info[1];
  }
  final points = <FlSpot>[];
  Color? color = Colors.lightBlueAccent[700];
  double? opacity = 0.1;
  double? range = 1.0;
  double? width = 4;

  late int deviceIndex;
  late String name;

  String sourceValue;

  void addPoint(double xValue) {
    points.add(FlSpot(xValue, devices[deviceIndex]!.scopeData[name]!));
  }
}

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
  var maximum = SplayTreeMap<double, int>((a, b) => a.compareTo(b));

  late Timer timer;

  List<Line> lines = [Line(sourceValue: '0:test')];
  List<LineChartBarData>? data;

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
      data!.add(LineChartBarData(
        spots: lines[i].points,
        dotData: FlDotData(show: false),
        colors: [lines[i].color!.withOpacity(0), lines[i].color!],
        colorStops: [lines[i].opacity!, lines[i].range!],
        barWidth: lines[i].width!,
        isCurved: false,
      ));
    }
    timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      for (int i = 0; i < lines.length; i++) {
        // 出列超出范围的点
        while (lines[i].points.length > limitCount) {
          lines[i].points.removeAt(0);
        }
      }
      // 添加点、处理上下限、绘制点
      setState(() {
        for (int i = 0; i < lines.length; i++) {
          lines[i].addPoint(xValue);
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
                            minY: -2,
                            maxY: 2,
                            minX: lines[0].points.first.x,
                            maxX: lines[0].points.last.x,
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
