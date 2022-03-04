import 'package:flutter/material.dart';

class SerialPage extends StatelessWidget {
  const SerialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SerialPort"),
      ),
      body: const SerialWindow(),
    );
  }
}

class SerialWindow extends StatefulWidget {
  const SerialWindow({Key? key}) : super(key: key);

  @override
  _SerialWindowState createState() => _SerialWindowState();
}

class _SerialWindowState extends State<SerialWindow> {
  final List<String> informations = [];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: informations.length,
        itemBuilder: (BuildContext context, int index) {
          return ChatBox(content: informations[index]);
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            height: 5,
            thickness: 1,
            color: Color.fromARGB(0, 255, 255, 255),
          );
        });
  }
}

class ChatBox extends StatelessWidget {
  const ChatBox({Key? key, required this.content}) : super(key: key);

  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      padding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 15), // 子Widget位置
      margin: const EdgeInsetsDirectional.only(start: 10, end: 200), // 自身位置
      child: Text(content),
    );
  }
}
