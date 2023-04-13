![](https://bfban-app.cabbagelol.net/images/github.app.bigpicture.jpg)

## Bfban应用

![GitHub closed issues](https://img.shields.io/github/issues-closed/cabbagelol/bfbanApp)
![GitHub Sponsors](https://img.shields.io/github/sponsors/cabbagelol)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/cabbagelol/bfbanApp)
![pub package](https://img.shields.io/badge/ios-no-green)
![pub package](https://img.shields.io/badge/android-yes-green)
![GitHub All Releases](https://img.shields.io/github/downloads/cabbagelol/bfbanApp/total)

由Cabbagelol负责维护的联Ban移动设备应用，完成对移动设备快速举报功能，改进在移动设备展示效果。关于隐私问题具体可查看源代码检查应用是否作出此类行为。

[Android和ios下载](https://github.com/cabbagelol/bfbanApp/releases)
| [开发计划进展](https://trello.com/b/ZECQnnEz/bfban-app) |
[联Ban网站](https://bfban.com) |
[应用网站](http://bfban-app.cabbagelol.net) |
[App网站仓库](https://github.com/cabbagelol/bfbanAppWebsite) |
[BFBANApp交流群(612949946)](https://jq.qq.com/?_wv=1027&k=kXr9z9FE)

避免在第三方模拟器中使用，它可能导致某些内置Api无法使用。关于此问题继续追踪修复方案。


## 介绍

> Bfban应用借助FlutterUI库混合原生实现跨平台，可发布android和ios以及桌面应用, 由于目前ios经费不足，不上线ios版本，请通过官方渠道捐助bfban，并注明为bfban app的ios经费捐助。

额外依赖：

- flutter_plugin_elui: https://github.com/cabbagelol/flutter-elui-plugin
- flutter_rich_html: https://github.com/cabbagelol/rich_html-d20822

(内置app相关配置接口来源)
- app网站: https://github.com/cabbagelol/bfbanAppWebsite

 部署android：
1. android部分仅保留部分资源文件，构建本地android项目需要先"flutter create
   kotlin ."，再导入克隆项目内的android文件。
2. 签名自己生成(需配置key.properties),在android/app/keystore

部署ios: (未确认，自行构建)
1. 通过"flutter create ios ."创建:D，资源在andorid项目取。
2. 在Info.plist添加网络、文件储存权限。
3. 包名com.cabbagelol.bfban, 由于目前还没确认，随便配吧， 对吧~

## 截图

![](https://github.com/cabbagelol/bfban-app-website/blob/main/images/screenshots.png?raw=true)

## 运行

具体看`main.example.dart`的例子来创建环境启动，如:

```
   // 生产环境
   flutter run (android or ios) ./main.prod.dart

   // 开发环境   
   flutter run (android or ios) ./main.dev.dart
```

## 构建

运行
```
   flutter build --release
```


## 分支介绍

- master 主要发行版本
- weex 旧方案实现(未完成)

# 捐助
此捐助是用于app开发者费用，Apple与Google总计￥853.69:

感谢所有捐助者，排名不分前后;
可以在3个月内申请退款，请附上支付时间，订单、渠道，联系app@bfban.com

- Super水神 ￥22.33
- 松雪柚咲 ￥80
- 三好学生于水水 ￥30
- 月夜 ￥1000