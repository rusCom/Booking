import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (host != "") {
          if (host == "92.50.171.110") return true;
          if (host == "62.133.173.81") return true;
          if (host == "api.ataxi24.ru") return true;
        }
        return false;
      };
  }
}
