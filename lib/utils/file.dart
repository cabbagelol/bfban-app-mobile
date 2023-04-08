enum FileType { NONE, VIDEO, IMAGE }

class FileManagement {
  /// 支持格式
  Map FILETYPE = {
    [FileType.VIDEO]: ["mp4"],
    [FileType.IMAGE]: ["png", "bmp", "jpg", "webp"],
  };

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
    return type![0];
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
