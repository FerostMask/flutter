# MCUAssitant

MCU调试助手

# 开发计划

| 符号 | !                                | ?                |
| ---- | -------------------------------- | ---------------- |
| 含义 | 重要内容，没有它功能无法正常使用 | 意见保留，非必要 |

-   [x] 主界面
    -   [ ] 示波器
        -   [ ] 用有序set维护最大最小值
    -   [ ] 串口助手
        -   [ ] 实现其他功能的接收内容捕获
    -   [ ] 设备管理
        -   [x] 设备添加Dialog
        -   [ ] 设备栏
        -   [ ] 设备栏/设备盒子
            -   [ ] 设备列表功能实现 - **!**
            -   [ ] 设备绑定连接功能实现 - **!**
            -   [ ] 设备连接/断开操作逻辑
            -   [ ] 点击连接后的动画过渡 - **?**

# 开发日志

### 2022.4.2 开始项目转移

创建了新的`mcuassitant`文件夹，用来存放调试助手项目代码

添加开发计划栏，用于管理项目中萌生的各种想法（在开发过程中有太多想实现的功能了，其中一些功能开发难度大且是非必要的，拖慢了开发进度。现在用开发计划来管理自己投入这些非必要功能的时间。

重新完善了一些设备盒子的界面，现在代码可读性更高了。

![image-20220402205807496](C:\Users\Szasd\AppData\Roaming\Typora\typora-user-images\image-20220402205807496.png)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
