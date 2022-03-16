import 'dart:io';
import 'package:udp/udp.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';

List<Device?> devices = [];

class Device {
  Device({required this.bind});

  String? receivePort;
  String? sendPort;
  String receiveContent = "";
  List<String> deviceList = ["No Device Select"];

  bool bind;

  NetworkForUDP? udp;

  void contentParsing(String content) {}
}

class NetworkForUDP {
  NetworkForUDP({
    // 构造函数
    required this.receivePort,
    required this.sendPort,
    required this.parsing,
  }) {
    _getLocalIP();
    initUDP();
  }

  final String receivePort; // 接收端口
  final String sendPort; // 发送端口
  String? wifiIPv4;
  String rcvContent = "default"; // 接收内容

  bool _close = false;

  Function parsing;

  void close() {
    _close = true;
  }

  void initUDP() async {
    final int port = int.parse(receivePort);
    // UDP初始化
    var receiver = await UDP.bind(Endpoint.any(port: Port(port)));
    receiver.asStream(timeout: const Duration(seconds: 120)).listen((datagram) {
      if (datagram?.data != null) {
        rcvContent = String.fromCharCodes(datagram!.data);
      }
      parsing(rcvContent);
      print(rcvContent);
      if (_close == true) receiver.close();
    });
  }

  void serachDevice() async {
    final int port = int.parse(sendPort);
    var sender = await UDP.bind(Endpoint.any(port: Port(port)));
    await sender.send('Hello!'.codeUnits, Endpoint.broadcast(port: Port(port)));
    sender.close();
  }

  void send({required String message}) async {
    final int port = int.parse(sendPort);
    // UDP发送数据
    var sender = await UDP.bind(Endpoint.any(port: Port(port)));
    await sender.send(
        message.codeUnits,
        Endpoint.unicast(
          InternetAddress("192.168.31.89"),
          port: Port(port),
        ));
    // sender.close();
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
