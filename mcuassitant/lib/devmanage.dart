import 'package:flutter/material.dart';
import 'package:mcuassitant/network.dart';

//?-------------------------
//?                 路由页面
//?=========================
class DevManagePage extends StatefulWidget {
  const DevManagePage({Key? key}) : super(key: key);

  @override
  _DevManagePageState createState() => _DevManagePageState();
}

class _DevManagePageState extends State<DevManagePage> {
  //! 浮空按钮处理函数
  void handleButton() async {
    //? 生成对话框
    final Device? item = await showDialog<Device>(
      context: context,
      builder: (BuildContext context) {
        return const PortInput(title: 'New Device');
      },
    );
    if (item == null) return;
    devices.add(item);
    setState(() {});
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
      body: DeviceList(
        deviceCount: devices.length,
      ),
    );
  }
}

//?-------------------------
//?                 校验器类
//?=========================
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

//?-------------------------
//?          对话框 | Dialog
//?=========================
class PortInput extends StatefulWidget {
  const PortInput({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _PortInputState createState() => _PortInputState();
}

class _PortInputState extends State<PortInput> {
  String? receivePort;
  String? sendPort;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // 处理按键
  void _handleOnPressed() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
          context, Device(receivePort: receivePort!, sendPort: sendPort!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(widget.title),
      children: [
        //? 输入框
        Form(
          key: _formKey,
          onChanged: () {
            Form.of(primaryFocus!.context!)!.save();
          },
          child: FocusTraversalGroup(
            child: Column(
              children: <Widget>[
                //? 接收端口输入
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter Receive Port',
                      labelText: 'Receive Port',
                    ),
                    onSaved: (String? value) {
                      receivePort = value;
                    },
                    validator: Validators.isPort,
                  ),
                ),
                //? 发送端口输入
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter Send Port',
                      labelText: 'Send Port',
                    ),
                    onSaved: (String? value) {
                      sendPort = value;
                    },
                    validator: Validators.isPort,
                  ),
                ),
              ],
            ),
          ),
        ),
        //? 添加按钮
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
            child: const Text('Add'),
          ),
        ),
      ],
    );
  }
}

//?-------------------------
//?            设备栏 | List
//?=========================
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
            child: DeviceBox(index: index),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) =>
          const Divider(indent: 20, endIndent: 20),
      itemCount: widget.deviceCount,
    );
  }
}

//?-------------------------
//?   设备盒子 | 由设备栏生成
//?=========================
class DeviceBox extends StatefulWidget {
  // 在创建设备盒子时创建接收实例并传入分析函数，
  const DeviceBox({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  _DeviceBoxState createState() => _DeviceBoxState();
}

class _DeviceBoxState extends State<DeviceBox> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        OptionalDevice(index: widget.index),
      ],
    );
  }
}

class OptionalDevice extends StatefulWidget {
  const OptionalDevice({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  _OptionalDeviceState createState() => _OptionalDeviceState();
}

class _OptionalDeviceState extends State<OptionalDevice> {
  String? dropdownValue;
  late List<String> optionalDevices;

  @override
  Widget build(BuildContext context) {
    // 构造列表
    dropdownValue = devices[widget.index]!.selectDeivce;
    optionalDevices =
        List<String>.from(devices[widget.index]!.deviceMap.keys.toList());
    return DropdownButton<String>(
      value: dropdownValue, // 选择的值
      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
      elevation: 16, // 高度
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
          devices[widget.index]!.selectDeivce = newValue;
        });
      },
      items: optionalDevices.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
