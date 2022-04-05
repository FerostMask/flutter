import 'package:flutter/material.dart';
import 'package:mcuassitant/devmanage.dart';
import 'package:mcuassitant/network.dart';

void main() {
  Device.getLocalIP(); // 获取本机IP
  runApp(const MyApp());
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCUAssitant',
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomePage(title: 'HomePage'),
        '/manage': (context) => const DevManagePage(),
      },
      navigatorObservers: [routeObserver],
    );
  }
}

//! 路由页面描述类
class RouteDescribe {
  RouteDescribe({
    required this.icon,
    required this.targetPage,
    required this.pageDescribe,
  });

  final Widget icon;
  final String targetPage;
  final String pageDescribe;
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);
  //! 路由器信息
  final String title;
  final List<RouteDescribe> routes = [
    RouteDescribe(
      icon: const Icon(Icons.insights,
          size: 100, color: Color.fromARGB(200, 168, 167, 167)),
      targetPage: '/scope',
      pageDescribe: 'Scope',
    ),
    RouteDescribe(
      icon: const Icon(Icons.question_answer,
          size: 100, color: Color.fromARGB(200, 168, 167, 167)),
      targetPage: '/serial',
      pageDescribe: 'SerialPort',
    ),
    RouteDescribe(
      icon: const Icon(Icons.settings_applications,
          size: 100, color: Color.fromARGB(200, 168, 167, 167)),
      targetPage: '/manage',
      pageDescribe: 'Device',
    ),
  ];

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          padding: const EdgeInsets.all(5),
          itemCount: widget.routes.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(5),
              child: OptionBox(
                targetPage: widget.routes[index].targetPage,
                icon: widget.routes[index].icon,
                describe: widget.routes[index].pageDescribe,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    //! 订阅路由
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPushNext() {} // 入栈

  @override
  void didPopNext() {} // 出栈
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
      padding: const EdgeInsetsDirectional.only(top: 10),
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
