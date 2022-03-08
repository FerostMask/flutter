import 'package:flutter/cupertino.dart';
import 'package:myapp_try/network.dart';
import 'package:flutter/material.dart';

//------
// 路由页面
//======
class DevManagePage extends StatefulWidget {
  DevManagePage({Key? key}) : super(key: key);

  @override
  _DevManagePageState createState() => _DevManagePageState();
}

class _DevManagePageState extends State<DevManagePage> {
  void handleButton() async {
    // 点击加号后的Dialog | 由FloatingActionButton触发
    final Device? item = await showDialog<Device>(
      context: context,
      builder: (BuildContext context) {
        return PortInput();
      },
    );
    if (item == null) return;
    devices.add(item);
    setState(() {}); // 更新界面
  }

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
      body: DevManage(
        devCount: devices.length,
      ),
    );
  }
}

//------
// 设备栏 | List
//======
class DevManage extends StatefulWidget {
  const DevManage({Key? key, required this.devCount}) : super(key: key);

  final devCount;

  @override
  _DevManageState createState() => _DevManageState();
}

class _DevManageState extends State<DevManage> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          child: Container(
            // height: 200,
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 10, right: 10),
            margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: DeviceBox(index: index),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(
        indent: 20,
        endIndent: 20,
      ),
      itemCount: widget.devCount,
    );
  }
}

//------
// 设备框内容 | 由设备栏生成
//======
class DeviceBox extends StatefulWidget {
  DeviceBox({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  _DeviceBoxState createState() => _DeviceBoxState();
}

class _DeviceBoxState extends State<DeviceBox> {
  // List<String> deviceList = ["No Device Select"];
  String? dropdownValue;
  Device itemTemp = Device(bind: false);
  bool alterAssert = false;
  bool alterAssertTemp = false;
  final GlobalKey<FormState> _formKeyRcv = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeySend = GlobalKey<FormState>();

  void _handleConnect() {}

  void assertAlter(String oriValue, String newValue) {
    if (newValue != null && newValue.isNotEmpty) {
      if (newValue != oriValue) {
        alterAssertTemp = true;
      }
    } else {
      alterAssertTemp = false;
    }
    if (alterAssert != alterAssertTemp) {
      // 变化检测
      alterAssert = alterAssertTemp;
      setState(() {});
    }
  }

  void _handleUpdate() {
    // 处理更新按键，生成新设备
    if (itemTemp.sendPort != null) {
      if (itemTemp.sendPort!.isNotEmpty) {
        if (_formKeySend.currentState!.validate()) {
          setState(() {
            // 修改断言
            alterAssert = false;
            alterAssertTemp = false;
            devices[widget.index]!.sendPort = itemTemp.sendPort!; // 修改端口
          });
        }
      }
    }
    if (itemTemp.receivePort != null) {
      if (itemTemp.receivePort!.isNotEmpty) {
        if (_formKeyRcv.currentState!.validate()) {
          setState(() {
            // 修改断言
            alterAssert = false;
            alterAssertTemp = false;
            devices[widget.index]!.receivePort = itemTemp.receivePort; // 修改端口
            devices[widget.index]!.udp!.close(); // 关闭端口
            devices[widget.index]!.udp = NetworkForUDP(
              // 创建新udp实例
              receivePort: devices[widget.index]!.receivePort!,
              sendPort: devices[widget.index]!.sendPort!,
            );
          });
        }
      }
    }
  }

  void _handleRefresh() {
    // devices[widget.index]!.udp!.serachDevice();
    devices[widget.index]!.udp!.send(message: "Hello!");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // 连接设备列表
        DropdownButton<String>(
          value: dropdownValue,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          elevation: 16,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 20,
          ),
          underline: Container(
            height: 2,
            color: Colors.grey,
          ),
          onChanged: (String? newValue) {
            // 设备选择
            setState(() {
              dropdownValue = newValue;
            });
          },
          // 下拉列表
          items: devices[widget.index]!
              .deviceList
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        //  端口输入
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKeyRcv,
              onChanged: () {
                Form.of(primaryFocus!.context!)!.save();
              },
              child: FocusTraversalGroup(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 150),
                    child: TextFormField(
                      onSaved: (String? value) {
                        itemTemp.receivePort = value;
                        assertAlter(devices[widget.index]!.receivePort!,
                            itemTemp.receivePort!);
                      },
                      validator: Validators.isPort,
                      decoration: InputDecoration(
                        hintText: 'enter new port',
                        labelText:
                            'Receive Port: ${devices[widget.index]!.receivePort}',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Form(
              key: _formKeySend,
              onChanged: () {
                Form.of(primaryFocus!.context!)!.save();
              },
              child: FocusTraversalGroup(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 150),
                    child: TextFormField(
                      onSaved: (String? value) {
                        itemTemp.sendPort = value;
                        assertAlter(devices[widget.index]!.sendPort!,
                            itemTemp.sendPort!);
                      },
                      validator: Validators.isPort,
                      decoration: InputDecoration(
                        hintText: 'enter new port',
                        labelText:
                            'Send Port: ${devices[widget.index]!.sendPort}',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // 按键
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 20),
              child: TextButton(
                onPressed: alterAssert ? _handleUpdate : _handleRefresh,
                child: Text(
                  alterAssert ? "Update" : "Refresh",
                  style: TextStyle(
                    fontSize: 20,
                    color: alterAssert ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: devices[widget.index]!.bind
                              ? Colors.red[350]
                              : Colors.green,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _handleConnect,
                      child: Text(
                        devices[widget.index]!.bind ? 'Disconnect' : 'Connect',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

//------
// 校验器类
//======
class Validators {
  static String? isPort(String? value) {
    // 端口合法性检测
    if (value == null) return "Please input a number";
    int number = 0;
    RegExp port = RegExp(r"\d");
    if (port.hasMatch(value)) {
      number = int.parse(value);
    }
    return ((port.hasMatch(value) && number >= 0 && number < 65536)
        ? null
        : 'illegal port!');
  }
}

//------
// 端口输入框 | 嵌入Dialog
//======
class PortInput extends StatefulWidget {
  const PortInput({Key? key}) : super(key: key);

  @override
  _PortInputState createState() => _PortInputState();
}

class _PortInputState extends State<PortInput> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Device item = Device(bind: false);

  void _handleOnPressed() {
    if (_formKey.currentState!.validate()) {
      item.udp = NetworkForUDP(
          receivePort: item.receivePort!, sendPort: item.sendPort!);
      Navigator.pop(context, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('New Device'),
      children: [
        //  输入框
        Form(
          key: _formKey,
          onChanged: () {
            Form.of(primaryFocus!.context!)!.save();
          },
          child: FocusTraversalGroup(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 24, end: 24),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter receive port',
                      labelText: 'receive port',
                    ),
                    onSaved: (String? value) {
                      // 存储输入框中的内容
                      item.receivePort = value;
                    },
                    validator: Validators.isPort,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 24, end: 24),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter send port',
                      labelText: 'send port',
                    ),
                    onSaved: (String? value) {
                      // 存储输入框中的内容
                      item.sendPort = value;
                    },
                    validator: Validators.isPort,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          // 页面适配
          padding: const EdgeInsetsDirectional.only(
            start: 30,
            end: 30,
            top: 15,
            bottom: 0,
          ),
          child: ElevatedButton(
            // 提交按钮
            onPressed: _handleOnPressed,
            child: Text('Add'),
          ),
        ),
      ],
    );
  }
}
