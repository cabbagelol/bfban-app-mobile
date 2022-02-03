import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_translate/flutter_translate.dart';

import 'package:permission_handler/permission_handler.dart';


class GuidePermissionPage extends StatefulWidget {
  final Function? onChange;

  const GuidePermissionPage({
    Key? key,
    this.onChange,
  }) : super(key: key);

  @override
  _permissionPageState createState() => _permissionPageState();
}

class _permissionPageState extends State<GuidePermissionPage> {
  List<Permission> permissions = [
    Permission.camera,
    Permission.photos,
    Permission.storage,
    Permission.notification,
  ];

  @override
  void initState() {
    super.initState();

    _getQueryPermanentlyState();
  }

  /// 查询权限结果
  void _getQueryPermanentlyState() {
    for (var permission in permissions) {
      print(Permission);
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
                translate("guide.permission.title"),
                style: const TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
              Text(
                translate("guide.permission.label"),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
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
          child: Wrap(
            spacing: 10,
            children: <Widget>[
              const Icon(
                Icons.warning,
                size: 16,
                color: Colors.yellow,
              ),
              Text(
                translate("guide.permission.tip"),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.yellow,
                ),
              ),
            ],
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
      "name": translate("guide.permission.list.0.name"),
      "describe": translate("guide.permission.list.0.describe"),
    },
    Permission.photos: {
      "name": translate("guide.permission.list.1.name"),
      "describe": translate("guide.permission.list.1.describe"),
    },
    Permission.storage: {
      "name": translate("guide.permission.list.2.name"),
      "describe": translate("guide.permission.list.2.describe"),
    },

    Permission.notification: {
      "name": translate("guide.permission.list.3.name"),
      "describe": translate("guide.permission.list.3.describe"),
    },
  };

  Map permissionStatus = {
    PermissionStatus.granted: {
      "text": translate("guide.permission.status.0"),
      "icon": Icons.check_circle,
    },
    PermissionStatus.values: {
      "text": translate("guide.permission.status.-1"),
      "icon": Icons.remove_circle,
    },
    PermissionStatus.denied: {
      "text": translate("guide.permission.status.1"),
      "icon": Icons.warning,
    },
    PermissionStatus.permanentlyDenied: {
      "text": translate("guide.permission.status.2"),
      "icon": Icons.error,
    },
    PermissionStatus.restricted: {
      "text": translate("guide.permission.status.3"),
      "icon": Icons.info,
    },
  };

  final Permission _permission;

  PermissionStatus _permissionStatus = PermissionStatus.denied;

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
        return Colors.red;
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
        backgroundColor: Colors.black12,
      ),
      title: "${permissionName[_permission]["name"]} - ${permissionStatus[_permissionStatus]["text"]}",
      label: permissionName[_permission]["describe"],
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
