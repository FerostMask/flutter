import 'dart:io';
import 'package:udp/udp.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';

List<Device?> devices = [];

//?-------------------------
//?                   设备类
//?=========================
class Device {
  Device({required this.receivePort, required this.sendPort});
  static String defaultSelectDeivce = 'No Device Select';

  bool bind = false; // 设备绑定
  Map<String, String> deviceMap = {defaultSelectDeivce: ''}; // 设备表
  Map<String, double> scopeData = {'Test': 1};
  String? selectDeivce;
  String? destinationIP;

  String receivePort; // 接收端口
  String sendPort; // 发送端口

  Function(String)? _parsing;

  static String? wifiIPv4;

  List<UDP> receivers = [];

  // late UDP receiver;
  // 关闭UDP接收实例
  void close() {
    for (int i = 0; i < receivers.length; i++) {
      receivers[i].close();
    }
    receivers.clear();
    // receiver.close();
  }

  //? 接收并处理数据函数
  void receiveWithParsing(Function(String) parsing) async {
    _parsing = parsing;
    final int port = int.parse(receivePort);
    String? rcvContent;
    var receiver = await UDP.bind(Endpoint.any(port: Port(port))); // 创建接收实例
    receivers.add(receiver);
    // 监听端口
    receivers[receivers.length - 1]
        .asStream(timeout: const Duration(seconds: 60))
        .listen((datagram) {
      // 接收并处理数据
      if (datagram != null) {
        rcvContent = String.fromCharCodes(datagram.data);
        if (rcvContent != null && rcvContent!.isNotEmpty) {
          print(rcvContent);
          _parsing!(rcvContent!);
        }
      }
    });
  }

  void updateParsing(Function(String) parsing) {
    _parsing = parsing;
  }

  //? 标准UDP接收初始化
  // void receiveInit() async {
  //   final int port = int.parse(receivePort);
  //   String rcvContent = "";
  //   receiver = await UDP.bind(Endpoint.any(port: Port(port))); // 创建接收实例
  //   // 监听端口
  //   receiver.asStream(timeout: const Duration(seconds: 120)).listen((datagram) {
  //     if (datagram?.data != null) {
  //       rcvContent = String.fromCharCodes(datagram!.data);
  //     }
  //     // print(rcvContent);
  //     // if (_close == true) {
  //     //   receiver.close();
  //     //   _close = false;
  //     // }
  //   });
  // }

  //? 数据发送
  void send({required String message}) async {
    final int port = int.parse(sendPort);
    // UDP发送数据
    var sender = await UDP.bind(Endpoint.any(port: Port(port)));
    await sender.send(
        message.codeUnits,
        Endpoint.unicast(
          InternetAddress(destinationIP ?? "127.0.0.1"),
          port: Port(port),
        ));
    sender.close();
  }

  //? 设备绑定
  void bindDevice() async {
    if (wifiIPv4 == null) return;
    if (selectDeivce == null || selectDeivce == defaultSelectDeivce) return;
    final int port = int.parse(sendPort);
    String message = 'BIND,' + wifiIPv4!;
    var sender = await UDP.bind(Endpoint.any(port: Port(port)));
    await sender.send(
        message.codeUnits,
        Endpoint.unicast(
          InternetAddress(deviceMap[selectDeivce]!),
          port: Port(port),
        ));
    sender.close();
  }

  //? 广播信息
  void broadcastSend({required String message}) async {
    final int port = int.parse(sendPort);
    // UDP发送数据
    if (wifiIPv4 == null) return;
    List<String> originIP = wifiIPv4!.split('.');
    originIP[3] = '255';
    String broadcastIP = originIP.join('.');
    var sender = await UDP.bind(Endpoint.any(port: Port(port)));
    await sender.send(
        message.codeUnits,
        Endpoint.unicast(
          InternetAddress(broadcastIP),
          port: Port(port),
        ));
    sender.close();
  }

  //? 获取本机IP
  static Future<void> getLocalIP() async {
    final NetworkInfo _networkInfo = NetworkInfo();
    try {
      // 异步执行，获得值后返回
      wifiIPv4 = await _networkInfo.getWifiIP();
      // print(wifiIPv4);
    } on PlatformException catch (e) {
      print(e);
    }
  }

  static String getIP() {
    getLocalIP();
    return wifiIPv4 ?? '...';
  }
}
