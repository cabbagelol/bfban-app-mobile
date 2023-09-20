import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/index.dart';

class DirProvider with ChangeNotifier {
  String NAME = "dir";

  Storage storage = Storage();

  // 应用内部完整地址
  Directory? appExtDir;

  FileAllPath fileAllPath = FileAllPath();

  // 所有用户配置列表
  List<DirItemStorePath> paths = [];

  // 默认选择保存位置
  String defaultSavePathValue = "";

  // 是否支持dir，不提供则关闭保存一类功能
  bool isSupportDirectory() => paths.isNotEmpty;

  // 获取默认选择保存的完整地址
  get currentDefaultSavePath => getPaths().where((element) => element.dirName == defaultSavePathValue).first.basicPath;

  init() async {
    try {
      List<Future> waitMode = [];
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) waitMode.insert(0, getApplicationSupportDirectory());
      if (Platform.isAndroid) waitMode.insert(1, getExternalStorageDirectories());
      if (Platform.isAndroid) waitMode.insert(2, getDownloadsDirectory());

      List futurePath = await Future.wait(waitMode);

      fileAllPath = FileAllPath(
        applicationSupportDirectory: futurePath[0],
        externalCacheDirectories: [],
        downloadsDirectory: Directory(""),
        applicationDocumentsDirectory: Directory(""),
      );

      if (Platform.isAndroid) fileAllPath.externalCacheDirectories = futurePath[1];
      if (Platform.isAndroid) fileAllPath.downloadsDirectory = futurePath[2];

      _initDirectory();

      if (defaultSavePathValue.isEmpty) defaultSavePathValue = "appInteriorDir";

      Map configuration = await getSaveDirPath();
      paths = getPaths();
      if (configuration["configuration"].length > 0) {
        for (DirItemStorePath i in saveDirPathToMapAsDirItemStorePath(configuration["configuration"])) {
          paths[paths.indexWhere((element) => element.dirName == i.dirName)] = i;
        }
      }

      notifyListeners();
    } finally {}
    return true;
  }

  // 列出可使用存储位置
  List<DirItemStorePath> getPaths() {
    List<DirItemStorePath> list = [];
    if (fileAllPath.applicationSupportDirectory!.existsSync()) {
      list.add(DirItemStorePath(
        dirName: "appInteriorDir",
        check: true,
        basicPath: fileAllPath.applicationSupportDirectory!.path,
      ));
    }
    if (fileAllPath.downloadsDirectory!.existsSync()) {
      list.add(DirItemStorePath(
        dirName: "downloadsDirectory",
        basicPath: fileAllPath.downloadsDirectory!.path,
      ));
    }
    if (fileAllPath.externalCacheDirectories!.isNotEmpty) {
      for (var externalDir in fileAllPath.externalCacheDirectories!.indexed) {
        if (!externalDir.$2.existsSync())
          // ignore: curly_braces_in_flow_control_structures
          list.add(DirItemStorePath(
            dirName: "external${externalDir.$1}",
            basicPath: externalDir.$2.path,
          ));
      }
    }
    paths = list;
    return list;
  }

  // 扫描用户配置目录，读取文件列表
  Future<List> getAllFile({String laterPath = "/media"}) async {
    dynamic localData = await getSaveDirPath();
    List readLocalPath = saveDirPathToMapAsDirItemStorePath(List.from(localData["configuration"]).where((element) => element["check"]).toList());
    List fileList = [];

    if (!isSupportDirectory()) return [];

    for (DirItemStorePath i in (readLocalPath.isEmpty ? paths : readLocalPath)) {
      if (i.check! == false) continue;

      Directory directory = Directory(i.basicPath + laterPath);
      directory.createSync(recursive: true);
      List files = directory.listSync(recursive: true);
      fileList.addAll(files ??= []);
    }
    return fileList;
  }

  // 保存目录位置
  setSaveDirPath(List<DirItemStorePath> paths) {
    Map value = {
      "defaultSavePathValue": defaultSavePathValue,
      "configuration": paths.map((key) => key.toMap).where((element) => element["check"]).toList(),
    };
    storage.set(NAME, value: value);
  }

  // 读取目录位置
  Future<Map> getSaveDirPath() async {
    StorageData filesData = await storage.get(NAME);
    if (filesData.code != 0) return {"configuration": []};
    return filesData.value;
  }

  // 读取目录位置 转换对象
  List<DirItemStorePath> saveDirPathToMapAsDirItemStorePath(List<dynamic> files) {
    List<DirItemStorePath> readLocalPathAsDirItemStorePath = [];
    for (Map i in files) {
      readLocalPathAsDirItemStorePath.add(DirItemStorePath(
        dirName: i["dirName"],
        basicPath: i["basicPath"],
        check: i["check"],
      ));
    }
    return readLocalPathAsDirItemStorePath;
  }

  // 初始目录
  _initDirectory() async {
    const allAppDir = ['/media', '/logs'];

    if (fileAllPath.applicationSupportDirectory!.existsSync())
      // ignore: curly_braces_in_flow_control_structures
      for (var path in allAppDir) {
        String fullPath = '${fileAllPath.applicationSupportDirectory!.path}$path';
        if (!Directory(fullPath).existsSync()) {
          Directory(fullPath).createSync(recursive: true);
        }
      }

    return true;
  }
}

class DirBasicItem {
  // 是否使用
  bool? check = false;

  // 基本地址
  String basicPath = "";

  DirBasicItem({
    this.check,
    required this.basicPath,
  });
}

class DirItemStorePath extends DirBasicItem {
  // 空间名称
  String dirName = "";

  DirItemStorePath({
    required this.dirName,
    bool check = false,
    required String basicPath,
  }) : super(check: check, basicPath: basicPath);

  Map<String, dynamic> get toMap => {
        "dirName": dirName,
        "check": check,
        "basicPath": basicPath,
      };
}

class FileAllPath {
  // 应用支持目录
  Directory? applicationSupportDirectory;

  // 外部存储目录 所有
  List<Directory>? externalCacheDirectories;

  // 下载目录
  Directory? downloadsDirectory;

  Directory? applicationDocumentsDirectory;

  FileAllPath({
    this.applicationSupportDirectory,
    this.externalCacheDirectories,
    this.downloadsDirectory,
    this.applicationDocumentsDirectory,
  });
}

class FileStorePath {}
