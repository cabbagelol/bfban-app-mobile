import 'dart:io';

import 'package:bfban/component/_empty/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../constants/api.dart';
import '../../data/index.dart';
import '../../utils/index.dart';
import '../../widgets/photo.dart';

class MediaPage extends StatefulWidget {
  bool? isSelectFile;

  MediaPage({
    Key? key,
    this.isSelectFile = false,
  }) : super(key: key);

  @override
  State<MediaPage> createState() => _mediaPageState();
}

class _mediaPageState extends State<MediaPage> {
  final UrlUtil _urlUtil = UrlUtil();

  TabController? _tabController;

  final GlobalKey<RefreshIndicatorState> _refreshLocalIndicatorKey = GlobalKey<RefreshIndicatorState>();

  final GlobalKey<RefreshIndicatorState> _refreshNetworkIndicatorKey = GlobalKey<RefreshIndicatorState>();

  final ScrollController _scrollNetworkController = ScrollController();

  MediaStatus mediaStatus = MediaStatus(
    load: false,
    list: [],
  );

  CloudMediaStatus cloudMediaStatus = CloudMediaStatus(
    load: false,
    list: [],
    parame: CloudMediaParame(
      skip: 0,
      limit: 15,
    ),
  );

  CloudMediaInfoStatus cloudMediaInfoStatus = CloudMediaInfoStatus(
    load: false,
    data: {},
  );

  List files = [];

  Map openFileDetail = {};

  @override
  void initState() {
    _getNetworkMediaInfo();
    _getLocalMediaFiles();
    _getNetworkMediaList();

    _scrollNetworkController.addListener(() {
      if (_scrollNetworkController.position.pixels == _scrollNetworkController.position.maxScrollExtent) {
        _getMore(MediaType.Network);
      }
    });

    super.initState();
  }

  /// [Result]
  /// 查询媒体库状态
  Future _getNetworkMediaInfo() async {
    Response result = await Http.request(
      Config.httpHost["service_myStorageQuota"],
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data;
      setState(() {
        cloudMediaInfoStatus.data = d["data"];
      });
    }
  }

  /// [Result]
  /// 查询媒体文件详情
  Future _getNetworkMediaDetail(MediaFileNetworkData i) async {
    if (mediaStatus.load!) return;

    setState(() {
      mediaStatus.load = true;
      i.fileDetailLoad = true;
    });

    Response result = await Upload().serviceFile(i.filename!);

    if (result.data["success"] == 1) {
      final d = result.data;
      setState(() {
        openFileDetail.addAll({d["data"]["filename"]: d["data"]});
        i.fileDetailLoad = false;
        mediaStatus.load = false;
      });
      return;
    }

    EluiMessageComponent.error(context)(
      child: Text(result.data["message"]),
    );

    setState(() {
      i.fileDetailLoad = false;
      mediaStatus.load = false;
    });
  }

  /// [Result]
  /// 从云端获取媒体列表
  Future _getNetworkMediaList() async {
    if (cloudMediaStatus.load!) return;

    setState(() {
      cloudMediaStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["service_myFiles"],
      parame: cloudMediaStatus.parame!.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data;
      setState(() {
        if (cloudMediaStatus.parame!.skip! <= 0) {
          cloudMediaStatus.setList(d["data"], MediaType.Network);
        } else {
          if (d["data"].length <= 0) return;

          cloudMediaStatus.addList(d["data"], MediaType.Network);
        }
      });
    }

    setState(() {
      cloudMediaStatus.load = false;
    });

    return cloudMediaStatus.list;
  }

  /// [Event]
  /// 获取本地媒体列表
  Future _getLocalMediaFiles() async {
    Directory extDir = await getApplicationSupportDirectory();
    List files = Directory('${extDir.path}/media').listSync(recursive: true);

    setState(() {
      mediaStatus.setList(files, MediaType.Local);
    });
  }

  /// [Event]
  /// 从公共相册导入APP文件
  importingFiles() async {
    final Directory extDir = await getApplicationSupportDirectory();
    final fileDir = await Directory('${extDir.path}/media').create(recursive: true);
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);

    if (image != null) await File(image!.path).copy("${fileDir.path}/${image.name}");
  }

  /// [Event]
  /// 删除本地文件
  Future _deleteLocalFile(File file) async {
    if (!await file.exists()) return;
    file.deleteSync();
    return true;
  }

  /// [Event]
  /// 打开拍摄
  void _openCamera() {
    _urlUtil.opEnPage(context, '/camera').then((res) {
      _getLocalMediaFiles();
    });
  }

