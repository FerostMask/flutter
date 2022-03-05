import 'package:flutter/cupertino.dart';
import 'package:myapp_try/network.dart';
import 'package:flutter/material.dart';

class DevManagePage extends StatefulWidget {
  DevManagePage({Key? key}) : super(key: key);

  @override
  _DevManagePageState createState() => _DevManagePageState();
}

class _DevManagePageState extends State<DevManagePage> {
  void handleButton() async {
    // 点击加号后的对话框
    final Device? item = await showDialog<Device>(
        context: context,
        builder: (BuildContext context) {
          return PortInput();
        });
    if (item == null) return;
    devices.add(item);
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

// 端口输入框
class PortInput extends StatefulWidget {
  const PortInput({Key? key}) : super(key: key);

  @override
  _PortInputState createState() => _PortInputState();
}

class _PortInputState extends State<PortInput> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Device item = Device();
  // 输入内容合法性检测
  String? portValidator(String? value) {
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

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Port Initial'),
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
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter receive port',
                  ),
                  onSaved: (String? value) {
                    // 存储输入框中的内容
                    item.receivePort = value;
                  },
                  validator: portValidator,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter send port',
                  ),
                  onSaved: (String? value) {
                    item.sendPort = value;
                  },
                  validator: portValidator,
                ),
              ],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, item);
            }
          },
          child: Text('submit'),
        ),
      ],
    );
  }
}

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
        return Container(
          height: 50,
          child: Text('$index'),
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemCount: widget.devCount,
    );
  }
}
