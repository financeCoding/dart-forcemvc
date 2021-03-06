part of dart_force_mvc_lib;

class ForceRequest {
  
  HttpRequest request;
  Map<String, String> path_variables;
  Completer _asyncCallCompleter;
  
  ForceRequest(this.request) {
    path_variables = new Map<String, String>(); 
    _asyncCallCompleter = new Completer();
  }
  
  List header(String name) => request.headers[name.toLowerCase()];

  bool accepts(String type) =>
      request.headers['accept'].where((name) => name.split(',').indexOf(type) ).length > 0;

  bool isMime(String type) =>
      request.headers['content-type'].where((value) => value == type).isNotEmpty;

  bool get isForwarded => request.headers['x-forwarded-host'] != null;

  List<Cookie> get cookies => request.cookies.map((Cookie cookie) {
    cookie.name = Uri.decodeQueryComponent(cookie.name);
    cookie.value = Uri.decodeQueryComponent(cookie.value);
    return cookie;
  });
  
  Future<dynamic> getPostData({ bool usejson: true }) {
    Completer<dynamic> completer = new Completer<dynamic>();
    this.request.listen((List<int> buffer) {
      // Return the data back to the client.
      String dataOnAString = new String.fromCharCodes(buffer);
      print(dataOnAString);
      
      var package = usejson ? JSON.decode(dataOnAString) : dataOnAString;
      completer.complete(package);
    });
    return completer.future;
  }
  
  Future<Map<String, String>> getPostRawData() {
      Completer c = new Completer();
      this.request.transform(const AsciiDecoder()).listen((content) {
        c.complete(content);
      });
      return c.future;
    }
  
  Future<Map<String, String>> getPostParams({ Encoding enc: UTF8 }) {
    Completer c = new Completer();
    this.request.transform(const AsciiDecoder()).listen((content) {
      final postParams = new Map.fromIterable(
          content.split("&").map((kvs) => kvs.split("=")),
          key: (kv) => Uri.decodeQueryComponent(kv[0], encoding: enc),
          value: (kv) => Uri.decodeQueryComponent(kv[1], encoding: enc)
      );
      c.complete(postParams);
    });
    return c.future;
  }
  
  void async(value) {
    _asyncCallCompleter.complete(value);
  }
  
  Future get asyncFuture => _asyncCallCompleter.future;
  
}