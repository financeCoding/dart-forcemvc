part of dart_force_mvc_lib;

abstract class SecurityStrategy {

  bool checkAuthorization(HttpRequest req);
  
  Uri getRedirectUri(HttpRequest req);
  
}