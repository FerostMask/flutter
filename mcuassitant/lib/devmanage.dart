import 'package:flutter/material.dart';

//?---------------
//?       路由页面
//?===============
class DevManagePage extends StatefulWidget {
  const DevManagePage({Key? key}) : super(key: key);

  @override
  _DevManagePageState createState() => _DevManagePageState();
}

class _DevManagePageState extends State<DevManagePage> {
  void handleButton() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Manage"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: handleButton,
      ),
    );
  }
}

//?---------------
//?  设备栏 | List
//?===============
class DeviceList extends StatefulWidget {
  const DeviceList({Key? key, required this.deviceCount}) : super(key: key);

  final int deviceCount;

  @override
  _DeviceList createState() => _DeviceList();
}

class _DeviceList extends State<DeviceList> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 10, right: 10),
            margin:
                const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) =>
          const Divider(indent: 20, endIndent: 20),
      itemCount: widget.deviceCount,
    );
  }
}
