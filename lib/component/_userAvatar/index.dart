import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

class UserAvatar extends StatefulWidget {
  final String? src;
  final double? size;

  UserAvatar({this.src = "", this.size});

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  int mirrorImageIndex = 0;
  List mirrorImage = [
    "https://gravatar.loli.net/avatar/",
    "https://cdn.v2ex.com/gravatar/",
    "https://cdn.sep.cc/avatar/",
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(60),
      child: ExtendedImage.network(
        widget.src!,
        width: widget.size,
        height: widget.size,
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.failed:
              setState(() {
                widget.src!.replaceAll(mirrorImageIndex == 0 ? 'https://www.gravatar.com/avatar/' : mirrorImage[mirrorImageIndex - 1], mirrorImage[mirrorImageIndex]);

                mirrorImageIndex += 1;
              });
              break;
            case LoadState.loading:
            case LoadState.completed:
              break;
          }
        },
      ),
    );
  }
}
