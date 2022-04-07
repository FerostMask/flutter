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
    Device.getLocalIP(); // 获取本机IP
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Manage"),
        //? 更多按键
        actions: const <Widget>[
          OptionMenu(),
        ],
      ),
      //? 浮空按钮
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

enum Options { ip }

//? 更多选项
class OptionMenu extends StatefulWidget {
  const OptionMenu({Key? key}) : super(key: key);

  @override
  _OptionMenuState createState() => _OptionMenuState();
}

class _OptionMenuState extends State<OptionMenu> {
  // Options? _selection;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (Options result) {
        switch (result) {
          case Options.ip:
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(Device.getIP()),
            ));
            break;
        }
        // setState(() {
        //   // _selection = result;
        // });
      },
      offset: Offset.fromDirection(1, 55),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Options>>[
        const PopupMenuItem<Options>(
          value: Options.ip,
          child: Text('IP'),
        ),
      ],
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
    if (value.contains('-')) {
      number = -1;
    } else if (port.hasMatch(value)) {
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

  final GlobalKey<FormState> _formKeyRcv = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeySend = GlobalKey<FormState>();

  void _onSavedRcv(String? value) {
    receivePort = value;
  }

  void _onSavedSend(String? value) {
    sendPort = value;
  }

  // 处理按键
  void _handleOnPressed() {
    bool validateA = _formKeyRcv.currentState!.validate();
    bool validateB = _formKeySend.currentState!.validate();
    if (validateA && validateB) {
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ChangeValueField(
              //? 接收端口输入
              formKey: _formKeyRcv,
              onSaved: _onSavedRcv,
              hint: 'Enter receive port',
              label: 'receive port',
              padding: const EdgeInsets.only(left: 24, right: 24),
              constraint: const BoxConstraints.tightFor(width: 230),
            ),
            ChangeValueField(
              //? 发送端口输入
              formKey: _formKeySend,
              onSaved: _onSavedSend,
              hint: 'Enter send port',
              label: 'send port',
              padding: const EdgeInsets.only(left: 24, right: 24),
              constraint: const BoxConstraints.tightFor(width: 230),
            ),
          ],
        ),
        //? 添加按钮
        Padding(
          // 页面适配
          padding: const EdgeInsetsDirectional.only(
            start: 24,
            end: 24,
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
                const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
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
  String? _rcvPort;
  String? _sendPort;

  final GlobalKey<FormState> _formKeyRcv = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeySend = GlobalKey<FormState>();

  bool _alterAssert = false;
  bool _alterAssertTemp = false;

  String? connectDevice;
  //! 变换断言函数，决定是否更新端口
  void assertAlter(String oriValue, String? newValue) {
    // 比较新旧值是否相同
    if (newValue != null && newValue.isNotEmpty) {
      if (newValue != oriValue) {
        _alterAssertTemp = true;
      } else {
        _alterAssertTemp = false;
      }
    } else {
      _alterAssertTemp = false;
    }
    // 状态机，在 变化/未变化 间切换
    if (_alterAssert != _alterAssertTemp) {
      setState(() {
        _alterAssert = _alterAssertTemp;
      });
    }
  }

//? 传输内容分析函数
  void _parsing(String value) {
    var rawData = value.split(",");
    if (rawData[0] == 'IP') {
      devices[widget.index]!
          .deviceMap
          .addAll(<String, String>{rawData[1]: rawData[2]});
      // print(devices[widget.index]!.deviceMap);
    }
  }

//? 更新按钮处理
  void _handleUpdate() {
    // 处理发送端口
    if (_sendPort != null && _sendPort!.isNotEmpty) {
      if (_formKeySend.currentState!.validate()) {
        // 另一个框为空，随便修改
        if (_rcvPort == null || _rcvPort != null && _rcvPort!.isEmpty) {
          _alterAssert = false;
          _alterAssertTemp = false;
        }
        setState(() {
          devices[widget.index]!.sendPort = _sendPort!;
        });
      }
    }
    if (_rcvPort != null && _rcvPort!.isNotEmpty) {
      if (_formKeyRcv.currentState!.validate()) {
        // 另一个框为空，随便修改
        if (_sendPort == null || _sendPort != null && _sendPort!.isEmpty) {
          _alterAssert = false;
          _alterAssertTemp = false;
        }
        //? 关闭之前的UDP接收实例
        devices[widget.index]!.close();
        setState(() {
          // 变更接收口
          devices[widget.index]!.receivePort = _rcvPort!;
          //? 新的UDP实例会在设备盒子建立时创建
        });
      }
    }
    // 判断是否恢复断言 | 无法判断某框为空的情况
    if (_sendPort != null && _rcvPort != null) {
      // 判空
      if (_sendPort!.isNotEmpty && _rcvPort!.isNotEmpty) {
        if (_sendPort == devices[widget.index]!.sendPort) {
          if (_rcvPort == devices[widget.index]!.receivePort) {
            _alterAssert = false;
            _alterAssertTemp = false;
          }
        }
      }
    }
  }

//? 刷新按钮处理
  void _handleRefresh() {
    devices[widget.index]!.broadcastSend(message: 'Hello');
  }

  void _handleConnect() {
    Device.getIP();
    // 这边会有一个BUG，如果在连接上之前在选择了其他可选设备并点击连接，那前一个连接请求成功会使当前选择的设备进入连接状态
    if (devices[widget.index]!.selectDeivce != Device.defaultSelectDeivce) {
      connectDevice = devices[widget.index]!.selectDeivce;
    }
    devices[widget.index]!.bindDevice();
    devices[widget.index]!.updateParsing((String value) {
      if (value == 'BIND') {
        setState(() {
          devices[widget.index]!.bind = true;
          devices[widget.index]!.destinationIP =
              devices[widget.index]!.deviceMap[connectDevice]; // 保存目标设备IP
        });
      }
    });
  }

  void _handleDisconnect() {
    devices[widget.index]!.send(message: 'UNBIND,');
    devices[widget.index]!.receiveWithParsing((String value) {
      // 这里重新创建UDP接收实例，防止实例自动关闭接收不到数据
      if (value == 'UNBIND') {
        setState(() {
          devices[widget.index]!.bind = false;
          devices[widget.index]!.destinationIP = null; // 清除目标设备IP
        });
      }
    });
  }

//? 处理输入框保存内容
  void _handleRcvSaved(String? value) {
    _rcvPort = value;
    assertAlter(devices[widget.index]!.receivePort, _rcvPort);
  }

  void _handleSendSaved(String? value) {
    _sendPort = value;
    assertAlter(devices[widget.index]!.sendPort, _sendPort);
  }

  @override
  Widget build(BuildContext context) {
    //? 创建UDP接收实例
    devices[widget.index]!.receiveWithParsing(_parsing);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        OptionalDevice(index: widget.index),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ChangeValueField(
              formKey: _formKeyRcv,
              onSaved: _handleRcvSaved,
              hint: 'Enter new port',
              label: 'Receive Port: ${devices[widget.index]!.receivePort}',
            ),
            ChangeValueField(
              formKey: _formKeySend,
              onSaved: _handleSendSaved,
              hint: 'Enter new port',
              label: 'Send Port: ${devices[widget.index]!.sendPort}',
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            ChangeButton(
              text: _alterAssert ? 'Update' : 'Refresh',
              color: _alterAssert ? Colors.blue : Colors.grey,
              onChanged: _alterAssert ? _handleUpdate : _handleRefresh,
            ),
            StackButton(
              onChanged: devices[widget.index]!.bind
                  ? _handleDisconnect
                  : _handleConnect,
              text: devices[widget.index]!.bind ? 'Disconnect' : 'Connect',
              fillColor: devices[widget.index]!.bind
                  ? Colors.redAccent
                  : Colors.green[300],
            ),
          ],
        ),
      ],
    );
  }
}

