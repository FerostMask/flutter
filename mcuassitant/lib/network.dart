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

  bool bind = false;

  String receivePort;
  String sendPort;

  String? wifiIPv4;

  bool _close = false;
  // 关闭UDP实例
  void close() {
    _close = true;
  }

  //? 标准UDP接收初始化
  void receiveInit() async {
    final int port = int.parse(receivePort);
    String rcvContent = "";
    var receiver = await UDP.bind(Endpoint.any(port: Port(port))); // 创建接收实例
    // 监听端口
    receiver.asStream(timeout: const Duration(seconds: 120)).listen((datagram) {
      if (datagram?.data != null) {
        rcvContent = String.fromCharCodes(datagram!.data);
      }
      print(rcvContent);
      if (_close == true) receiver.close();
    });
  }

  //? 获取本机IP
  Future<void> _getLocalIP() async {
    final NetworkInfo _networkInfo = NetworkInfo();
    try {
      // 异步执行，获得值后返回
      wifiIPv4 = await _networkInfo.getWifiIP();
      // print(wifiIPv4);
    } on PlatformException catch (e) {
      print(e);
    }
  }

  String getIP() {
    return wifiIPv4 != null ? wifiIPv4.toString() : "...";
  }
}
