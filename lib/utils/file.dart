enum FileType { NONE, VIDEO, IMAGE }

class FileManagement {
  /// 支持格式
  Map FILETYPE = {
    [FileType.VIDEO]: ["mp4", "mov"],
    [FileType.IMAGE]: ["png", "bmp", "jpg" "webp"],
  };

  /// 转换字典
  Map FILERESOLUTION = {
    "mp4": "video/mp4",
    "mov": "video/mov",
    "png": "image/png",
    "bmp":"image/bmp",
    "jpg": "image/jpeg",
    "webp": "image/webp",
  };

  /// 解析类型
  /// 通过文件后缀转换media-types格式
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types
  resolutionFileType (String url) {
    return FILERESOLUTION[splitFileUrl(url)["fileExtension"]] ?? "application/octet-stream";
  }

  /// 检查文件类型
  dynamic checkFileExtension(String url) {
    dynamic type = FileType.NONE;
    String fileExtension = splitFileUrl(url)["fileExtension"];

    for (MapEntry i in FILETYPE.entries) {
      if (i.value.contains(fileExtension)) {
        type = i.key;
        continue;
      }
    }
    return type!;
  }

  /// 拆分地址
  Map splitFileUrl(String url) {
    List splitArray = url.split("/");
    List f = splitArray.last.toString().split(".");

    return {
      "fullName": "${f[0]}.${f[1]}",
      "fileName": f[0],
      "fileExtension": f[1],
    };
  }
}
