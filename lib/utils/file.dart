enum FileManagementType { NONE, VIDEO, IMAGE, ZIP }

class FileManagement {
  /// 支持格式
  final Map FILETYPE = {
    FileManagementType.VIDEO: ["webm", "ogg", "mp4", "mov"],
    FileManagementType.ZIP: ["zip"],
    FileManagementType.IMAGE: ["gif", "png", "bmp", "jpg", "webp"],
  };

  /// 解析类型
  /// 通过文件后缀转换media-types格式
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types
  resolutionFileType(String url) {
    switch (splitFileUrl(url)["fileExtension"]) {
      case "gif":
        return "image/gif";
      case "jpg":
        return "image/jpg";
      case "png":
        return "image/png";
      case "bmp":
        return "image/bmp";
      case "webp":
        return "image/webp";
      case "webm":
        return "video/webm";
      case "ogg":
        return "video/ogg";
      case "mp4":
        return "video/mp4";
      case "mov":
        return "video/mov";
      case "zip":
      case "x-zip-compressed":
        return "application/zip";
      default:
        return "application/octet-stream";
    }
  }

  /// 检查文件类型
  checkFileExtension(String url) {
    FileManagementType type = FileManagementType.NONE;
    String fileExtension = splitFileUrl(url)["fileExtension"];

    for (MapEntry i in FILETYPE.entries) {
      if (i.value.contains(fileExtension)) {
        type = i.key;
        continue;
      }
    }
    return type;
  }

  /// 拆分地址
  Map splitFileUrl(String url) {
    List splitArray = url.split("/");
    List f = splitArray.last.toString().split(".");

    return {
      "fullName": "${f[0]}.${f[1]}",
      "fileName": f[0] ?? "n/a",
      "fileExtension": f[1] ?? "err",
    };
  }

  /// [Event]
  /// Storage unit conversion
  String onUnitConversion(dynamic value) {
    String size = "";
    double limit = double.parse(value.toString());
    if (limit < 0.1 * 1024) {
      size = "${limit.toStringAsFixed(2)}B";
    } else if (limit < 0.1 * 1024 * 1024) {
      size = "${(limit / 1024).toStringAsFixed(2)}KB";
    } else if (limit < 0.1 * 1024 * 1024 * 1024) {
      size = "${(limit / (1024 * 1024)).toStringAsFixed(2)}MB";
    } else {
      size = "${(limit / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB";
    }

    return size;
  }
}