import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../constants/api.dart';
import '../../data/index.dart';
import '../../provider/dir_provider.dart';
import '../../provider/userinfo_provider.dart';
import '../../utils/index.dart';
import '../../widgets/hint_login.dart';
import '../../widgets/photo.dart';
import '/component/_Time/index.dart';
import '/component/_empty/index.dart';

class MediaPage extends StatefulWidget {
  bool? isSelectFile;

  MediaPage({
    super.key,
    this.isSelectFile = false,
  });

  @override
  State<MediaPage> createState() => _mediaPageState();
}

class _mediaPageState extends State<MediaPage> {
  final UrlUtil _urlUtil = UrlUtil();

  final FileManagement _fileManagement = FileManagement();

  TabController? _tabController;

  final GlobalKey<RefreshIndicatorState> _refreshLocalIndicatorKey = GlobalKey<RefreshIndicatorState>();

  final GlobalKey<RefreshIndicatorState> _refreshNetworkIndicatorKey = GlobalKey<RefreshIndicatorState>();

  final ScrollController _scrollNetworkController = ScrollController();

  DirProvider? dirProvider;

  FileManagement fileManagement = FileManagement();

  ProviderUtil providerUtil = ProviderUtil();

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
    dirProvider = Provider.of<DirProvider>(context, listen: false);

    _getLocalMediaFiles();
    _getNetworkMediaList();
    _getNetworkMediaInfo();

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
    if (!providerUtil.ofUser(context).isLogin) return;

    setState(() {
      cloudMediaInfoStatus.load = true;
    });

    Response result = await HttpToken.request(
      Config.httpHost["service_myStorageQuota"],
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data;
      setState(() {
        cloudMediaInfoStatus.data = d["data"];
      });
    }

    setState(() {
      cloudMediaInfoStatus.load = false;
    });
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
    if (cloudMediaStatus.load! && !UserInfoProvider().isLogin) return;

    setState(() {
      cloudMediaStatus.load = true;
    });

    Response result = await HttpToken.request(
      Config.httpHost["service_myFiles"],
      parame: cloudMediaStatus.parame!.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data;

      if (mounted) {
        setState(() {
          if (cloudMediaStatus.parame!.skip! <= 0) {
            cloudMediaStatus.setList(d["data"], MediaType.Network);
          } else {
            if (d["data"].length <= 0) return;

            cloudMediaStatus.addList(d["data"], MediaType.Network);
          }
        });
      }
    }

    setState(() {
      cloudMediaStatus.load = false;
    });

