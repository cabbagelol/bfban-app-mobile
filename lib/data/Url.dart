enum BaseUrlProtocol { HTTP, HTTPS }

class BaseUrl {
  List protocols = ["http", "https"];
  String? protocol;
  String? host = "";
  String? pathname = "";

  BaseUrl({
    BaseUrlProtocol? protocol = BaseUrlProtocol.HTTP,
    this.host,
    this.pathname,
  }) : super() {
    this.protocol = protocols[protocol!.index];
  }

  get url => "${protocol!.isNotEmpty ? "$protocol://" : ""}${host ?? ""}${pathname ?? ""}";
}
