import 'package:bfban/component/_html/htmlLink.dart';
import 'package:bfban/component/_loading/index.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../../utils/index.dart';
import '../../widgets/index.dart';

class HtmlImage extends StatefulWidget {
  final String? src;
  final Color? color;
  final Color? backgroundColor;

  const HtmlImage({
    super.key,
    this.src,
    this.color,
    this.backgroundColor,
  });

  @override
  State<HtmlImage> createState() => _HtmlImageState();
}

class _HtmlImageState extends State<HtmlImage> {
  double turns = 0.0;

  @override
  void initState() {
    super.initState();
  }

  /// [Event]
  /// 查看图片
  void onImageTap(context, String imageUrl) {
    if (imageUrl.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return PhotoViewSimpleScreen(
          type: PhotoViewFileType.network,
          imageUrl: imageUrl,
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      widget.src!,
      fit: BoxFit.fitWidth,
      mode: ExtendedImageMode.editor,
      filterQuality: FilterQuality.low,
      cache: true,
      enableLoadState: true,
      loadStateChanged: (ExtendedImageState state) {
        eventUtil.emit("html-image-update-widget", {});

        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return Card(
              margin: EdgeInsets.zero,
              color: widget.color!.withOpacity(.5),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
                            child: LoadingWidget(
                              size: 17,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: .5,
                        child: HtmlLink(
                          url: "${widget.src}",
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          case LoadState.completed:
            return Card(
              color: widget.color!.withOpacity(.5),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                    height: 25,
                    child: Row(
                      textBaseline: TextBaseline.ideographic,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (turns <= -1 + .25) {
                                    turns = 0;
                                    return;
                                  }
                                  turns -= .25;
                                });
                              },
                              child: const SizedBox(
                                width: 25,
                                child: Icon(Icons.turn_slight_left, size: 15),
                              ),
                            ),
                            const VerticalDivider(width: 1),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (turns >= 1 - .25) {
                                    turns = 0;
                                    return;
                                  }
                                  turns += .25;
                                });
                              },
                              child: const SizedBox(
                                width: 25,
                                child: Icon(Icons.turn_slight_right, size: 15),
                              ),
                            ),
                            if (turns != 0) const VerticalDivider(width: 1),
                            if (turns != 0)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    turns = 0;
                                  });
                                },
                                child: const SizedBox(
                                  width: 35,
                                  child: Icon(Icons.rotate_left, size: 15),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "${widget.src}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: widget.color),
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
                  ClipRect(
                    child: InkWell(
                      child: Container(
                        width: double.infinity,
                        color: widget.backgroundColor!.withOpacity(.2),
                        child: AnimatedRotation(
                          turns: turns,
                          duration: const Duration(milliseconds: 0),
                          child: Image(image: state.imageProvider, fit: BoxFit.fitWidth),
                        ),
                      ),
                      onTap: () {
                        onImageTap(context, widget.src.toString());
                      },
                    ),
                  ),
                ],
              ),
            );
          case LoadState.failed:
          default:
            return Card(
              margin: EdgeInsets.zero,
              color: widget.color!.withOpacity(.5),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Center(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.image, size: 50),
                          Positioned(
                            top: -5,
                            right: -5,
                            child: Icon(
                              Icons.error,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: .5,
                        child: HtmlLink(
                          url: "${widget.src}",
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}
