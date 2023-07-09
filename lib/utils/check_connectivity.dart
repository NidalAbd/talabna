import 'package:connectivity_plus/connectivity_plus.dart';

class ApiInterceptor {
  final Connectivity _connectivity;

  ApiInterceptor(this._connectivity);

  Future<bool> isConnected() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<dynamic> interceptRequest(Function request) async {
    final bool isConnected = await this.isConnected();

    if (!isConnected) {
      throw Exception('You are currently offline');
    }

    return request();
  }
}
