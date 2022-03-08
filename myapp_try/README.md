# myapp_try

我的第一个Flutter项目！

# 开发日志

### 3/8/2022 更改设备框修改逻辑，支持单独修改端口，区分刷新、修改按键

![屏幕截图 2022-03-08 220730](C:\Users\Szasd\Pictures\Saved Pictures\屏幕截图 2022-03-08 220730.jpg)

现在可以单独修改其中一个端口了，在输入框中输入新的内容后原先`Refresh`按键会变为`Update`按键。两者拥有独立功能。

`Update`：更新设备端口信息

`Refresh`：刷新可连接设备列表

经测试UDP接收功能正常。发送功能在MCU助手项目更新后也能正常使用了。

### 3/6/2022 完善设备框

![IMG_3/6/2022](https://ferost-myphotos.oss-cn-shenzhen.aliyuncs.com/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202022-03-07%20140434.jpg)

被`mainAxisAlignment`困扰了一阵子（框框一直对不齐，疯狂加`Padding`发现没有用，最后一个一个查才发现`Row`和`Column`有两个参数可以调节位置）。

用`DropdownButton`做了一个设备选择的演示，暂时还没有把相关功能实现加进来。

------

### 3/5/2022 实现FloatingActionButton添加设备功能

![IMG_3/5/2022](https://ferost-myphotos.oss-cn-shenzhen.aliyuncs.com/%E5%B1%8F%E5%B9%95%E6%88%AA%E5%9B%BE%202022-03-07%20135950.jpg)

可以通过`TextFormField`输入任意内容了！并且有专门的`validator`来检测输入的端口是否合法。

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
