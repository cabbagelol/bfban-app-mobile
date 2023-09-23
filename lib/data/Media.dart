import 'dart:io';

import 'package:bfban/data/Sort.dart';

import '../utils/index.dart';

enum MediaType { Local, Network }

class MediaList {
  List<MediaFileLocalData> localList = [];
  List<MediaFileNetworkData> networkList = [];

  MediaList({
    required this.localList,
    required this.networkList,
  });
}

class MediaWrite {
  List list = [];

  BaseSort sort = BaseSort();

  /// 赋值
  void setList(List fileList, MediaType type) {
    switch (type) {
      case MediaType.Local:
        list.clear();
        break;
      case MediaType.Network:
        list.clear();
        break;
    }
    _add(fileList, type);
  }

  void setListSort() {
    _sort();
  }

  /// 追加
  /// 适用下拉加载
  void addList(List fileList, MediaType type) {
    _add(fileList, type);
    _sort();
  }

  /// 排序
  _sort() {
    list.sort((a, b) {
      int aTime = DateTime.parse(a.createTime.toString()).millisecondsSinceEpoch;
      int bTime = DateTime.parse(b.createTime.toString()).millisecondsSinceEpoch;

      switch (sort.order) {
        case OrderType.asc:
          return aTime < bTime ? 1 : -1;
        case OrderType.desc:
        default:
          return aTime > bTime ? 1 : -1;
      }
    });
  }

  _add(List fileList, MediaType type) {
    for (var i in fileList) {
      switch (type) {
        case MediaType.Local:
          MediaFileLocalData mfld = MediaFileLocalData();
          // local is File;
          mfld.file = i;
          list.add(mfld);
          break;
        case MediaType.Network:
          MediaFileNetworkData mfnd = MediaFileNetworkData();
          // network is Map
          mfnd.setData(i);
          list.add(mfnd);
          break;
      }
    }
  }
}

/// 本地媒体
class MediaStatus extends MediaWrite {
  bool? load;

  @override
  List list;

  MediaStatus({
    this.load,
    required this.list,
  });
}

class BaseMediaFileData {
  File? _file;

  set file(File value) {
    _file = value;
  }

  File get file => _file!;

  get extension {
    if (_file == null) return FileManagementType.NONE;
    return FileManagement().checkFileExtension(_file!.path);
  }

  get url => _file!.path;

  get name => _file!.path;
}

/// 本地文件Data
class MediaFileLocalData extends BaseMediaFileData {
  final MediaType type = MediaType.Local;

  // 本地上传状态
  bool upload = false;

  // 已上传标记
  String upLoadedName = "[Uploaded]";

  FileManagement fileManagement = FileManagement();

  // 仅本地
  // 是否已上传过
  bool get isUploaded {
    return _file!.path.contains(upLoadedName);
  }

  get createTime {
    return _file!.statSync().changed;
  }

  String get filename {
    return (fileManagement.splitFileUrl(_file!.path)["fileName"] as String).replaceAll(upLoadedName, "");
  }

  String get fileExtension {
    return fileManagement.splitFileUrl(_file!.path)["fileExtension"] as String;
  }
}

/// 网络文件Data
class MediaFileNetworkData extends BaseMediaFileData {
  final MediaType type = MediaType.Network;

  // 远程获取文件信息状态
  bool fileDetailLoad = false;

  String? createTime;
  String? filename;
  num? id;
  num? size;

  MediaFileNetworkData({
    this.createTime,
    this.filename,
    this.id,
    this.size,
  });

  setData(Map map) {
    createTime = map["createTime"];
    filename = map["filename"];
    id = map["id"];
    size = map["size"];
    return toMap;
  }

  get fileExtension {
    List splitArray = filename!.split("/");
    List f = splitArray.last.toString().split(".");
    return f[1];
  }

  get toMap {
    return {
      "createTime": createTime,
      "filename": filename,
      "id": id,
      "size": size,
    };
  }
}
