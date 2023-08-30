enum BaseUrlProtocol { HTTP, HTTPS }

class BaseUrl {
  List<String> protocols = ["http", "https"];
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

  String get _protocol => protocol!.isNotEmpty ? "$protocol://" : "";

  String get baseHost => "$_protocol${host ?? ""}";

  String get url => "$_protocol${host ?? ""}${pathname ?? ""}";

  set url(String url) {
    Uri uri = Uri.parse(url);
    protocol = uri.scheme;
    pathname = uri.path;
    host = uri.host;
  }
}
