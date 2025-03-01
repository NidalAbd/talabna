import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background messages
  await Firebase.initializeApp();

  print('Handling background message: ${message.notification?.title}');

  // Add your background message handling logic here
}

class FCMHandler {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initializeFCM() async {
    // Request permission for receiving notifications
    NotificationSettings settings = await firebaseMessaging.requestPermission(
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

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Configure foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');

      // Handle the received message as desired
      // You might want to show a local notification or update UI
    });

    // Configure message tap handling when app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened app: ${message.notification?.title}');
      // Handle navigation or specific action when user taps on notification
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await firebaseMessaging.getToken();
    print('Device Token: $token');
    return token ?? '';
  }
}