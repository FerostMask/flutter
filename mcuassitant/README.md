# MCUAssitant

MCU调试助手

# 开发计划

| 符号 | !                                | ?                |
| ---- | -------------------------------- | ---------------- |
| 含义 | 重要内容，没有它功能无法正常使用 | 意见保留，非必要 |

-   [x] 主界面
    -   [ ] 示波器
        -   [x] 用有序Map维护最大最小值
        -   [x] *长按示波器窗口可以添加要显示的数据* - 这项功能改为了下滑菜单
            -   [x] 可以选择显示来自不同设备的不同数据
        -   [x] 完成示波器列表显示及按钮添加新的示波器
        -   [x] 完成WiFi模块的数据传输
        -   [ ] 将WiFi模块连接信息返回给单片机 - 迟早要做
        -   [ ] 将被动式接收改为主动发送请求 - **!**
            -   [ ] 可以请求数据列表
            -   [ ] 可以修改发送时间间隔 - **?**
        -   [ ] 根据需要显示的数据传输数据 - **?**
        -   [ ] 加入PID调参功能 - **?**
    -   [ ] 串口助手
        -   [ ] 实现其他功能的接收内容捕获
    -   [ ] 设备管理
        -   [x] 设备添加Dialog
        -   [ ] 设备栏
        -   [ ] 设备栏/设备盒子
            -   [x] 设备列表功能实现 - **!**
            -   [x] 设备绑定连接功能实现 - **!**
            -   [ ] 把ESP8266的网络看门狗写好，不然这边解绑会有BUG - **！**
            -   [x] 设备连接/断开操作逻辑
            -   [x] 解决UDP接收实例删不掉的问题 - 减短了Duration时间，延迟10秒后关闭
            -   [ ] 通过开关控制主动搜索设备
            -   [ ] 给每个设备标记是否已绑定设备 - **?**
            -   [ ] 点击连接后的动画过渡 - **?**
            -   [ ] 使设备盒子可以删除 - **?**

# 开发日志

### 2022.4.21 完成示波器基本功能

![image-20220421010234429](https://ferost-myphotos.oss-cn-shenzhen.aliyuncs.com/202204210107244.png)

效果可以说是非常的amazing啊，现在可以选择显示来自不同设备的不同数据。

### 2022.4.7 完成设备连接功能

![image-20220407231351535](https://ferost-myphotos.oss-cn-shenzhen.aliyuncs.com/202204072314392.png)

虽然还有些BUG，但是基本的连接功能实现了

### 2022.4.2 开始项目转移

创建了新的`mcuassitant`文件夹，用来存放调试助手项目代码

添加开发计划栏，用于管理项目中萌生的各种想法（在开发过程中有太多想实现的功能了，其中一些功能开发难度大且是非必要的，拖慢了开发进度。现在用开发计划来管理自己投入这些非必要功能的时间。

重新完善了一些设备盒子的界面，现在代码可读性更高了。

![image-20220402205807496](https://ferost-myphotos.oss-cn-shenzhen.aliyuncs.com/202204072314394.png)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
