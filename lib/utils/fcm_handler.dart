import 'package:firebase_messaging/firebase_messaging.dart';

class FCMHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initializeFCM() async {
    // Request permission for receiving notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('FCM permission granted.');
    } else {
      print('FCM permission denied.');
    }

    // Configure message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.title}');

      // Handle the received message as desired
    });

    // Configure background message handling
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print('Handling background message: ${message.notification?.title}');

    // Handle the background message as desired
  }

  Future<String> getDeviceToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('Device Token: $token');
    return token ?? '';
  }
}
