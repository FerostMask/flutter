import 'dart:io';
import 'package:udp/udp.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';

List<Device?> devices = [];

class Device {
  Device({required this.bind});

  String? receivePort;
  String? sendPort;
  bool bind;
}

class NetworkForUDP {
  NetworkForUDP({
    // 构造函数
    required this.receivePort,
    required this.sendPort,
  }) {
    _getLocalIP();
  }

  final int receivePort; // 接收端口
  final int sendPort; // 发送端口
  String? wifiIPv4;
  String rcvContent = "default"; // 接收内容

  void initUDP() async {
    // UDP初始化
    var receiver = await UDP.bind(Endpoint.any(port: Port(receivePort)));
    receiver.asStream(timeout: const Duration(seconds: 120)).listen((datagram) {
      if (datagram?.data != null) {
        rcvContent = String.fromCharCodes(datagram!.data);
      }
      print(rcvContent);
      send(message: "Hello!");
    });
  }

  void send({required String message}) async {
    // UDP发送数据
    var sender = await UDP.bind(Endpoint.any(port: Port(sendPort)));
    await sender.send(
        message.codeUnits,
        Endpoint.unicast(
          InternetAddress("192.168.31.89"),
          port: Port(sendPort),
        ));
  }

  Future<void> _getLocalIP() async {
    final NetworkInfo _networkInfo = NetworkInfo();
    try {
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
