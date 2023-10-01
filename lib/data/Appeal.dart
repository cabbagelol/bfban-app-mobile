class AppealStatus {
  late bool? load;
  AppealParame? parame;

  AppealStatus({
    this.load,
    this.parame,
  });
}

class AppealParame {
  String? toPlayerId;
  String? appealType;
  String? content;
  AppealParameExtendedLinks? extendedLinks;

  AppealParame({
    required this.toPlayerId,
    required this.appealType,
    required this.content,
    this.extendedLinks,
  });

  get toMap {
    Map data = {
      "data": {
        "toPlayerId": toPlayerId,
        "appealType": appealType,
        "content": content,
      }
    };

    if (extendedLinks!.isNotNull) data["data"]["extendedLinks"] = extendedLinks!.toMap;
    return data;
  }
}

class AppealParameExtendedLinks {
  String? videoLink;
  String? btrLink;
  String? mossDownloadUrl;

  AppealParameExtendedLinks({
    this.videoLink = "",
    this.btrLink = "",
    this.mossDownloadUrl = "",
  });

  get isNotNull => videoLink!.isNotEmpty && btrLink!.isNotEmpty && mossDownloadUrl!.isNotEmpty;

  get toMap {
    Map data = {};
    if (videoLink != null) data["videoLink"] = videoLink;
    if (btrLink != null) data["btrLink"] = btrLink;
    if (mossDownloadUrl != null) data["mossDownloadUrl"] = mossDownloadUrl;
    return data;
  }
}
