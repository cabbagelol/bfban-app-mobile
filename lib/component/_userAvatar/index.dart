import 'package:bfban/component/_loading/index.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

class UserAvatar extends StatefulWidget {
  final String? src;
  final double? size;

  const UserAvatar({
    super.key,
    this.src = "",
    this.size,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  /// 处理 Gravatar 国内镜像，避免海外域名超时或无法访问
  String _normalizeAvatarUrl(String url) {
    String cleanUrl = url.trim();
    if (cleanUrl.contains("gravatar.com/avatar/")) {
      cleanUrl = cleanUrl.replaceFirst(RegExp(r'https?:\/\/[a-zA-Z0-9_.-]*gravatar\.com\/avatar\/'), "https://cravatar.cn/avatar/");
    }
    return cleanUrl;
  }

  @override
  Widget build(BuildContext context) {
    final String src = _normalizeAvatarUrl(widget.src ?? "");
    final double defaultSize = widget.size ?? 40.0;

    Widget buildFallbackAvatar() {
      return Container(
        width: widget.size,
        height: widget.size,
        color: Theme
            .of(context)
            .colorScheme
            .surfaceContainerHighest,
        child: Icon(
          Icons.account_circle,
          size: defaultSize,
          color: Theme
              .of(context)
              .colorScheme
              .onSurfaceVariant,
        ),
      );
    }

    if (src.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: buildFallbackAvatar(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(60),
      child: ExtendedImage.network(
        src,
        width: widget.size,
        height: widget.size,
        printError: false,
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.failed:
              return buildFallbackAvatar();
            case LoadState.loading:
              return const LoadingWidget();
            case LoadState.completed:
              break;
          }
          return null;
        },
      ),
    );
  }
}