    return cloudMediaStatus.list;
  }

  /// [Event]
  /// 获取本地媒体列表
  Future _getLocalMediaFiles() async {
    List pathFiles = await dirProvider!.getAllFile(laterPath: '/media');

    setState(() {
      if (pathFiles.isNotEmpty) {
        mediaStatus.setList(pathFiles, MediaType.Local);
        mediaStatus.setListSort();
      }
    });
    return true;
  }

  /// [Event]
  /// 从公共相册导入APP文件
  importingFiles() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100, requestFullMetadata: true);
      final String fileName = "${const Uuid().v4(options: {'name': image?.name})}.${fileManagement.splitFileUrl(image!.name)["fileExtension"]}";

      await File(image.path).copy("${dirProvider!.currentDefaultSavePath}/media/$fileName");
    } catch (err) {
      rethrow;
    }
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

        if (i.extension == FileManagementType.IMAGE) {
          widget = PhotoViewSimpleScreen(
            type: PhotoViewFileType.file,
            imageUrl: i.file.path,
          );
        }

        if (i.extension == FileManagementType.VIDEO || i.extension == FileManagementType.NONE) {
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
              type: PhotoViewFileType.network,
              imageUrl: openFileDetail[i.filename]["downloadURL"],
            );
          },
        ));
        break;
    }
  }

  /// [Event]
  /// 查看媒体库状态
  void _opEnCloudMediaInfo() {
    Widget widget = Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          EluiCellComponent(
            title: FlutterI18n.translate(context, 'profile.media.maxFileNumber'),
            cont: Text(cloudMediaInfoStatus.data!['maxFileNumber'].toString()),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, 'profile.media.maxTrafficQuota'),
            cont: Text(_fileManagement.onUnitConversion(cloudMediaInfoStatus.data!['maxTrafficQuota'])),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, 'profile.media.usedStorageQuota'),
            cont: Row(
              children: [
                Text(_fileManagement.onUnitConversion(cloudMediaInfoStatus.data!['usedStorageQuota'])),
                const Text("/"),
                Text(_fileManagement.onUnitConversion(cloudMediaInfoStatus.data!['totalStorageQuota'])),
              ],
            ),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, 'profile.media.todayFileNumber'),
            cont: Text(cloudMediaInfoStatus.data!['todayFileNumber'].toString()),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, 'profile.media.todayTrafficQuota'),
            cont: Text(_fileManagement.onUnitConversion(cloudMediaInfoStatus.data!['todayTrafficQuota'])),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, 'profile.media.prevResetTime'),
            cont: TimeWidget(data: cloudMediaInfoStatus.data!['prevResetTime']),
          ),
        ],
      ),
    );

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (BuildContext context) {
          return widget;
        },
      ),
    );
  }

  /// [Event]
  /// 上传文件
  void _onUploadFile(context, i) async {
    setState(() {
      i.upload = true;
    });

    Map result = await Upload().on(i.file);

    if (result["code"] == 1) {
      // 标记
      Map splitFileUrl = fileManagement.splitFileUrl(i.file.path);
      String newPath = "${i.file.parent.path}/${splitFileUrl["fileName"]}_[Uploaded].${splitFileUrl["fileExtension"]}";
      i.file.renameSync(newPath);

      EluiMessageComponent.success(context)(
        child: Text(result["message"]),
      );

      _getLocalMediaFiles();
      setState(() {
        i.upload = false;
      });
      return;
    }

    setState(() {
      i.upload = false;
    });

    EluiMessageComponent.error(context)(
      child: Text(result["message"]),
    );
  }

  ///
  void _onExportFile(originalFilePath, DirItemStorePath newFilePath) async {
    try {
      String fileName = fileManagement.splitFileUrl(originalFilePath.file.path)["fileName"];
      String newPath = "${dirProvider?.paths.where((element) => element.dirName == newFilePath.dirName).first.basicPath}/$fileName";

      await File(originalFilePath.file.path).copy(newPath);

      EluiMessageComponent.success(context)(
        child: Column(
          children: [
            const Icon(Icons.done),
            Text(newPath),
          ],
        ),
      );
      Navigator.pop(context);
    } catch (err) {
      EluiMessageComponent.error(context)(
        child: Text(err.toString()),
      );
    }
  }

  /// [Event]
  /// 导出
  void _onPenExportFileModel(context, MediaFileLocalData i) async {
    try {
      showModalBottomSheet<void>(
        context: context,
        clipBehavior: Clip.hardEdge,
        useRootNavigator: true,
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              leading: const CloseButton(),
              title: Text(FlutterI18n.translate(context, "app.media.export")),
            ),
            body: ListView(
              children: dirProvider!.paths.map((DirItemStorePath dir) {
                return ListTile(
                  title: Text(FlutterI18n.translate(context, "app.media.directory.${dir.translate!.key!}", translationParams: dir.translate!.param)),
                  subtitle: Text(dir.basicPath),
                  onTap: () => _onExportFile(i, dir),
                );
              }).toList(),
            ),
          );
        },
      );
    } catch (err) {
      EluiMessageComponent.error(context)(
        child: Text(err.toString()),
      );
    }
  }

  /// [Event]
  /// 打开文件详情
  void _onEnFileInfo(BuildContext context, dynamic i) async {
    switch (i.type) {
      case MediaType.Local:
        if (i is! MediaFileLocalData) return;

        FileStat stat = await i.file.stat();

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SelectableText(i.file.path.toString()),
                  Text(stat.type.toString()),
                  Text("Size ${_fileManagement.onUnitConversion(stat.size)}"),
                  Text("Accessed ${stat.accessed}"),
                  Text("Modified ${stat.modified}"),
                  Text("Changed ${stat.changed}"),
                ],
              ),
            ),
          ),
        );
        break;
      case MediaType.Network:
        if (i is! MediaFileNetworkData) return;

        // 1 查询
        if (openFileDetail[i.filename] == null) {
          await _getNetworkMediaDetail(i);
        }

        // 2 再次检查
        if (openFileDetail[i.filename] == null) return;

        print(openFileDetail[i.filename]['filename']);

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SelectableText("${Config.apis["network_service_request"]!.url}/service/file?filename=${openFileDetail[i.filename]["filename"]}"),
                  Text("mimeType ${openFileDetail[i.filename]["mimeType"]}"),
                  Text("Size ${_fileManagement.onUnitConversion(openFileDetail[i.filename]["size"])}"),
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
        await _getLocalMediaFiles();
        break;
      case MediaType.Network:
        cloudMediaStatus.parame!.resetPage();
        await _getNetworkMediaInfo();
        await _getNetworkMediaList();
        break;
    }
    return;
  }

  /// [Event]
  /// 下拉 追加数据
  Future _getMore(MediaType type) async {
    switch (type) {
      case MediaType.Local:
        await _getLocalMediaFiles();
        break;
      case MediaType.Network:
        cloudMediaStatus.parame!.nextPage(count: cloudMediaStatus.parame!.limit!);
        await _getNetworkMediaList();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "app.setting.cell.media.title")),
          actions: [
            IconButton(
              padding: const EdgeInsets.all(16),
              onPressed: () {
                _urlUtil.opEnPage(context, "/profile/dir/configuration").then((value) {
                  _onRefresh(MediaType.Local);
                });
              },
              icon: const Icon(Icons.settings),
            ),
          ],
          bottom: TabBar(
            labelStyle: const TextStyle(fontSize: 16),
            controller: _tabController,
            tabs: [
              Tab(
                child: Text(FlutterI18n.translate(context, "app.media.tab.local")),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(FlutterI18n.translate(context, "app.media.tab.cloud")),
                    if (cloudMediaInfoStatus.load!) const SizedBox(width: 5),
                    if (cloudMediaInfoStatus.load!)
                      ELuiLoadComponent(
                        type: "line",
                        lineWidth: 2,
                        color: Theme.of(context).progressIndicatorTheme.color!,
                        size: 13,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Consumer<UserInfoProvider>(
          builder: (BuildContext context, UserInfoProvider userinfo, Widget? child) {
            return Column(
              children: [
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
                            Expanded(
                              flex: 1,
                              child: mediaStatus.list.isNotEmpty
                                  ? GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        mainAxisSpacing: 5,
                                        crossAxisSpacing: 5,
                                        childAspectRatio: 1.0,
                                      ),
                                      padding: const EdgeInsets.all(5),
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
                                          onTagExportFile: () {
                                            _onPenExportFileModel(context, i);
                                          },
                                        );
                                      },
                                    )
                                  : const EmptyWidget(),
                            ),
                            const Divider(height: 1),
                            Container(
                              color: Theme.of(context).bottomAppBarTheme.color,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Wrap(
                                      spacing: 7,
                                      children: [
                                        Wrap(
                                          spacing: 2,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            const Icon(Icons.file_present_sharp),
                                            Text("${mediaStatus.list.length} file"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
                          ],
                        ),
                      ),

                      /// 云媒体库
                      RefreshIndicator(
                        key: _refreshNetworkIndicatorKey,
                        onRefresh: () => _onRefresh(MediaType.Network),
                        child: userinfo.isLogin
                            ? Column(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: cloudMediaStatus.list.isNotEmpty
                                        ? GridView.builder(
                                            controller: _scrollNetworkController,
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              mainAxisSpacing: 5,
                                              crossAxisSpacing: 5,
                                              childAspectRatio: 1.0,
                                            ),
                                            padding: const EdgeInsets.all(5),
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
                                  const Divider(height: 1),
                                  Container(
                                    color: Theme.of(context).bottomAppBarTheme.color,
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: GestureDetector(
                                            onTap: () => _opEnCloudMediaInfo(),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                cloudMediaInfoStatus.data!.isEmpty
                                                    ? ELuiLoadComponent(
                                                        type: "line",
                                                        lineWidth: 1,
                                                        color: Theme.of(context).progressIndicatorTheme.color!,
                                                        size: 16,
                                                      )
                                                    : Row(
                                                        children: [
                                                          const Icon(Icons.info_outline, size: 18),
                                                          const SizedBox(width: 10),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(_fileManagement.onUnitConversion(cloudMediaInfoStatus.data!['usedStorageQuota'])),
                                                                  const Text("/"),
                                                                  Text(_fileManagement.onUnitConversion(cloudMediaInfoStatus.data!['totalStorageQuota'])),
                                                                ],
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => _onRefresh(MediaType.Network),
                                          child: const Icon(Icons.restart_alt_rounded),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : const Center(child: HintLoginWidget()),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MediaCard extends StatefulWidget {
  dynamic i;
  bool? isSelectFile;
  Function? onTapDelete;
  Function? onTapOpenFile;
  Function? onTapFileInfo;
  Function? onTapUploadFile;
  Function? onTagSelectFile;
  Function? onTagExportFile;

  MediaCard({
    Key? key,
    this.i,
    this.isSelectFile = false,
    this.onTapDelete,
    this.onTapOpenFile,
    this.onTapFileInfo,
    this.onTapUploadFile,
    this.onTagSelectFile,
    this.onTagExportFile,
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

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
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
                  ClipPath(
                    child: GestureDetector(
                      onDoubleTap: () {
                        if (widget.i.type == MediaType.Local && widget.onTapOpenFile != null) {
                          widget.onTapOpenFile!();
                        }
                      },
                      child: MediaLocalIconCard(
                        i: widget.i,
                        filetype: _filetype,
                      ),
                    ),
                  ),
                if (widget.i.type == MediaType.Network)
                  ClipPath(
                    child: GestureDetector(
                      onDoubleTap: () {
                        if (widget.i.type == MediaType.Local && widget.onTapOpenFile != null) {
                          widget.onTapOpenFile!();
                        }
                      },
                      child: MediaNetworkIconCard(
                        i: widget.i,
                      ),
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
                        case "export_file":
                          if (widget.onTagExportFile != null) widget.onTagExportFile!();
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
                      if (widget.i.type == MediaType.Local)
                        PopupMenuItem(
                          value: "export_file",
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Icon(Icons.file_copy_rounded),
                              const SizedBox(width: 10),
                              Text(FlutterI18n.translate(context, "app.media.export")),
                            ],
                          ),
                        ),
                      if (widget.i.type == MediaType.Local && !widget.i.isUploaded) const PopupMenuDivider(),
                      if (widget.i.type == MediaType.Local && !widget.i.isUploaded)
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
                  Positioned.fill(
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.8),
                      child: ELuiLoadComponent(
                        type: "line",
                        lineWidth: 2,
                        color: Theme.of(context).progressIndicatorTheme.color!,
                        size: 30,
                      ),
                    ),
                  ),

                /// 上传遮盖
                if (widget.i.type == MediaType.Local && widget.i.upload)
                  Positioned.fill(
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.8),
                      child: ELuiLoadComponent(
                        type: "line",
                        lineWidth: 2,
                        color: Theme.of(context).progressIndicatorTheme.color!,
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
                    widget.i.filename,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Wrap(
                  runSpacing: 2,
                  spacing: 2,
                  children: [
                    if (widget.i.type == MediaType.Local && widget.i.isUploaded)
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

class MediaLocalIconCard extends StatelessWidget {
  var filetype;

  var i;

  MediaLocalIconCard({
    Key? key,
    this.filetype,
    this.i,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (filetype == FileManagementType.IMAGE)
          Expanded(
            flex: 1,
            child: ExtendedImage.file(
              i.file,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.low,
              repeat: ImageRepeat.noRepeat,
            ),
          )
        else if (filetype == FileManagementType.VIDEO)
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

class MediaNetworkIconCard extends StatelessWidget {
  var i;

  MediaNetworkIconCard({
    Key? key,
    this.i,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: ExtendedImage.network(
            "${Config.apis["network_service_request"]!.url}/service/file?filename=${i.filename}",
            fit: BoxFit.contain,
            filterQuality: FilterQuality.low,
            repeat: ImageRepeat.noRepeat,
          ),
        )
      ],
    );
  }
}
