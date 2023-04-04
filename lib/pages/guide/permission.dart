import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:permission_handler/permission_handler.dart';

class GuidePermissionPage extends StatefulWidget {
  final Function? onChange;

  const GuidePermissionPage({
    Key? key,
    this.onChange,
  }) : super(key: key);

  @override
  _PermissionPageState createState() => _PermissionPageState();
}

class _PermissionPageState extends State<GuidePermissionPage> with AutomaticKeepAliveClientMixin {
  List<Permission> permissions = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    switch (Platform.operatingSystem) {
      case "ios":
      case "macos":
        permissions = [
          Permission.storage,
          Permission.notification,
        ];
        break;
      case "android":
        permissions = [
          Permission.camera,
          Permission.photos,
          Permission.storage,
          Permission.notification,
        ];
        break;
    }

    _getQueryPermanentlyState();
  }

  /// 查询权限结果
  void _getQueryPermanentlyState() {
    for (var permission in permissions) {
      // print(permission.value);
      // TODO
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                FlutterI18n.translate(context, "app.guide.permission.title"),
                style: const TextStyle(fontSize: 25),
              ),
              Text(
                FlutterI18n.translate(context, "app.guide.permission.label"),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        Column(
          children: permissions.map((permission) => PermissionWidget(permission)).toList(),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Text.rich(
            TextSpan(
              children: [
                const WidgetSpan(
                  child: Icon(
                    Icons.warning,
                    size: 16,
                    color: Colors.yellow,
                  ),
                ),
                WidgetSpan(
                  child: Text(
                    FlutterI18n.translate(context, "app.guide.permission.tip"),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.yellow,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PermissionWidget extends StatefulWidget {
  final Permission _permission;

  final Function? onChange;

  const PermissionWidget(
    this._permission, {
    Key? key,
    this.onChange,
  }) : super(key: key);

  @override
  _PermissionState createState() => _PermissionState(_permission);
}

class _PermissionState extends State<PermissionWidget> {
  _PermissionState(this._permission);

  Map permissionName = {
    Permission.camera: {
      "name": "app.guide.permission.list.0.name",
      "describe": "app.guide.permission.list.0.describe",
    },
    Permission.photos: {
      "name": "app.guide.permission.list.1.name",
      "describe": "app.guide.permission.list.1.describe",
    },
    Permission.storage: {
      "name": "app.guide.permission.list.2.name",
      "describe": "app.guide.permission.list.2.describe",
    },
    Permission.notification: {
      "name": "app.guide.permission.list.3.name",
      "describe": "app.guide.permission.list.3.describe",
    },
  };

  Map permissionStatus = {
    PermissionStatus.granted: {
      "text": "app.guide.permission.status.0",
      "icon": Icons.check_circle,
    },
    PermissionStatus.values: {
      "text": "app.guide.permission.status.-1",
      "icon": Icons.remove_circle,
    },
    PermissionStatus.denied: {
      "text": "app.guide.permission.status.1",
      "icon": Icons.warning,
    },
    PermissionStatus.permanentlyDenied: {
      "text": "app.guide.permission.status.2",
      "icon": Icons.error,
    },
    PermissionStatus.restricted: {
      "text": "app.guide.permission.status.3",
      "icon": Icons.info,
    },
  };

  final Permission _permission;

  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }

  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return Colors.yellow;
      case PermissionStatus.granted:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return EluiCellComponent(
      icons: GestureDetector(
        child: Icon(
          permissionStatus[_permissionStatus]["icon"],
          color: getPermissionColor(),
        ),
      ),
      theme: EluiCellTheme(
        titleColor: Theme.of(context).textTheme.subtitle1?.color,
        labelColor: Theme.of(context).textTheme.subtitle2?.color,
        linkColor: Theme.of(context).textTheme.subtitle1?.color,
        backgroundColor: Theme.of(context).cardTheme.color,
      ),
      title: "${FlutterI18n.translate(context, permissionName[_permission]["name"])} - ${FlutterI18n.translate(context, permissionStatus[_permissionStatus]["text"])}",
      label: FlutterI18n.translate(context, permissionName[_permission]["describe"]),
      onTap: () {
        requestPermission(_permission);
      },
    );
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      _permissionStatus = status;
    });
  }
}
