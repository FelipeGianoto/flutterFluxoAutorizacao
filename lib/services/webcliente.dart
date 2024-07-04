import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/intercepted_client.dart';

import 'http_interceptors.dart';

class WebClient {
  static const String url = "http://192.168.15.18:3001/";

  http.Client client = InterceptedClient.build(
    interceptors: [LoggingInterceptor()],
    requestTimeout: const Duration(seconds: 5),
  );
}
