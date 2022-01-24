/// 搜索

import 'dart:ui' as ui;

import 'package:bfban/pages/index/search_panel.dart';
import 'package:bfban/widgets/drawer.dart';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../utils/theme.dart';
import 'community.dart';

class SearchPage extends StatefulWidget {
  final int num;

  const SearchPage({
    Key? key,
    this.num = 0,
  }) : super(key: key);

  get getNum {
    return num;
  }

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // 应用主体
  AppThemeItem? theme;

  // 视频控制器
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();

    /// 播放控制器
    _controller = VideoPlayerController.asset(
      'assets/video/bf-video-hero-medium-steam-launch.mp4',
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    )
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      })
      ..setLooping(true)
      ..play();
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _screenHeight = MediaQuery.of(context).size.height;
    double _screenBarHeight = 26.0;

    return FlutterPluginDrawer(
      body: Stack(
        fit: StackFit.loose,
        children: <Widget>[
          // Positioned(
          //   top: 0,
          //   bottom: 0,
          //   child: _controller!.value.isInitialized
          //       ? AspectRatio(
          //           aspectRatio: _controller!.value.aspectRatio,
          //           child: VideoPlayer(_controller!),
          //         )
          //       : Container(),
          // ),
          BackdropFilter(
            child: const CommunityPage(),
            filter: ui.ImageFilter.blur(
              sigmaX: 6.0,
              sigmaY: 6.0,
            ),
          ),
        ],
      ),
      dragContainer: DragContainer(
        drawer: Container(
          child: OverscrollNotificationWidget(
            child: Column(
              children: <Widget>[
                Container(
                  height: 6.0,
                  width: 45.0,
                  margin: const EdgeInsets.only(top: 10.0, bottom: 10),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 214, 215, 218),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: _screenHeight * 0.7 - _screenBarHeight,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: const SearchPanel(),
                  ),
                ),
              ],
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).appBarTheme.backgroundColor!.withOpacity(.2),
                offset: const Offset(0, -2),
                spreadRadius: .2,
                blurRadius: 10,
              )
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          height: _screenBarHeight,
        ),
        defaultShowHeight: _screenBarHeight + 80,
        height: _screenHeight * .7,
      ),
    );
  }
}
