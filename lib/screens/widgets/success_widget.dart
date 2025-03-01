import 'package:flutter/material.dart';
import 'package:talbna/provider/language.dart';

enum SnackBarType { success, error, warning, info }

// Function to fetch translated text
String getTranslatedText(String key) {
  final currentLanguage = Language(); // Assume this function gets the current app language
  Map<String, Map<String, String>> translations = {
    'success': {
      'en': 'Action completed successfully!',
      'ar': 'تم تنفيذ العملية بنجاح!',
      'es': '¡Acción completada con éxito!',
    },
    'error': {
      'en': 'Something went wrong. Please try again.',
      'ar': 'حدث خطأ ما. يرجى المحاولة مرة أخرى.',
      'es': 'Algo salió mal. Por favor, inténtalo de nuevo.',
    },
    'warning': {
      'en': 'Warning! Please check the details.',
      'ar': 'تحذير! يرجى التحقق من التفاصيل.',
      'es': '¡Advertencia! Por favor, revisa los detalles.',
    },
    'info': {
      'en': 'Here’s what you need to know.',
      'ar': 'إليك ما تحتاج إلى معرفته.',
      'es': 'Aquí está lo que necesitas saber.',
    },
    'network_error': {
      'en': 'No internet connection. Please check your network.',
      'ar': 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.',
      'es': 'Sin conexión a Internet. Por favor, verifica tu red.',
    },
    'validation_error': {
      'en': 'Please ensure all fields are correctly filled.',
      'ar': 'يرجى التأكد من ملء جميع الحقول بشكل صحيح.',
      'es': 'Por favor, asegúrate de completar todos los campos correctamente.',
    },
    'permission_denied': {
      'en': 'You don’t have permission to perform this action.',
      'ar': 'ليس لديك الإذن لتنفيذ هذا الإجراء.',
      'es': 'No tienes permiso para realizar esta acción.',
    },
    'loading': {
      'en': 'Processing... Please wait.',
      'ar': 'جارٍ المعالجة... يرجى الانتظار.',
      'es': 'Procesando... Por favor, espera.',
    },
    'logout': {
      'en': 'You have been logged out successfully.',
      'ar': 'تم تسجيل خروجك بنجاح.',
      'es': 'Has cerrado sesión con éxito.',
    },
    'delete_confirmation': {
      'en': 'Are you sure you want to delete this?',
      'ar': 'هل أنت متأكد أنك تريد الحذف؟',
      'es': '¿Estás seguro de que deseas eliminar esto?',
    },
    'update_available': {
      'en': 'A new update is available. Please update the app.',
      'ar': 'يتوفر تحديث جديد. يرجى تحديث التطبيق.',
      'es': 'Hay una nueva actualización disponible. Por favor, actualiza la app.',
    },
  };

  return translations[key]?[currentLanguage] ?? translations[key]?['en'] ?? key;
}

// Show SnackBar function
void showCustomSnackBar(BuildContext context, String key,
    {SnackBarType type = SnackBarType.info}) {
  // Define color and icon based on type
  Color backgroundColor;
  IconData icon;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = Colors.green;
      icon = Icons.check_circle;
      break;
    case SnackBarType.error:
      backgroundColor = Colors.red;
      icon = Icons.error;
      break;
    case SnackBarType.warning:
      backgroundColor = Colors.orange;
      icon = Icons.warning;
      break;
    case SnackBarType.info:
    backgroundColor = Colors.blue;
      icon = Icons.info;
      break;
  }

  // Show the SnackBar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              getTranslatedText(key), // Get translated message
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      duration: const Duration(seconds: 3),
      elevation: 6,
    ),
  );
}
