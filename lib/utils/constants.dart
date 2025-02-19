class Constants {
  // App name
  static const String appName = "Talabna";

  // API base URL
  // static const String apiBaseUrl = "https://talbna.cloud";
  static const String apiBaseUrl = "http://192.168.8.22:8000";

  // Social media API keys
  static const String googleApiKey = "YOUR_GOOGLE_API_KEY_HERE";
  static const String facebookApiKey = "YOUR_FACEBOOK_API_KEY_HERE";

  // Regular expressions
  static final RegExp emailRegExp =RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
      r"[a-zA-Z0-9])?)*$");

}
