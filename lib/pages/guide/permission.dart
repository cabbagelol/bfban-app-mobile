import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:permission_handler/permission_handler.dart';

class GuidePermissionPage extends StatefulWidget {
  final Function? onChange;

  const GuidePermissionPage({
    super.key,
    this.onChange,
  });

  @override
  PermissionPageState createState() => PermissionPageState();
}

class PermissionPageState extends State<GuidePermissionPage> with AutomaticKeepAliveClientMixin {
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
          Permission.camera,
          Permission.photos,
          Permission.storage,
          Permission.notification,
        ];
        break;
      case "android":
        permissions = [
          Permission.camera,
          Permission.storage,
          Permission.videos,
          Permission.photos,
          Permission.notification,
        ];
        break;
      default:
        permissions = [];
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning,
                size: 16,
                color: Colors.yellow,
              ),
              const SizedBox(width: 10),
              Flexible(
                flex: 1,
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
    Permission.manageExternalStorage: {
      "name": "app.guide.permission.list.manageExternalStorage.name",
      "describe": "app.guide.permission.list.manageExternalStorage.describe",
      "shouldShowRequestRationale": false,
    },
    Permission.camera: {
      "name": "app.guide.permission.list.camera.name",
      "describe": "app.guide.permission.list.camera.describe",
      "shouldShowRequestRationale": false,
    },
    Permission.audio: {
      "name": "app.guide.permission.list.audio.name",
      "describe": "app.guide.permission.list.audio.describe",
      "shouldShowRequestRationale": false,
    },
    Permission.photos: {
      "name": "app.guide.permission.list.photos.name",
      "describe": "app.guide.permission.list.photos.describe",
      "shouldShowRequestRationale": false,
    },
    Permission.storage: {
      "name": "app.guide.permission.list.storage.name",
      "describe": "app.guide.permission.list.storage.describe",
      "shouldShowRequestRationale": false,
    },
    Permission.videos: {
      "name": "app.guide.permission.list.videos.name",
      "describe": "app.guide.permission.list.videos.describe",
      "shouldShowRequestRationale": false,
    },
    Permission.notification: {
      "name": "app.guide.permission.list.notification.name",
      "describe": "app.guide.permission.list.notification.describe",
      "shouldShowRequestRationale": false,
    },
  };

  Map permissionStatus = {
    PermissionStatus.granted: {
      "text": "app.guide.permission.status.0",
      "icon": Icons.check_circle,
    },
    PermissionStatus.limited: {
      "text": "app.guide.permission.status.0",
      "icon": Icons.check_circle_outline,
    },
    PermissionStatus.denied: {
      "text": "app.guide.permission.status.1",
      "icon": Icons.remove_circle,
    },
    PermissionStatus.permanentlyDenied: {
      "text": "app.guide.permission.status.2",
      "icon": Icons.cancel,
    },
    PermissionStatus.restricted: {
      "text": "app.guide.permission.status.3",
      "icon": Icons.info,
    },
    PermissionStatus.provisional: {
      "text": "app.guide.permission.status.-1",
      "icon": Icons.help_outline,
    },
  };

  final Permission _permission;

  PermissionStatus _permissionStatus = PermissionStatus.denied;

  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _shouldShowRequestRationale(widget._permission);
    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    if (mounted) {
      setState(() => _permissionStatus = status);
    }
  }

  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
      case PermissionStatus.denied:
        return Theme.of(context).colorScheme.error;
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _shouldShowRequestRationale(Permission permission) async {
    if (permissionName.containsKey(_permission)) {
      permissionName[_permission]['shouldShowRequestRationale'] = await permission.shouldShowRequestRationale;
    }
  }

  Map<String, dynamic> _getStatusConfig(PermissionStatus status) {
    if (permissionStatus.containsKey(status) && permissionStatus[status] is Map) {
      return Map<String, dynamic>.from(permissionStatus[status] as Map);
    }
    return {
      "text": "app.guide.permission.status.-1",
      "icon": Icons.help_outline,
    };
  }

  Map<String, dynamic> _getNameConfig(Permission permission) {
    if (permissionName.containsKey(permission) && permissionName[permission] is Map) {
      return Map<String, dynamic>.from(permissionName[permission] as Map);
    }
    return {
      "name": "app.guide.permission.title",
      "describe": "",
      "shouldShowRequestRationale": false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusConf = _getStatusConfig(_permissionStatus);
    final nameConf = _getNameConfig(_permission);

    return Column(
      children: [
        const Divider(height: 1),
        EluiCellComponent(
          icons: GestureDetector(
            child: Icon(
              statusConf["icon"] as IconData,
              color: getPermissionColor(),
            ),
          ),
          theme: EluiCellTheme(
            titleColor: Theme.of(context).textTheme.titleMedium?.color,
            labelColor: Theme.of(context).textTheme.displayMedium?.color,
            linkColor: Theme.of(context).textTheme.displayMedium?.color,
            backgroundColor: Theme.of(context).cardTheme.color,
          ),
          title: "${FlutterI18n.translate(context, nameConf["name"].toString())} - ${FlutterI18n.translate(context, statusConf["text"].toString())}",
          label: FlutterI18n.translate(context, nameConf["describe"].toString()),
          onTap: () {
            requestPermission(_permission);
          },
        ),
      ],
    );
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      _permissionStatus = status;
    });
  }
}