class OptionalDevice extends StatefulWidget {
  //? 选择框
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

class ChangeValueField extends StatefulWidget {
  //? 输入框
  const ChangeValueField({
    Key? key,
    required this.formKey,
    required this.onSaved,
    required this.hint,
    required this.label,
    this.padding,
    this.constraint,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;
  final Function(String?) onSaved;
  final String hint;
  final String label;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraint; // 横向限制器

  @override
  _ChangeValueField createState() => _ChangeValueField();
}

class _ChangeValueField extends State<ChangeValueField> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      onChanged: () {
        // 在输入框内容变化时调用保存函数
        Form.of(primaryFocus!.context!)!.save();
      },
      child: FocusTraversalGroup(
        child: Padding(
          padding: widget.padding ??
              const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: ConstrainedBox(
            // 限制盒子
            constraints:
                widget.constraint ?? const BoxConstraints.tightFor(width: 150),
            child: TextFormField(
              onSaved: widget.onSaved, // 被调用的保存函数
              validator: Validators.isPort, // 被调用的校验器，通过key调用该方法
              decoration: InputDecoration(
                hintText: widget.hint, // 提示
                labelText: widget.label, // 标签信息
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChangeButton extends StatefulWidget {
  //? 按钮
  const ChangeButton({
    Key? key,
    required this.text,
    this.color,
    required this.onChanged,
    this.fontSize,
  }) : super(key: key);

  final String text;
  final Color? color;
  final Function()? onChanged;
  final double? fontSize;

  @override
  _ChangeButtonState createState() => _ChangeButtonState();
}

class _ChangeButtonState extends State<ChangeButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 10),
      child: TextButton(
        onPressed: widget.onChanged,
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: widget.fontSize ?? 20,
            color: widget.color ?? Colors.blue,
          ),
        ),
      ),
    );
  }
}

class StackButton extends StatefulWidget {
  //? 填充颜色的按钮
  const StackButton({
    Key? key,
    this.onChanged,
    this.padding,
    this.fillColor,
    required this.text,
    this.textStyle,
  }) : super(key: key);

  final Function()? onChanged;
  final Color? fillColor;
  final EdgeInsets? padding;
  final String text;
  final TextStyle? textStyle;

  @override
  _StackButtonState createState() => _StackButtonState();
}

class _StackButtonState extends State<StackButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.only(top: 10, bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: widget.fillColor ?? Colors.blue,
                ),
              ),
            ),
            TextButton(
              onPressed: widget.onChanged,
              child: Text(
                widget.text,
                style: widget.textStyle ??
                    const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
