![](public/images/github.logo.jpg)

## Bfban应用

![GitHub release (latest by date)](https://img.shields.io/github/v/release/cabbagelol/bfbanApp)
![pub package](https://img.shields.io/badge/ios-no-green)
![pub package](https://img.shields.io/badge/android-yes-green)
![GitHub All Releases](https://img.shields.io/github/downloads/cabbagelol/bfbanApp/total)

由Cabbagelol负责维护的联Ban移动设备应用，完成对移动设备快速举报功能，改进在移动设备展示效果。该应用并`非官方`，关于隐私问题具体可查看源代码检查应用是否作出此类行为。

[Android和ios下载](https://github.com/cabbagelol/bfbanApp/releases)
| [开发计划进展](https://trello.com/b/ZECQnnEz/bfban-app) |
[联Ban网站](https://bfban.com) |
[应用网站](http://app.bfban.com/public/www) |
[BFBANApp交流群(612949946)](https://jq.qq.com/?_wv=1027&k=kXr9z9FE)


## 介绍

> Bfban应用借助FlutterUI库混合原生实现跨平台，可发布android和ios以及桌面应用

额外依赖：

- flutter_plugin_elui: https://github.com/cabbagelol/flutter-elui-plugin
- flutter_rich_html: https://github.com/cabbagelol/rich_html-d20822

 部署android：
1. android部分仅保留部分资源文件，构建本地android项目需要先"flutter create
   kotlin ."，再导入克隆项目内的android文件。
2. 编码模式含'armeabi', 'x86', 'armeabi-v7a', 'x86_64',
   'arm64-v8a'NDK，缺少文件到官网下载完整的NDK。
3. 库里的gradle版本是6.1.1/kotlin:1.3.72，如果和本地不同，请自行修改。
4. 入口是main_dev不是main。

部署ios: (未确认，自行构建)
1. 通过"flutter create ios ."创建:D，资源在andorid项目取。
2. 在Info.plist添加网络、文件储存权限。
3. 包名com.cabbagelol.bfban, 由于目前还没确认，随便配吧， 对吧~


## 分支介绍

- master 主要发行版本
- weex 旧方案实现(未完成)

