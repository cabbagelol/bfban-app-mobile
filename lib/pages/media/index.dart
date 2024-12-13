import 'dart:io';

import 'package:bfban/component/_loading/index.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../component/_refresh/index.dart';
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
  final bool? isSelectFile;

  const MediaPage({
    super.key,
    this.isSelectFile = false,
  });

  @override
  State<MediaPage> createState() => MediaPageState();
}

class MediaPageState extends State<MediaPage> {
  final UrlUtil _urlUtil = UrlUtil();

  final StorageAccount _storageAccount = StorageAccount();

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
    try {
      if (mediaStatus.load!) return;

      setState(() {
        mediaStatus.load = true;
        i.fileDetailLoad = true;
      });

      Response result = await Upload.serviceFile(i.filename!);

      if (result.data["success"] == 1) {
        final d = result.data;
        setState(() {
          openFileDetail.addAll({d["data"]["filename"]: d["data"]});
          i.fileDetailLoad = false;
          mediaStatus.load = false;
        });
        return;
      }

      throw result.data["message"];
    } catch (e) {
      if (mounted) return;
      EluiMessageComponent.error(context)(
        child: Text(e.toString()),
      );
    } finally {
      setState(() {
        i.fileDetailLoad = false;
        mediaStatus.load = false;
      });
    }
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
    List<String> scanDir = ['/media'];
    bool isShowLog = await _storageAccount.getConfiguration("logShowFile", false);
    if (isShowLog) {
      scanDir.add('/logs');
    }
    List pathFiles = await dirProvider!.getAllFile(scanDir);

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
  Future<void> onImportingFiles() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100, requestFullMetadata: true);
      final String fileName = "${const Uuid().v4(options: {'name': image?.name})}.${fileManagement.splitFileUrl(image!.name)["fileExtension"]}";

      await File(image.path).copy("${dirProvider!.currentDefaultSavePath}/media/$fileName");
    } catch (err) {
      EluiMessageComponent.error(context)(child: Text(err.toString()));
      rethrow;
    }
  }

  /// [Event]
  /// 删除本地文件
  Future<bool> _deleteLocalFile(File file) async {
    try {
      if (!await file.exists()) throw "file exists";
      file.deleteSync();
      return true;
    } catch (E) {
      EluiMessageComponent.error(context)(child: Text(E.toString()));
      return false;
    } finally {
      _getLocalMediaFiles();
    }
  }

  /// [Event]
  /// 打开拍摄
  void _openCameraPage() {
    _urlUtil.opEnPage(context, '/camera').then((res) {
      _getLocalMediaFiles();
    });
  }

  /// [Event]
  /// 选择文件
  /// 用于媒体选择，返回
  Future<void> _onSelectFile(dynamic i) async {
    try {
      if (openFileDetail[i.filename] == null) {
        await _getNetworkMediaDetail(i);
      }

      if (openFileDetail[i.filename]["downloadURL"] != null) {
        Navigator.pop(context, openFileDetail[i.filename]["downloadURL"]);
        return;
      }

      throw "No file information was obtained";
    } catch (E) {
      EluiMessageComponent.error(context)(child: Text(E.toString()));
    }
  }

  /// [Event]
  /// 调用外部程序打开
  void _onEnExternalFile(context, dynamic i) {
    try {
      switch (i.type) {
        case MediaType.Local:
          OpenFile.open(i.file.path);
          break;
        case MediaType.Network:
        case MediaType.values:
          throw "❌";
      }
    } catch (E) {
      EluiMessageComponent.error(context)(child: Text(E.toString()));
    }
  }

  /// [Event]
  /// 查看文件详情信息
  void _onEnImageInfo(context, dynamic i) async {
    try {
      switch (i.type) {
        case MediaType.Local:
          if (i is! MediaFileLocalData) return;

          Widget widget = Container();
          if (!await i.file.exists() && i.extension == null) return;

          if (i.extension == FileManagementType.IMAGE) {
            widget = Hero(
              tag: "image.${i.file.path}",
              child: PhotoViewSimpleScreen(
                type: PhotoViewFileType.file,
                imageUrl: i.file.path,
              ),
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
            MaterialPageRoute(builder: (BuildContext context) => widget),
          );
          break;
        case MediaType.Network:
          if (i is! MediaFileNetworkData) return;

          if (openFileDetail[i.filename] == null) {
            await _getNetworkMediaDetail(i);
          }

          if (openFileDetail.isEmpty) return;
          if (openFileDetail[i.filename ?? ""]["downloadURL"] == null) return;

          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => Hero(
              tag: "image.${openFileDetail[i.filename]["downloadURL"]}",
              child: PhotoViewSimpleScreen(
                type: PhotoViewFileType.network,
                imageUrl: openFileDetail[i.filename]["downloadURL"],
              ),
            ),
          ));
          break;
        case MediaType.values:
          throw "MediaType Unsupported type";
      }
    } catch (E) {
      EluiMessageComponent.error(context)(child: Text(E.toString()));
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
    try {
      setState(() {
        i.upload = true;
      });

      Map result = await Upload.on(i.file);

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

      throw result["message"];
    } catch (e) {
      EluiMessageComponent.error(context)(
        child: Text(e.toString()),
      );
    } finally {
      setState(() {
        i.upload = false;
      });
    }
  }

  /// [Event]
  /// 导出处理
  void _onExportFileCore(originalFilePath, DirItemStorePath newFilePath) async {
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
  /// 导出选择器Sheet Model
  void _onPenExportFileModel(context, MediaFileLocalData i) async {
    try {
      showModalBottomSheet<void>(
        context: context,
        clipBehavior: Clip.hardEdge,
        isScrollControlled: false,
        showDragHandle: true,
        useRootNavigator: true,
        builder: (BuildContext context) {
          return ListView(
            children: dirProvider!.paths.map((DirItemStorePath dir) {
              return ListTile(
                title: Text(FlutterI18n.translate(context, "app.media.directory.${dir.translate!.key!}", translationParams: dir.translate!.param)),
                subtitle: Text(dir.basicPath),
                onTap: () => _onExportFileCore(i, dir),
              );
            }).toList(),
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

        if (!context.mounted) return;
        showModalBottomSheet<void>(
          context: context,
          useSafeArea: true,
          isDismissible: true,
          isScrollControlled: false,
          showDragHandle: true,
          clipBehavior: Clip.hardEdge,
          builder: (BuildContext context) => ListView(
            children: <Widget>[
              ListTile(
                title: SelectableText(i.file.path.toString()),
                leading: Icon(Icons.file_present),
              ),
              Divider(indent: 8),
              ListTile(
                title: Text(stat.type.toString()),
              ),
              Divider(indent: 8),
              ListTile(
                title: Text("Size ${_fileManagement.onUnitConversion(stat.size)}"),
              ),
              Divider(),
              ListTile(
                title: Text("Accessed"),
                trailing: Text("${stat.accessed}"),
              ),
              Divider(indent: 8),
              ListTile(
                title: Text("Modified"),
                trailing: Text("${stat.modified}"),
              ),
              Divider(indent: 8),
              ListTile(
                title: Text("Changed"),
                trailing: Text("${stat.changed}"),
              ),
            ],
          ),
        );

        break;
      case MediaType.Network:
        if (i is! MediaFileNetworkData) return;

        // 1 查询并返回数据到 openFileDetail
        if (openFileDetail[i.filename] == null) {
          await _getNetworkMediaDetail(i);
        }

        // 2 再次检查
        if (openFileDetail[i.filename] == null) return;

        if (!context.mounted) return;
        showModalBottomSheet<void>(
          context: context,
          useSafeArea: true,
          isDismissible: true,
          isScrollControlled: false,
          showDragHandle: true,
          clipBehavior: Clip.hardEdge,
          builder: (BuildContext context) => ListView(
            children: <Widget>[
              ListTile(
                title: SelectableText("${Config.apis["network_service_request"]!.url}/service/file?filename=${openFileDetail[i.filename]["filename"]}"),
                leading: Icon(Icons.file_present),
              ),
              Divider(indent: 8),
              ListTile(
                title: Text("Mime Type"),
                trailing: Text("${openFileDetail[i.filename]["mimeType"]}"),
              ),
              Divider(indent: 8),
              ListTile(
                title: Text("Size"),
                trailing: Text(_fileManagement.onUnitConversion(openFileDetail[i.filename]["size"])),
              ),
            ],
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
                      LoadingWidget(
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
                      Refresh(
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
                                            _onEnExternalFile(context, i);
                                          },
                                          onTapViewFile: () {
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
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [const EmptyWidget()],
                                    ),
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
                                    onPressed: () => _openCameraPage(),
                                    child: const Icon(Icons.camera),
                                  ),
                                  const SizedBox(width: 5),
                                  TextButton(
                                    onPressed: () async {
                                      await onImportingFiles();
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
                      Refresh(
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
                                                    ? LoadingWidget(
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
  Function? onTapViewFile;
  Function? onTapFileInfo;
  Function? onTapUploadFile;
  Function? onTagSelectFile;
  Function? onTagExportFile;

  MediaCard({
    super.key,
    this.i,
    this.isSelectFile = false,
    this.onTapDelete,
    this.onTapOpenFile,
    this.onTapViewFile,
    this.onTapFileInfo,
    this.onTapUploadFile,
    this.onTagSelectFile,
    this.onTagExportFile,
  });

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
    return Consumer<UserInfoProvider>(builder: (BuildContext context, UserInfoProvider userData, state) {
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
                          if (widget.i.type == MediaType.Local && widget.onTapViewFile != null) {
                            widget.onTapViewFile!();
                          }
                        },
                        child: Hero(
                          tag: "image.${widget.i.file.path}",
                          child: MediaLocalIconCard(
                            i: widget.i,
                            filetype: _filetype,
                          ),
                        ),
                      ),
                    ),
                  if (widget.i.type == MediaType.Network)
                    ClipPath(
                      child: GestureDetector(
                        onDoubleTap: () {
                          if (widget.i.type == MediaType.Local && widget.onTapViewFile != null) {
                            widget.onTapViewFile!();
                          }
                        },
                        child: Hero(
                          tag: "image.${widget.i.filename}",
                          child: MediaNetworkIconCard(
                            i: widget.i,
                          ),
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
                          case "view_file":
                            if (widget.onTapViewFile != null) widget.onTapViewFile!();
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
                        PopupMenuItem(
                          value: "view_file",
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Icon(Icons.file_open_rounded),
                              const SizedBox(width: 10),
                              Text(FlutterI18n.translate(context, "app.media.view")),
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
                        if (widget.i.type == MediaType.Local && !widget.i.isUploaded && userData.isLogin) const PopupMenuDivider(),
                        if (widget.i.type == MediaType.Local && !widget.i.isUploaded && userData.isLogin)
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
                        child: Center(
                          child: LoadingWidget(
                            color: Theme.of(context).progressIndicatorTheme.color!,
                            size: 30,
                          ),
                        ),
                      ),
                    ),

                  /// 上传遮盖
                  if (true && widget.i.type == MediaType.Local && widget.i.upload)
                    Positioned.fill(
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.8),
                        child: Center(
                          child: LoadingWidget(
                            color: Theme.of(context).progressIndicatorTheme.color!,
                            size: 30,
                          ),
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
    });
  }
}

class MediaLocalIconCard extends StatelessWidget {
  final dynamic filetype;

  final dynamic i;

  const MediaLocalIconCard({
    super.key,
    required this.filetype,
    required this.i,
  });

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
  final dynamic i;

  const MediaNetworkIconCard({
    super.key,
    required this.i,
  });

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
            loadStateChanged: (ExtendedImageState state) {
              switch (state.extendedImageLoadState) {
                case LoadState.failed:
                  return Center(
                    child: Icon(Icons.error),
                  );
                case LoadState.completed:
                  break;
                case LoadState.loading:
                  return Center(
                    child: LoadingWidget(),
                  );
              }
              return null;
            },
          ),
        )
      ],
    );
  }
}
