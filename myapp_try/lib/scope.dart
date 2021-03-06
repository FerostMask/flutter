import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class ScopePage extends StatelessWidget {
  const ScopePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scope'),
      ),
      body: Center(
        child: Text('Text'),
      ),
    );
  }
}

class Scope extends StatelessWidget {
  const Scope({Key? key}) : super(key: key);

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
        child: const Material(
          child: LineChartSample10(),
        ),
      ),
    );
  }
}

class LineChartSample10 extends StatefulWidget {
  const LineChartSample10({Key? key}) : super(key: key);

  @override
  _LineChartSample10State createState() => _LineChartSample10State();
}

class _LineChartSample10State extends State<LineChartSample10> {
  final Color sinColor = Colors.redAccent;
  final Color cosColor = Colors.blueAccent;

  final limitCount = 100; // 允许显示的范围
  final sinPoints = <FlSpot>[];
  final cosPoints = <FlSpot>[];

  final storage_max = <double>[0];
  final storage_min = <double>[0];

  double xValue = 0; // 起始值
  double step = 0.1; // 步长

  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      // 推测：每过40ms执行一次该函数
      while (sinPoints.length > limitCount) {
        sinPoints.removeAt(0); // 出列
        cosPoints.removeAt(0);
        storage_max.removeAt(0);
        storage_min.removeAt(0);
      }
      setState(() {
        sinPoints.add(FlSpot(xValue, 2 * math.sin(xValue))); // 入列
        cosPoints.add(FlSpot(xValue, math.cos(xValue)));
        if (2 * math.sin(xValue) > math.cos(xValue)) {
          storage_max.add(2 * math.sin(xValue));
          storage_min.add(math.cos(xValue));
        } else {
          storage_min.add(2 * math.sin(xValue));
          storage_max.add(math.cos(xValue));
        }
      });
      xValue += step;
    });
  }

  @override
  Widget build(BuildContext context) {
    return cosPoints.isNotEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 文字显示部分
              // Text(
              //   'x: ${xValue.toStringAsFixed(1)}',
              //   style: const TextStyle(
              //     color: Colors.black,
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // Text(
              //   'sin: ${sinPoints.last.y.toStringAsFixed(1)}',
              //   style: TextStyle(
              //     color: sinColor,
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // Text(
              //   'cos: ${cosPoints.last.y.toStringAsFixed(1)}',
              //   style: TextStyle(
              //     color: cosColor,
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(
                height: 12,
              ),
              SizedBox(
                // 盒子的尺寸
                width: 600,
                height: 300,
                child: LineChart(
                  LineChartData(
                    // 坐标轴四周极值
                    minY: storage_min.reduce(math.min) - 0.5,
                    maxY: storage_max.reduce(math.max) + 0.5,
                    minX: sinPoints.first.x,
                    maxX: sinPoints.last.x,
                    lineTouchData: LineTouchData(enabled: false),
                    clipData: FlClipData.all(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                    lineBarsData: [
                      sinLine(sinPoints),
                      cosLine(cosPoints),
                    ],
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        : Container();
  }

  LineChartBarData sinLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: FlDotData(
        show: false,
      ),
      colors: [sinColor.withOpacity(0), sinColor],
      colorStops: [0.1, 1.0],
      barWidth: 4,
      isCurved: false,
    );
  }

  LineChartBarData cosLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: FlDotData(
        show: false,
      ),
      colors: [cosColor.withOpacity(0), cosColor],
      colorStops: [0.01, 0.9], // 透明度、显示范围
      barWidth: 4, // 线宽
      isCurved: false,
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
