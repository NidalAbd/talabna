import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:talbna/utils/debug_logger.dart';

class NetworkConnectivity {
  static final NetworkConnectivity _singleton = NetworkConnectivity._internal();
  final Connectivity _connectivity = Connectivity();

  bool _hasConnection = true;
  bool get hasConnection => _hasConnection;

  // Stream controller for connectivity changes
  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  // Static factory constructor
  factory NetworkConnectivity() {
    return _singleton;
  }

  // Internal constructor
  NetworkConnectivity._internal() {
    // Initialize connection status
    _checkConnectivity();

    // Listen for connectivity changes
    // The connectivity package now returns a List<ConnectivityResult>
    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  // Handle connectivity change with the updated API
  void _handleConnectivityChange(List<ConnectivityResult> result) {
    // If any connection is available, consider connected
    final hasConnection = !result.contains(ConnectivityResult.none) && result.isNotEmpty;
    _updateConnectionStatus(hasConnection);
  }

  // Check connectivity and update state
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      // Check if any connection is available
      final hasConnection = !result.contains(ConnectivityResult.none) && result.isNotEmpty;
      _updateConnectionStatus(hasConnection);
    } catch (e) {
      DebugLogger.log('Error checking connectivity: $e', category: 'NETWORK');
      _hasConnection = false;
      _connectivityController.add(_hasConnection);
    }
  }

  // Update connection status based on connectivity result
  void _updateConnectionStatus(bool hasConnection) {
    final previousStatus = _hasConnection;
    _hasConnection = hasConnection;

    // Only notify if status changed
    if (previousStatus != _hasConnection) {
      DebugLogger.log('Connectivity changed: ${_hasConnection ? 'Online' : 'Offline'}',
          category: 'NETWORK');
      _connectivityController.add(_hasConnection);
    }
  }

  // Force check connectivity - useful before major operations
  Future<bool> checkConnection() async {
    await _checkConnectivity();
    return _hasConnection;
  }

  // Dispose resources
  void dispose() {
    _connectivityController.close();
  }
}