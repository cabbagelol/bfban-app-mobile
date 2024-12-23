![](https://bfban-app.cabbagelol.net/images/github.app.bigpicture.v2.png)

## Bfban 助手

![GitHub closed issues](https://img.shields.io/github/issues-closed/cabbagelol/bfban-app-mobile)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/cabbagelol/bfban-app-mobile)
![pub package](https://img.shields.io/badge/ios-yes-green)
![pub package](https://img.shields.io/badge/desktop_ios-yes-green)
![pub package](https://img.shields.io/badge/android-yes-green)

由Cabbagelol负责维护的联Ban移动设备应用，完成对移动设备快速举报功能，改进在移动设备展示效果。关于隐私问题具体可查看源代码检查应用是否作出此类行为。

[下载(android and ios)](https://bfban-app.cabbagelol.net) |
[开发计划进展](https://trello.com/b/ZECQnnEz/bfban-app) |
[联Ban网站](https://bfban.com) |
[应用网站](http://bfban-app.cabbagelol.net) |
[App网站仓库](https://github.com/hll-gun-calculator/website)

## 介绍

Bfban应用由dart编写，借助Flutter生态实现跨平台应用，运行在Android和ios以及桌面应用环境；应用主要提供BFBAN.com在移动设备合适界面，接壤客户端本地图像识别、举报素材管理、预览记录等功能。

现在此项目以bfban助手在applestore与googleplay上线，你可以点击上方下载android/and/ios链接前往各大商店。

## 开发

额外依赖：

* [flutter_plugin_elui](https://github.com/cabbagelol/flutter-elui-plugin) [<=1.8]:
* [flutter_plugin_plus_elui](https://github.com/ElementUserInterface/flutter-elui-plus-plugin) [>=3.0]:
* [flutter_rich_html](https://github.com/cabbagelol/rich_html-d20822):

## 截图

![](https://github.com/cabbagelol/bfban-app-website/blob/main/images/screenshots.png?raw=true)

## 运行

具体看main.example.dart的例子来创建环境启动，如:

```shell
   # 生产环境
   flutter run (android or ios) ./main.prod.dart

   # 开发环境   
   flutter run (android or ios) ./main.dev.dart
```

## 构建

### 1. 默认打包

```shell
   flutter build --release ./lib/main.prod.dart --build-name 0.0.1 --build-number 1
```

### 2. 使用Distribute(v2)

    使用ide内置的终端来配置使用

基于Distribute编写的shell脚本,运行后依照提示选择打包

    - 简单化，自动计算版本
    - 需要将此脚本的工作目录设置为/,而不是/script/里运行

```shell   
  sh ./script/build-v2.sh
```

### 3. 使用sh脚本(v1)

    使用ide内置的终端来配置使用

注意此方法打包，需要修改'pubspec.yaml'
内的'version'
值，将0.0.1+1改为0.0.1,
再由脚本提示输入build-number

```shell
 sh ./script/build-v1.sh
```

## 分支介绍

| 分支名称   |                |
|--------|----------------|
| master | 主要发行版本         |
| weex   | weex旧方案实现(未完成) |

# 捐助

此捐助是用于app开发者费用，Apple与Google总计￥853.69:

感谢所有捐助者，排名不分前后;可以在3个月内申请退款，请附上支付时间，订单、渠道，联系app@bfban.com

| Name    |        |
|---------|--------|
| Super水神 | ￥22.33 
| 松雪柚咲    | ￥80    
| 三好学生于水水 | ￥30    
| 月夜      | ￥1000  