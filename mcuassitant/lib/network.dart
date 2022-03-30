import 'dart:io';
import 'package:udp/udp.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';

List<Device?> devices = [];

class Device {
  Device({required this.bind});

  bool bind;

  String? receivePort;
  String? sendPort;
}
