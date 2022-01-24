import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/_cell/cell.dart';

import 'package:permission_handler/permission_handler.dart';


class permissionPage extends StatefulWidget {
  final Function? onChange;

  const permissionPage({
    Key? key,
    this.onChange,
  }) : super(key: key);

  @override
  _permissionPageState createState() => _permissionPageState();
}

class _permissionPageState extends State<permissionPage> {
  List<Permission> permissions = [
    Permission.camera,
    Permission.photos,
    Permission.storage,
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
            children: const <Widget>[
              Text(
                "权限",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
              Text(
                "请触摸下方单元，授权权限给予应用。并非强制要求",
                style: TextStyle(
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
            children: const <Widget>[
              Icon(
                Icons.warning,
                size: 16,
                color: Colors.yellow,
              ),
              Text(
                "如果存在【永久拒绝】选项，可以到设置》应用》权限修改",
                style: TextStyle(
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
      "name": "摄像头",
      "describe": "主要用于拍摄或录制多媒体，媒体内容多为证据为主。",
    },
    Permission.photos: {
      "name": "相册",
      "describe": "读取相册内容，用途证据为主",
    },
    Permission.storage: {
      "name": "本地储存",
      "describe": "授权应用储存用户数据，其中包含登录信息以及草稿箱。",
    },
  };

  Map permissionStatus = {
    PermissionStatus.granted: {
      "text": "授权成功",
      "icon": Icons.check_circle,
    },
    PermissionStatus.values: {
      "text": "未知",
      "icon": Icons.remove_circle,
    },
    PermissionStatus.denied: {
      "text": "未授权",
      "icon": Icons.warning,
    },
    PermissionStatus.permanentlyDenied: {
      "text": "永久拒绝",
      "icon": Icons.error,
    },
    PermissionStatus.restricted: {
      "text": "受限制",
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
