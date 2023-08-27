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
[App网站仓库](https://github.com/cabbagelol/bfbanAppWebsite)

## 👋 介绍

> Bfban应用由dart编写，借助Flutter生态实现跨平台应用，运行在Android和ios以及桌面应用环境；应用主要提供BFBAN.com在移动设备合适界面，接壤客户端本地图像识别、举报素材管理、预览记录等功能。

现在此项目以"bfban助手"在apple store与google play上线，你可以点击上方[下载(android and ios)]链接前往各大商店。

## 💁 常见应用问题

#### Q: 使用BFBAN APP登录账户为何网页版账户掉线？

bfban不支持多平台登录，使用app登录账户将重置凭证，导致其他平台失效

(重要) 在8月20日BFBAN已支持多端，应用也在0.2.6之后做适配

#### Q: BFBAN助手会不会盗窃我资料或泄露我隐私？

不会，BFBAN助手没有自己任何服务器、也不会劫持任何数据，bfban账户由bfban.com本身内部处理， BFBAN助手仅在本地处理数据提交到bfban服务中，但BFBAN助手会收集个别特征，这些用于应用分析，你可以查看隐私协议披露的服务

#### Q: 卸载APP会导致媒体库的文件删除么

是的

#### Q: BFBAN助手和BFBAN什么关系？

由BFBAN开源组织成员开发应用，发布版本目前属于个人，但它的代码开源，任何人可以参与或克隆

#### Q: 没看到数据列表以及界面不显示语言

请先检查手机网络状态，打开网络； 仍然无法解决请尝试在系统设置中打开应用详情，检查app权限是否放行网络(注意放行是仅流量还是流量或wifi); 仍然无法解决，请尝试打开应用，在主界面点击'我'>'支援'>'初始引导'，在权限放行所有权限，完成后再前往'我'>'清理'删除所有持久保存内容，重启应用。

## 开发

额外依赖：

- flutter_plugin_elui: https://github.com/cabbagelol/flutter-elui-plugin
- flutter_rich_html: https://github.com/cabbagelol/rich_html-d20822

(内置app相关配置接口来源)

- app网站: https://github.com/cabbagelol/bfbanAppWebsite

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