import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp_try/scope.dart';
import 'package:myapp_try/network.dart';
import 'package:myapp_try/serial.dart';

var udpInstance = NetworkForUDP(receivePort: 9000, sendPort: 8000);

void main() async {
// 网络初始化
  udpInstance.initUDP();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomePage(title: 'HomePage'),
        '/scope': (context) => ScopePage(
              broadcastIP: udpInstance.getIP(), // 调用接口获取本地IP
            ),
        '/serial': (context) => const SerialPage(),
      },
    );
  }
}

// 主界面
class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 主界面样式
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontFamily: "汉仪尚巍手书W",
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: const <Widget>[
            OptionBox(
              targetPage: "/scope",
              icon: Icon(
                // 示波器
                Icons.insights,
                size: 100,
                color: Color.fromARGB(200, 168, 167, 167),
              ),
              describe: 'Scope',
            ),
            OptionBox(
              // 串口
              targetPage: "/serial",
              icon: Icon(
                Icons.question_answer,
                size: 100,
                color: Color.fromARGB(200, 168, 167, 167),
              ),
              describe: "SerialPort",
            ),
          ],
        ),
      ),
    );
  }
}

// 主界面选项盒
class OptionBox extends StatelessWidget {
  const OptionBox({
    Key? key,
    required this.targetPage,
    required this.icon,
    required this.describe,
  }) : super(key: key);

  final String targetPage;
  final String describe;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, targetPage),
        child: Column(
          children: <Widget>[
            icon,
            Text(
              describe,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(200, 168, 167, 167),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
