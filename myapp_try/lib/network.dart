import 'dart:io';
import 'package:udp/udp.dart';

class NetworkForUDP {
  NetworkForUDP({
    // 构造函数
    required this.receivePort,
    required this.sendPort,
  });

  final int receivePort; // 接收端口
  final int sendPort; // 发送端口
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
}
