import 'package:http/http.dart' as http;

class HttpClientService extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept-Encoding'] = 'gzip, deflate';
    request.headers['User-Agent'] = 'Blinkr/1.0';
    
    return _inner.send(request);
  }
}