  /// [Event]
  /// 选择文件
  /// 用于媒体选择，返回
  _onSelectFile(dynamic i) async {
    if (openFileDetail[i.filename] == null) {
      await _getNetworkMediaDetail(i);
    }

    if (openFileDetail[i.filename]["downloadURL"] != null) {
      Navigator.pop(context, openFileDetail[i.filename]["downloadURL"]);
    } else {
      EluiMessageComponent.warning(context)(child: const Text("No file information was obtained"));
    }
  }

  /// [Event]
  /// 查看文件详情信息
  void _onEnImageInfo(context, dynamic i) async {
    switch (i.type) {
      case MediaType.Local:
        if (i is! MediaFileLocalData) return;

        Widget widget = Container();
        if (!await i.file.exists() && i.extension == null) return;

        if (i.extension == FileType.IMAGE) {
          widget = PhotoViewSimpleScreen(
            imageUrl: i.file.path,
            imageProvider: FileImage(i.file),
            heroTag: 'simple',
          );
        }

        if (i.extension == FileType.VIDEO || i.extension == FileType.NONE) {
          widget = Scaffold(
            appBar: AppBar(
              title: Text(i.file.path),
            ),
            body: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Center(
                child: Text(
                  i.file.path,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (BuildContext context) {
              return widget;
            },
          ),
        );
        break;
      case MediaType.Network:
        if (i is! MediaFileNetworkData) return;

        if (openFileDetail[i.filename] == null) {
          await _getNetworkMediaDetail(i);
        }

        if (openFileDetail.isEmpty) return;
        if (openFileDetail[i.filename ?? ""]["downloadURL"] == null) return;

        Navigator.of(context).push(CupertinoPageRoute(
          builder: (BuildContext context) {
            return PhotoViewSimpleScreen(
              imageUrl: openFileDetail[i.filename]["downloadURL"],
              imageProvider: NetworkImage(openFileDetail[i.filename]["downloadURL"]),
              heroTag: "simple",
            );
          },
        ));
        break;
    }
  }

  /// [Event]
  /// 上传文件
  void _onUploadFile(context, i) async {
    setState(() {
      i.updataLoad = true;
    });

    Map result = await Upload().on(i.file);

    if (result["code"] == 1) {
      // 标记
      Map splitFileUrl = FileManagement().splitFileUrl(i.file.path);
      String newPath = "${i.file.parent.path}/${splitFileUrl["fileName"]}_[Uploaded].${splitFileUrl["fileExtension"]}";
      i.file.renameSync(newPath);

      EluiMessageComponent.success(context)(
        child: Text(result["message"]),
      );

      _getLocalMediaFiles();
      setState(() {
        i.updataLoad = false;
      });
      return;
    }

    setState(() {
      i.updataLoad = false;
    });

    EluiMessageComponent.error(context)(
      child: Text(result["message"]),
    );
  }

  /// [Event]
  /// 文件详情
  void _onEnFileInfo(BuildContext context, dynamic i) async {
    switch (i.type) {
      case MediaType.Local:
        if (i is! MediaFileLocalData) return;

        FileStat stat = await i.file.stat();

        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        SelectableText(i.file.path.toString()),
                        Text(stat.type.toString()),
                        Text("Size ${stat.size}"),
                        Text("Accessed ${stat.accessed}"),
                        Text("Modified ${stat.modified}"),
                        Text("Changed ${stat.changed}"),
                      ],
                    ),
                  ),
                ));
        break;
      case MediaType.Network:
        if (i is! MediaFileNetworkData) return;

        // 1 查询
        if (openFileDetail[i.filename] == null) {
          await _getNetworkMediaDetail(i);
        }

        // 2 再次检查
        if (openFileDetail[i.filename] == null) return;

        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SelectableText(openFileDetail[i.filename]["downloadURL"]),
                  Text("mimeType ${openFileDetail[i.filename]["mimeType"]}"),
                  Text("Size ${openFileDetail[i.filename]["size"]}"),
                ],
              ),
            ),
          ),
        );
        break;
    }
  }

  /// [Event]
  /// 刷新
  Future<void> _onRefresh(MediaType type) async {
    switch (type) {
      case MediaType.Local:
        _getLocalMediaFiles();
        break;
      case MediaType.Network:
        cloudMediaStatus.parame!.resetPage();
        _getNetworkMediaList();
        break;
    }
    return;
  }

  /// [Event]
  /// 下拉 追加数据
  Future _getMore(MediaType type) async {
    switch (type) {
      case MediaType.Local:
        _getLocalMediaFiles();
        break;
      case MediaType.Network:
        cloudMediaStatus.parame!.nextPage(count: cloudMediaStatus.parame!.limit!);
        await _getNetworkMediaList();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "app.setting.cell.media.title")),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              labelStyle: const TextStyle(fontSize: 16),
              controller: _tabController,
              tabs: [
                Tab(text: FlutterI18n.translate(context, "app.media.tab.local")),
                Tab(
                  child: Row(
                    children: [
                      Text(FlutterI18n.translate(context, "app.media.tab.cloud")),
                      const SizedBox(width: 5),
                      if (cloudMediaStatus.load!)
                        ELuiLoadComponent(
                          type: "line",
                          lineWidth: 1,
                          color: Theme.of(context).textTheme.displayMedium!.color!,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              flex: 1,
              child: TabBarView(
                controller: _tabController,
                children: [
                  /// 本地媒体库
                  RefreshIndicator(
                    key: _refreshLocalIndicatorKey,
                    onRefresh: () => _onRefresh(MediaType.Local),
                    child: Column(
                      crossAxisAlignment: EluiCellTextAlign.left,
                      children: [
                        Container(
                          height: 40,
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(flex: 1, child: Container()),
                              TextButton(
                                onPressed: () async {
                                  _openCamera();
                                },
                                child: const Icon(Icons.camera),
                              ),
                              const SizedBox(width: 5),
                              TextButton(
                                onPressed: () async {
                                  await importingFiles();
                                  _getLocalMediaFiles();
                                },
                                child: const Icon(Icons.file_open),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          flex: 1,
                          child: mediaStatus.list.isNotEmpty
                              ? GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 20.0,
                                    crossAxisSpacing: 10.0,
                                    childAspectRatio: 1.0,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                  itemCount: mediaStatus.list.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    MediaFileLocalData i = mediaStatus.list[index];
                                    return MediaCard(
                                      i: i,
                                      isSelectFile: widget.isSelectFile,
                                      onTapDelete: () async {
                                        await _deleteLocalFile(i.file);
                                        _getLocalMediaFiles();
                                      },
                                      onTapOpenFile: () {
                                        _onEnImageInfo(context, i);
                                      },
                                      onTapFileInfo: () {
                                        _onEnFileInfo(context, i);
                                      },
                                      onTapUploadFile: () {
                                        _onUploadFile(context, i);
                                      },
                                    );
                                  },
                                )
                              : const EmptyWidget(),
                        ),
                      ],
                    ),
                  ),

                  /// 云媒体库
                  RefreshIndicator(
                    key: _refreshNetworkIndicatorKey,
                    onRefresh: () => _onRefresh(MediaType.Network),
                    child: Column(
                      children: [
                        Container(
                          height: 40,
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline, size: 16),
                                    const SizedBox(width: 5),
                                    Text(
                                      "${cloudMediaInfoStatus.data!["usedStorageQuota"] ?? "0"}",
                                    )
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  _getNetworkMediaList();
                                },
                                child: const Icon(Icons.restart_alt_rounded),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          flex: 1,
                          child: cloudMediaStatus.list.isNotEmpty
                              ? GridView.builder(
                                  controller: _scrollNetworkController,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 20.0,
                                    crossAxisSpacing: 10.0,
                                    childAspectRatio: 1.0,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                  itemCount: cloudMediaStatus.list.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    MediaFileNetworkData i = cloudMediaStatus.list[index];
                                    return MediaCard(
                                      i: i,
                                      isSelectFile: widget.isSelectFile,
                                      // 云端不支持删除
                                      onTapDelete: null,
                                      onTapOpenFile: () {
                                        _onEnImageInfo(context, i);
                                      },
                                      onTapFileInfo: () {
                                        _onEnFileInfo(context, i);
                                      },
                                      onTagSelectFile: () {
                                        _onSelectFile(i);
                                      },
                                    );
                                  },
                                )
                              : const EmptyWidget(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaCard extends StatefulWidget {
  dynamic i;
  bool? isSelectFile;
  Function? onTapDelete;
  Function? onTapOpenFile;
  Function? onTapFileInfo;
  Function? onTapUploadFile;
  Function? onTagSelectFile;

  MediaCard({
    Key? key,
    this.i,
    this.isSelectFile = false,
    this.onTapDelete,
    this.onTapOpenFile,
    this.onTapFileInfo,
    this.onTapUploadFile,
    this.onTagSelectFile,
  }) : super(key: key);

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> {
  dynamic _filetype;

  FileManagement fileManagement = FileManagement();

  @override
  initState() {
    _filetype = widget.i.extension;
    super.initState();
  }

  /// [Event]
  /// 是否已上传
  bool _isUploaded(File file) {
    return file.path.contains("[Uploaded]");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: BorderSide(
          color: Theme.of(context).dividerTheme.color!,
          width: 1,
        ),
      ),
      color: Theme.of(context).bottomAppBarTheme.color,
      child: Column(
        children: [
          Flexible(
            flex: 1,
            child: Stack(
              children: [
                if (widget.i.type == MediaType.Local)
                  MediaIconCard(
                    i: widget.i,
                    filetype: _filetype,
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Icon(Icons.file_present, size: 40),
                    ),
                  ),

                /// 选择模式文件选择
                if (widget.i.type == MediaType.Network && widget.isSelectFile!)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.done),
                      onPressed: () {
                        if (widget.onTagSelectFile != null) widget.onTagSelectFile!();
                      },
                    ),
                  ),

                /// 标准模式下拉窗口
                Positioned(
                  top: 0,
                  right: 0,
                  child: PopupMenuButton(
                    offset: const Offset(0, 45),
                    onSelected: (value) {
                      switch (value) {
                        case "open_file":
                          if (widget.onTapOpenFile != null) widget.onTapOpenFile!();
                          break;
                        case "delete":
                          if (widget.onTapDelete != null) widget.onTapDelete!();
                          break;
                        case "see_file_info":
                          if (widget.onTapFileInfo != null) widget.onTapFileInfo!();
                          break;
                        case "upload_file":
                          if (widget.onTapUploadFile != null) widget.onTapUploadFile!();
                          break;
                      }
                    },
                    itemBuilder: (content) => <PopupMenuEntry>[
                      PopupMenuItem(
                        value: "open_file",
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(Icons.file_open_rounded),
                            const SizedBox(width: 10),
                            Text(FlutterI18n.translate(context, "app.media.open")),
                          ],
                        ),
                      ),
                      if (widget.i.type == MediaType.Local)
                        PopupMenuItem(
                          value: "delete",
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Icon(Icons.delete),
                              const SizedBox(width: 10),
                              Text(FlutterI18n.translate(context, "app.media.delete")),
                            ],
                          ),
                        ),
                      if (widget.i.type == MediaType.Local && !_isUploaded(widget.i.file)) const PopupMenuDivider(),
                      if (widget.i.type == MediaType.Local && !_isUploaded(widget.i.file))
                        PopupMenuItem(
                          value: "upload_file",
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Icon(Icons.upload_file_rounded),
                              const SizedBox(width: 10),
                              Text(FlutterI18n.translate(context, "app.media.uploadFile")),
                            ],
                          ),
                        ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: "see_file_info",
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(Icons.info),
                            const SizedBox(width: 10),
                            Text(FlutterI18n.translate(context, "app.media.fileInfo")),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                /// 远程获取信息遮盖
                if (widget.i.type == MediaType.Network && widget.i.fileDetailLoad)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.8),
                      child: ELuiLoadComponent(
                        type: "line",
                        lineWidth: 2,
                        color: Theme.of(context).textTheme.displayMedium!.color!,
                        size: 30,
                      ),
                    ),
                  ),

                /// 上传遮盖
                if (widget.i.type == MediaType.Local && widget.i.updataLoad)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.8),
                      child: ELuiLoadComponent(
                        type: "line",
                        lineWidth: 2,
                        color: Theme.of(context).textTheme.displayMedium!.color!,
                        size: 30,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    widget.i.filename.toString(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
                Wrap(
                  runSpacing: 2,
                  spacing: 2,
                  children: [
                    if (widget.i.type == MediaType.Local && _isUploaded(widget.i.file))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          border: Border.all(color: Theme.of(context).dividerTheme.color!),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Icon(Icons.cloud, size: 17),
                      ),
                    EluiTagComponent(
                      value: widget.i.fileExtension.toString(),
                      theme: EluiTagTheme(
                        backgroundColor: Theme.of(context).appBarTheme.backgroundColor!,
                      ),
                      color: EluiTagType.none,
                      size: EluiTagSize.no2,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MediaIconCard extends StatelessWidget {
  var filetype;

  var i;

  MediaIconCard({
    Key? key,
    this.filetype,
    this.i,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        if (filetype == FileType.IMAGE)
          Image.file(
            i.file,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.low,
          )
        else if (filetype == FileType.VIDEO)
          const Icon(
            Icons.video_camera_back_outlined,
            size: 40,
          )
        else
          const Icon(
            Icons.file_present,
            size: 40,
          ),
      ],
    );
  }
}
