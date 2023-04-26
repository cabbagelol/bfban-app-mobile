import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';

import '../../widgets/index.dart';

class HtmlImage extends StatefulWidget {
  String? src;
  Color? color;
  Color? backgroundColor;

  HtmlImage({
    Key? key,
    this.src,
    this.color,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<HtmlImage> createState() => _HtmlImageState();
}

class _HtmlImageState extends State<HtmlImage> {
  /// [Event]
  /// 查看图片
  void onImageTap(context, String img) {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (BuildContext context) {
        return PhotoViewSimpleScreen(
          imageUrl: img,
          imageProvider: NetworkImage(img),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        color: widget.color!.withOpacity(.5),
        child: CachedNetworkImage(
          imageUrl: "${widget.src}",
          width: double.infinity,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(seconds: 0),
          fadeOutDuration: const Duration(seconds: 0),
          imageBuilder: (BuildContext buildContext, ImageProvider imageProvider) {
            return InkWell(
              child: Card(
                color: Colors.transparent,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      height: 25,
                      child: Row(
                        textBaseline: TextBaseline.ideographic,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              "${widget.src}",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                            ),
                          ),
                          const Icon(
                            Icons.link,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      color: Theme.of(context).cardTheme.color!.withOpacity(.2),
                      child: Image(image: imageProvider, fit: BoxFit.fitWidth),
                    ),
                  ],
                ),
              ),
              onTap: () {
                onImageTap(context, widget.src.toString());
              },
            );
          },
          placeholderFadeInDuration: const Duration(seconds: 0),
          placeholder: (BuildContext buildContext, String url) {
            return Card(
              margin: EdgeInsets.zero,
              color: widget.backgroundColor!.withOpacity(.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                child: Center(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.image, size: 50),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: ELuiLoadComponent(
                              type: "line",
                              color: Theme.of(buildContext).iconTheme.color!,
                              size: 17,
                              lineWidth: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: .5,
                        child: Text(
                          "${widget.src}",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          errorWidget: (BuildContext buildContext, String url, dynamic error) {
            return Card(
              margin: EdgeInsets.zero,
              color: widget.backgroundColor!.withOpacity(.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                child: Center(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: const [
                          Icon(Icons.image, size: 50),
                          Positioned(
                            top: -5,
                            right: -5,
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: .5,
                        child: Text(
                          "${widget.src}",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
