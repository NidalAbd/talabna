import 'package:flutter/material.dart';
import 'package:talbna/main.dart';

class Language extends ChangeNotifier {
  String _lang = language;

  getLanguage(){
    return _lang;
  }
  setLanguage(String lang){
    _lang = lang;
    notifyListeners();
  }
  String tJobTextHome() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'وظائف';
      case 'en':
        return 'jobs';
      case 'Es':
        return 'trabajos';
      case '中文':
        return '工作';
      case 'हिन्दी':
        return 'नौकरियां';
      case 'Português':
        return 'empregos';
      case 'Русский':
        return 'работа';
      case '日本語':
        return '仕事';
      case 'Français':
        return 'emplois';
      case 'Deutsch':
        return 'Arbeitsplätze';
      default:
        return '';
    }
  }
  String chooseLanguageText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'اختر لغتك';
      case 'en':
        return 'Choose Your Language';
      default:
        return 'Choose Your Language';
    }
  }
  String tReportTitle() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الإبلاغ';
      case 'en':
        return 'Report';
      case 'Es':
        return 'Informe';
      case '中文':
        return '报告';
      case 'हिन्दी':
        return 'रिपोर्ट';
      case 'Português':
        return 'Relatório';
      case 'Русский':
        return 'Отчет';
      case '日本語':
        return '報告';
      case 'Français':
        return 'Rapport';
      case 'Deutsch':
        return 'Bericht';
      default:
        return 'Report';
    }
  }
  String tReportSpam() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'سبام';
      case 'en':
        return 'Spam';
      case 'Es':
        return 'Spam';
      case '中文':
        return '垃圾信息';
      case 'हिन्दी':
        return 'स्पैम';
      case 'Português':
        return 'Spam';
      case 'Русский':
        return 'Спам';
      case '日本語':
        return 'スパム';
      case 'Français':
        return 'Spam';
      case 'Deutsch':
        return 'Spam';
      default:
        return 'Spam';
    }
  }
  String tReportInappropriate() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'محتوى غير لائق';
      case 'en':
        return 'Inappropriate content';
      case 'Es':
        return 'Contenido inapropiado';
      case '中文':
        return '不当内容';
      case 'हिन्दी':
        return 'अनुचित सामग्री';
      case 'Português':
        return 'Conteúdo impróprio';
      case 'Русский':
        return 'Неприемлемый контент';
      case '日本語':
        return '不適切なコンテンツ';
      case 'Français':
        return 'Contenu inapproprié';
      case 'Deutsch':
        return 'Unangemessene Inhalte';
      default:
        return 'Inappropriate content';
    }
  }
  String tReportHarassment() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'مضايقة';
      case 'en':
        return 'Harassment';
      case 'Es':
        return 'Acoso';
      case '中文':
        return '骚扰';
      case 'हिन्दी':
        return 'उत्पीड़न';
      case 'Português':
        return 'Assédio';
      case 'Русский':
        return 'Преследование';
      case '日本語':
        return 'ハラスメント';
      case 'Français':
        return 'Harcèlement';
      case 'Deutsch':
        return 'Belästigung';
      default:
        return 'Harassment';
    }
  }
  String tReportFalseInfo() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'معلومات كاذبة';
      case 'en':
        return 'False information';
      case 'Es':
        return 'Información falsa';
      case '中文':
        return '虚假信息';
      case 'हिन्दी':
        return 'गलत जानकारी';
      case 'Português':
        return 'Informação falsa';
      case 'Русский':
        return 'Ложная информация';
      case '日本語':
        return '虚偽の情報';
      case 'Français':
        return 'Fausse information';
      case 'Deutsch':
        return 'Falsche Informationen';
      default:
        return 'False information';
    }
  }
  // Add these methods to your Language class

  String tPreferencesText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'التفضيلات';
      case 'en':
        return 'Preferences';
      case 'Español':
        return 'Preferencias';
      case '中文':
        return '偏好设置';
      case 'हिन्दी':
        return 'प्राथमिकताएँ';
      case 'Português':
        return 'Preferências';
      case 'Русский':
        return 'Настройки';
      case '日本語':
        return '設定';
      case 'Français':
        return 'Préférences';
      case 'Deutsch':
        return 'Einstellungen';
      default:
        return 'Preferences';
    }
  }

  String tAccountText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الحساب';
      case 'en':
        return 'Account';
      case 'Español':
        return 'Cuenta';
      case '中文':
        return '账户';
      case 'हिन्दी':
        return 'खाता';
      case 'Português':
        return 'Conta';
      case 'Русский':
        return 'Аккаунт';
      case '日本語':
        return 'アカウント';
      case 'Français':
        return 'Compte';
      case 'Deutsch':
        return 'Konto';
      default:
        return 'Account';
    }
  }

  String tSupportText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الدعم';
      case 'en':
        return 'Support';
      case 'Español':
        return 'Soporte';
      case '中文':
        return '支持';
      case 'हिन्दी':
        return 'सहायता';
      case 'Português':
        return 'Suporte';
      case 'Русский':
        return 'Поддержка';
      case '日本語':
        return 'サポート';
      case 'Français':
        return 'Support';
      case 'Deutsch':
        return 'Unterstützung';
      default:
        return 'Support';
    }
  }

  String tOtherText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'أخرى';
      case 'en':
        return 'Other';
      case 'Español':
        return 'Otros';
      case '中文':
        return '其他';
      case 'हिन्दी':
        return 'अन्य';
      case 'Português':
        return 'Outros';
      case 'Русский':
        return 'Другое';
      case '日本語':
        return 'その他';
      case 'Français':
        return 'Autre';
      case 'Deutsch':
        return 'Sonstiges';
      default:
        return 'Other';
    }
  }

  String tNotificationsText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الإشعارات';
      case 'en':
        return 'Notifications';
      case 'Español':
        return 'Notificaciones';
      case '中文':
        return '通知';
      case 'हिन्दी':
        return 'सूचनाएँ';
      case 'Português':
        return 'Notificações';
      case 'Русский':
        return 'Уведомления';
      case '日本語':
        return '通知';
      case 'Français':
        return 'Notifications';
      case 'Deutsch':
        return 'Benachrichtigungen';
      default:
        return 'Notifications';
    }
  }

  String tHelpCenterText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'مركز المساعدة';
      case 'en':
        return 'Help Center';
      case 'Español':
        return 'Centro de Ayuda';
      case '中文':
        return '帮助中心';
      case 'हिन्दी':
        return 'सहायता केंद्र';
      case 'Português':
        return 'Central de Ajuda';
      case 'Русский':
        return 'Центр помощи';
      case '日本語':
        return 'ヘルプセンター';
      case 'Français':
        return 'Centre d\'aide';
      case 'Deutsch':
        return 'Hilfezentrum';
      default:
        return 'Help Center';
    }
  }

  String tPrivacyPolicyText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'سياسة الخصوصية';
      case 'en':
        return 'Privacy Policy';
      case 'Español':
        return 'Política de Privacidad';
      case '中文':
        return '隐私政策';
      case 'हिन्दी':
        return 'गोपनीयता नीति';
      case 'Português':
        return 'Política de Privacidade';
      case 'Русский':
        return 'Политика конфиденциальности';
      case '日本語':
        return 'プライバシーポリシー';
      case 'Français':
        return 'Politique de Confidentialité';
      case 'Deutsch':
        return 'Datenschutzrichtlinie';
      default:
        return 'Privacy Policy';
    }
  }

  String tAboutText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'حول التطبيق';
      case 'en':
        return 'About';
      case 'Español':
        return 'Acerca de';
      case '中文':
        return '关于';
      case 'हिन्दी':
        return 'के बारे में';
      case 'Português':
        return 'Sobre';
      case 'Русский':
        return 'О приложении';
      case '日本語':
        return 'アプリについて';
      case 'Français':
        return 'À propos';
      case 'Deutsch':
        return 'Über';
      default:
        return 'About';
    }
  }

  String tAppearanceText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'المظهر';
      case 'en':
        return 'Appearance';
      case 'Español':
        return 'Apariencia';
      case '中文':
        return '外观';
      case 'हिन्दी':
        return 'दिखावट';
      case 'Português':
        return 'Aparência';
      case 'Русский':
        return 'Внешний вид';
      case '日本語':
        return '外観';
      case 'Français':
        return 'Apparence';
      case 'Deutsch':
        return 'Erscheinungsbild';
      default:
        return 'Appearance';
    }
  }

  String tConfirmChangeText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تأكيد التغيير';
      case 'en':
        return 'Confirm Change';
      case 'Español':
        return 'Confirmar Cambio';
      case '中文':
        return '确认更改';
      case 'हिन्दी':
        return 'परिवर्तन की पुष्टि करें';
      case 'Português':
        return 'Confirmar Alteração';
      case 'Русский':
        return 'Подтвердить изменение';
      case '日本語':
        return '変更を確認';
      case 'Français':
        return 'Confirmer le Changement';
      case 'Deutsch':
        return 'Änderung Bestätigen';
      default:
        return 'Confirm Change';
    }
  }

  String tLanguageChangeDescText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'هل أنت متأكد أنك تريد تغيير اللغة؟ سيتم إعادة تشغيل التطبيق لتطبيق التغييرات.';
      case 'en':
        return 'Are you sure you want to change the language? The app will restart to apply changes.';
      case 'Español':
        return '¿Estás seguro de que quieres cambiar el idioma? La aplicación se reiniciará para aplicar los cambios.';
      case '中文':
        return '你确定要更改语言吗？应用将重新启动以应用更改。';
      case 'हिन्दी':
        return 'क्या आप वाकई भाषा बदलना चाहते हैं? परिवर्तन लागू करने के लिए ऐप पुनरारंभ होगा।';
      case 'Português':
        return 'Tem certeza de que deseja alterar o idioma? O aplicativo será reiniciado para aplicar as alterações.';
      case 'Русский':
        return 'Вы уверены, что хотите изменить язык? Приложение перезапустится, чтобы применить изменения.';
      case '日本語':
        return '言語を変更してもよろしいですか？変更を適用するためにアプリが再起動します。';
      case 'Français':
        return 'Êtes-vous sûr de vouloir changer la langue ? L\'application redémarrera pour appliquer les modifications.';
      case 'Deutsch':
        return 'Sind Sie sicher, dass Sie die Sprache ändern möchten? Die App wird neu gestartet, um die Änderungen anzuwenden.';
      default:
        return 'Are you sure you want to change the language? The app will restart to apply changes.';
    }
  }

  String tCancelText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'إلغاء';
      case 'en':
        return 'Cancel';
      case 'Español':
        return 'Cancelar';
      case '中文':
        return '取消';
      case 'हिन्दी':
        return 'रद्द करें';
      case 'Português':
        return 'Cancelar';
      case 'Русский':
        return 'Отмена';
      case '日本語':
        return 'キャンセル';
      case 'Français':
        return 'Annuler';
      case 'Deutsch':
        return 'Abbrechen';
      default:
        return 'Cancel';
    }
  }

  String tConfirmText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تأكيد';
      case 'en':
        return 'Confirm';
      case 'Español':
        return 'Confirmar';
      case '中文':
        return '确认';
      case 'हिन्दी':
        return 'पुष्टि करें';
      case 'Português':
        return 'Confirmar';
      case 'Русский':
        return 'Подтвердить';
      case '日本語':
        return '確認';
      case 'Français':
        return 'Confirmer';
      case 'Deutsch':
        return 'Bestätigen';
      default:
        return 'Confirm';
    }
  }

  String tSelectLanguageText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'اختر اللغة';
      case 'en':
        return 'Select Language';
      case 'Español':
        return 'Seleccionar Idioma';
      case '中文':
        return '选择语言';
      case 'हिन्दी':
        return 'भाषा चुनें';
      case 'Português':
        return 'Selecionar Idioma';
      case 'Русский':
        return 'Выбрать язык';
      case '日本語':
        return '言語を選択';
      case 'Français':
        return 'Sélectionner la Langue';
      case 'Deutsch':
        return 'Sprache Auswählen';
      default:
        return 'Select Language';
    }
  }String tUserText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'المستخدم';
      case 'en':
        return 'User';
      case 'Español':
        return 'Usuario';
      case '中文':
        return '用户';
      case 'हिन्दी':
        return 'उपयोगकर्ता';
      case 'Português':
        return 'Usuário';
      case 'Русский':
        return 'Пользователь';
      case '日本語':
        return 'ユーザー';
      case 'Français':
        return 'Utilisateur';
      case 'Deutsch':
        return 'Benutzer';
      default:
        return 'User';
    }
  }
  String tReportSuccess() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تم الإبلاغ بنجاح';
      case 'en':
        return 'Reported successfully';
      case 'Es':
        return 'Reportado con éxito';
      case '中文':
        return '报告成功';
      case 'हिन्दी':
        return 'सफलतापूर्वक रिपोर्ट किया गया';
      case 'Português':
        return 'Relatado com sucesso';
      case 'Русский':
        return 'Успешно отправлено';
      case '日本語':
        return '正常に報告されました';
      case 'Français':
        return 'Rapporté avec succès';
      case 'Deutsch':
        return 'Erfolgreich gemeldet';
      default:
        return 'Reported successfully';
    }
  }
  String chooseThemeText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'اختر المظهر';
      case 'en':
        return 'Choose Theme';
      default:
        return 'Choose Theme';
    }
  }
  String lightModeText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الوضع الفاتح';
      case 'en':
        return 'Light Mode';
      default:
        return 'Light Mode';
    }
  }
  String darkModeText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الوضع الداكن';
      case 'en':
        return 'Dark Mode';
      default:
        return 'Dark Mode';
    }
  }
  String continueText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'متابعة';
      case 'en':
        return 'Continue';
      default:
        return 'Continue';
    }
  }
  String confirmSettingsText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تأكيد الإعدادات';
      case 'en':
        return 'Confirm Settings';
      default:
        return 'Confirm Settings';
    }
  }
  String confirmSettingsMessageText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'سيتم تطبيق الإعدادات الجديدة';
      case 'en':
        return 'The new settings will be applied';
      default:
        return 'The new settings will be applied';
    }
  }
  String cancelText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'إلغاء';
      case 'en':
        return 'Cancel';
      default:
        return 'Cancel';
    }
  }
  String completeAllFieldsText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'يرجى إكمال جميع الحقول المطلوبة';
      case 'en':
        return 'Please complete all required fields';
      case 'Es':
        return 'Por favor complete todos los campos requeridos';
      case '中文':
        return '请填写所有必填字段';
      case 'हिन्दी':
        return 'कृपया सभी आवश्यक फ़ील्ड भरें';
      case 'Português':
        return 'Por favor, preencha todos os campos obrigatórios';
      case 'Русский':
        return 'Пожалуйста, заполните все обязательные поля';
      case '日本語':
        return '必須項目をすべて入力してください';
      case 'Français':
        return 'Veuillez remplir tous les champs obligatoires';
      case 'Deutsch':
        return 'Bitte füllen Sie alle erforderlichen Felder aus';
      default:
        return 'Please complete all required fields';
    }
  }
  String selectGenderText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الرجاء اختيار الجنس';
      case 'en':
        return 'Please select your gender';
      case 'Es':
        return 'Por favor seleccione su género';
      case '中文':
        return '请选择您的性别';
      case 'हिन्दी':
        return 'कृपया अपना लिंग चुनें';
      case 'Português':
        return 'Por favor, selecione seu gênero';
      case 'Русский':
        return 'Пожалуйста, выберите ваш пол';
      case '日本語':
        return '性別を選択してください';
      case 'Français':
        return 'Veuillez sélectionner votre genre';
      case 'Deutsch':
        return 'Bitte wählen Sie Ihr Geschlecht';
      default:
        return 'Please select your gender';
    }
  }
  String selectDateText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الرجاء اختيار تاريخ الميلاد';
      case 'en':
        return 'Please select your date of birth';
      case 'Es':
        return 'Por favor seleccione su fecha de nacimiento';
      case '中文':
        return '请选择您的出生日期';
      case 'हिन्दी':
        return 'कृपया अपनी जन्म तिथि चुनें';
      case 'Português':
        return 'Por favor, selecione sua data de nascimento';
      case 'Русский':
        return 'Пожалуйста, выберите дату рождения';
      case '日本語':
        return '生年月日を選択してください';
      case 'Français':
        return 'Veuillez sélectionner votre date de naissance';
      case 'Deutsch':
        return 'Bitte wählen Sie Ihr Geburtsdatum';
      default:
        return 'Please select your date of birth';
    }
  }
  String enterPhoneNumbersText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الرجاء إدخال رقمي الهاتف';
      case 'en':
        return 'Please enter both phone numbers';
      case 'Es':
        return 'Por favor ingrese ambos números de teléfono';
      case '中文':
        return '请输入两个电话号码';
      case 'हिन्दी':
        return 'कृपया दोनों फ़ोन नंबर दर्ज करें';
      case 'Português':
        return 'Por favor, insira ambos os números de telefone';
      case 'Русский':
        return 'Пожалуйста, введите оба номера телефона';
      case '日本語':
        return '両方の電話番号を入力してください';
      case 'Français':
        return 'Veuillez entrer les deux numéros de téléphone';
      case 'Deutsch':
        return 'Bitte geben Sie beide Telefonnummern ein';
      default:
        return 'Please enter both phone numbers';
    }
  }
  String profileUpdatedSuccessText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تم تحديث الملف الشخصي بنجاح';
      case 'en':
        return 'Profile updated successfully';
      case 'Es':
        return 'Perfil actualizado con éxito';
      case '中文':
        return '个人资料更新成功';
      case 'हिन्दी':
        return 'प्रोफ़ाइल सफलतापूर्वक अपडेट की गई';
      case 'Português':
        return 'Perfil atualizado com sucesso';
      case 'Русский':
        return 'Профиль успешно обновлен';
      case '日本語':
        return 'プロフィールが正常に更新されました';
      case 'Français':
        return 'Profil mis à jour avec succès';
      case 'Deutsch':
        return 'Profil erfolgreich aktualisiert';
      default:
        return 'Profile updated successfully';
    }
  }
  String updateFailedText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'فشل تحديث الملف الشخصي';
      case 'en':
        return 'Failed to update profile';
      case 'Es':
        return 'Error al actualizar el perfil';
      case '中文':
        return '个人资料更新失败';
      case 'हिन्दी':
        return 'प्रोफ़ाइल अपडेट करने में विफल';
      case 'Português':
        return 'Falha ao atualizar o perfil';
      case 'Русский':
        return 'Не удалось обновить профиль';
      case '日本語':
        return 'プロフィールの更新に失敗しました';
      case 'Français':
        return 'Échec de la mise à jour du profil';
      case 'Deutsch':
        return 'Profilaktualisierung fehlgeschlagen';
      default:
        return 'Failed to update profile';
    }
  }
// Add these methods to your Language class
  String completeProfilePromptText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'يرجى إكمال ملف التعريف الخاص بك للحصول على تجربة أفضل';
      case 'en':
        return 'Please complete your profile for a better experience';
      case 'Es':
        return 'Complete su perfil para una mejor experiencia';
      case '中文':
        return '请完善您的个人资料以获得更好的体验';
      case 'हिन्दी':
        return 'बेहतर अनुभव के लिए कृपया अपनी प्रोफ़ाइल पूरी करें';
      case 'Português':
        return 'Complete seu perfil para uma melhor experiência';
      case 'Русский':
        return 'Пожалуйста, заполните свой профиль для лучшего опыта';
      case '日本語':
        return 'より良い体験のためにプロフィールを完成させてください';
      case 'Français':
        return 'Veuillez compléter votre profil pour une meilleure expérience';
      case 'Deutsch':
        return 'Bitte vervollständigen Sie Ihr Profil für ein besseres Erlebnis';
      default:
        return 'Please complete your profile for a better experience';
    }
  }
  String whyCompleteProfileText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'لماذا يجب أن تكمل ملفك الشخصي:';
      case 'en':
        return 'Why complete your profile:';
      case 'Es':
        return '¿Por qué completar tu perfil:';
      case '中文':
        return '为什么要完善您的个人资料：';
      case 'हिन्दी':
        return 'अपनी प्रोफ़ाइल को पूरा क्यों करें:';
      case 'Português':
        return 'Por que completar seu perfil:';
      case 'Русский':
        return 'Почему нужно заполнить профиль:';
      case '日本語':
        return 'プロフィールを完成させる理由：';
      case 'Français':
        return 'Pourquoi compléter votre profil :';
      case 'Deutsch':
        return 'Warum Sie Ihr Profil vervollständigen sollten:';
      default:
        return 'Why complete your profile:';
    }
  }
  String betterExperienceText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'للحصول على تجربة أفضل مع التطبيق';
      case 'en':
        return 'For a better experience with the app';
      case 'Es':
        return 'Para una mejor experiencia con la aplicación';
      case '中文':
        return '获得更好的应用体验';
      case 'हिन्दी':
        return 'ऐप के साथ बेहतर अनुभव के लिए';
      case 'Português':
        return 'Para uma melhor experiência com o aplicativo';
      case 'Русский':
        return 'Для лучшего опыта работы с приложением';
      case '日本語':
        return 'アプリでのより良い体験のために';
      case 'Français':
        return 'Pour une meilleure expérience avec l\'application';
      case 'Deutsch':
        return 'Für ein besseres Erlebnis mit der App';
      default:
        return 'For a better experience with the app';
    }
  }
  String personalizedContentText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'للحصول على محتوى مخصص لك';
      case 'en':
        return 'To get personalized content';
      case 'Es':
        return 'Para obtener contenido personalizado';
      case '中文':
        return '获取个性化内容';
      case 'हिन्दी':
        return 'पर्सनलाइज्ड कंटेंट पाने के लिए';
      case 'Português':
        return 'Para obter conteúdo personalizado';
      case 'Русский':
        return 'Для получения персонализированного контента';
      case '日本語':
        return 'パーソナライズされたコンテンツを取得するため';
      case 'Français':
        return 'Pour obtenir un contenu personnalisé';
      case 'Deutsch':
        return 'Um personalisierte Inhalte zu erhalten';
      default:
        return 'To get personalized content';
    }
  }
  String connectWithOthersText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'للتواصل بشكل أفضل مع الآخرين';
      case 'en':
        return 'To better connect with others';
      case 'Es':
        return 'Para conectarse mejor con otros';
      case '中文':
        return '更好地与他人联系';
      case 'हिन्दी':
        return 'दूसरों के साथ बेहतर जुड़ाव के लिए';
      case 'Português':
        return 'Para se conectar melhor com outras pessoas';
      case 'Русский':
        return 'Для лучшего взаимодействия с другими';
      case '日本語':
        return '他の人ともっと繋がるために';
      case 'Français':
        return 'Pour mieux vous connecter avec les autres';
      case 'Deutsch':
        return 'Um besser mit anderen in Kontakt zu treten';
      default:
        return 'To better connect with others';
    }
  }
  String skipForNowText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تخطي الآن';
      case 'en':
        return 'Skip for now';
      case 'Es':
        return 'Omitir por ahora';
      case '中文':
        return '暂时跳过';
      case 'हिन्दी':
        return 'अभी के लिए छोड़ें';
      case 'Português':
        return 'Pular por enquanto';
      case 'Русский':
        return 'Пропустить сейчас';
      case '日本語':
        return '今はスキップ';
      case 'Français':
        return 'Ignorer pour le moment';
      case 'Deutsch':
        return 'Vorerst überspringen';
      default:
        return 'Skip for now';
    }
  }
  String completeNowText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'أكمل الآن';
      case 'en':
        return 'Complete now';
      case 'Es':
        return 'Completar ahora';
      case '中文':
        return '立即完成';
      case 'हिन्दी':
        return 'अभी पूरा करें';
      case 'Português':
        return 'Completar agora';
      case 'Русский':
        return 'Заполнить сейчас';
      case '日本語':
        return '今すぐ完了する';
      case 'Français':
        return 'Compléter maintenant';
      case 'Deutsch':
        return 'Jetzt vervollständigen';
      default:
        return 'Complete now';
    }
  }
  String tAddPostText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'إضافة منشور';
      case 'en':
        return 'Add Post';
      case 'Es':
        return 'Añadir Publicación';
      case '中文':
        return '添加帖子';
      case 'हिन्दी':
        return 'पोस्ट जोड़ें';
      case 'Português':
        return 'Adicionar Publicação';
      case 'Русский':
        return 'Добавить публикацию';
      case '日本語':
        return '投稿を追加';
      case 'Français':
        return 'Ajouter une publication';
      case 'Deutsch':
        return 'Beitrag hinzufügen';
      default:
        return 'Add Post';
    }
  }
  String tMoreOptionsText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'خيارات أكثر';
      case 'en':
        return 'More Options';
      case 'Es':
        return 'Más Opciones';
      case '中文':
        return '更多选项';
      case 'हिन्दी':
        return 'अधिक विकल्प';
      case 'Português':
        return 'Mais Opções';
      case 'Русский':
        return 'Дополнительные опции';
      case '日本語':
        return 'その他のオプション';
      case 'Français':
        return 'Plus d\'options';
      case 'Deutsch':
        return 'Weitere Optionen';
      default:
        return 'More Options';
    }
  }
  String tLaterText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'لاحقاً';
      case 'en':
        return 'Later';
      case 'Es':
        return 'Después';
      case '中文':
        return '稍后';
      case 'हिन्दी':
        return 'बाद में';
      case 'Português':
        return 'Depois';
      case 'Русский':
        return 'Позже';
      case '日本語':
        return '後で';
      case 'Français':
        return 'Plus tard';
      case 'Deutsch':
        return 'Später';
      default:
        return 'Later';
    }
  }
  String tUpdateNowText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تحديث الآن';
      case 'en':
        return 'Update Now';
      case 'Es':
        return 'Actualizar Ahora';
      case '中文':
        return '立即更新';
      case 'हिन्दी':
        return 'अभी अपडेट करें';
      case 'Português':
        return 'Atualizar Agora';
      case 'Русский':
        return 'Обновить сейчас';
      case '日本語':
        return '今すぐ更新';
      case 'Français':
        return 'Mettre à jour maintenant';
      case 'Deutsch':
        return 'Jetzt aktualisieren';
      default:
        return 'Update Now';
    }
  }
  String loadFailedText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'فشل تحميل الملف الشخصي';
      case 'en':
        return 'Failed to load profile';
      case 'Es':
        return 'Error al cargar el perfil';
      case '中文':
        return '加载个人资料失败';
      case 'हिन्दी':
        return 'प्रोफ़ाइल लोड करने में विफल';
      case 'Português':
        return 'Falha ao carregar o perfil';
      case 'Русский':
        return 'Не удалось загрузить профиль';
      case '日本語':
        return 'プロフィールの読み込みに失敗しました';
      case 'Français':
        return 'Échec du chargement du profil';
      case 'Deutsch':
        return 'Fehler beim Laden des Profils';
      default:
        return 'Failed to load profile';
    }
  }
  String retryText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'إعادة المحاولة';
      case 'en':
        return 'Retry';
      case 'Es':
        return 'Reintentar';
      case '中文':
        return '重试';
      case 'हिन्दी':
        return 'पुनः प्रयास करें';
      case 'Português':
        return 'Tentar novamente';
      case 'Русский':
        return 'Повторить';
      case '日本語':
        return '再試行';
      case 'Français':
        return 'Réessayer';
      case 'Deutsch':
        return 'Wiederholen';
      default:
        return 'Retry';
    }
  }String errorInitializingText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'خطأ في تهيئة الملف الشخصي';
      case 'en':
        return 'Error initializing profile';
      default:
        return 'Error initializing profile';
    }
  }
  String selectCityText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'يرجى اختيار المدينة';
      case 'en':
        return 'Please select a city';
      case 'Es':
        return 'Por favor seleccione una ciudad';
      case '中文':
        return '请选择城市';
      case 'हिन्दी':
        return 'कृपया एक शहर चुनें';
      case 'Português':
        return 'Por favor, selecione uma cidade';
      case 'Русский':
        return 'Пожалуйста, выберите город';
      case '日本語':
        return '都市を選択してください';
      case 'Français':
        return 'Veuillez sélectionner une ville';
      case 'Deutsch':
        return 'Bitte wählen Sie eine Stadt';
      default:
        return 'Please select a city';
    }
  }
  String selectCountryText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'يرجى اختيار الدولة';
      case 'en':
        return 'Please select a country';
      case 'Es':
        return 'Por favor seleccione un país';
      case '中文':
        return '请选择国家';
      case 'हिन्दी':
        return 'कृपया एक देश चुनें';
      case 'Português':
        return 'Por favor, selecione um país';
      case 'Русский':
        return 'Пожалуйста, выберите страну';
      case '日本語':
        return '国を選択してください';
      case 'Français':
        return 'Veuillez sélectionner un pays';
      case 'Deutsch':
        return 'Bitte wählen Sie ein Land';
      default:
        return 'Please select a country';
    }
  }
  String errorUploadingImageText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'خطأ في تحميل الصورة';
      case 'en':
        return 'Error uploading image';
      default:
        return 'Error uploading image';
    }
  }
  String confirmText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تأكيد';
      case 'en':
        return 'Confirm';
      default:
        return 'Confirm';
    }
  }
  String tLocationText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الموقع';
      case 'en':
        return 'Location';
      case 'Es':
        return 'Ubicación';
      case '中文':
        return '位置';
      case 'हिन्दी':
        return 'स्थान';
      case 'Português':
        return 'Localização';
      case 'Русский':
        return 'Местоположение';
      case '日本語':
        return '場所';
      case 'Français':
        return 'Emplacement';
      case 'Deutsch':
        return 'Standort';
      default:
        return '';
    }
  }
  String tDetailsText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'التفاصيل';
      case 'en':
        return 'Details';
      case 'Es':
        return 'Detalles';
      case '中文':
        return '详细信息';
      case 'हिन्दी':
        return 'विवरण';
      case 'Português':
        return 'Detalhes';
      case 'Русский':
        return 'Подробности';
      case '日本語':
        return '詳細';
      case 'Français':
        return 'Détails';
      case 'Deutsch':
        return 'Details';
      default:
        return '';
    }
  }
  String tNoChangesText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'لم يتم إجراء أي تغييرات';
      case 'en':
        return 'No changes made';
      case 'Es':
        return 'Sin cambios realizados';
      case '中文':
        return '未作更改';
      case 'हिन्दी':
        return 'कोई बदलाव नहीं किया गया';
      case 'Português':
        return 'Nenhuma alteração feita';
      case 'Русский':
        return 'Изменений не внесено';
      case '日本語':
        return '変更はありません';
      case 'Français':
        return 'Aucune modification effectuée';
      case 'Deutsch':
        return 'Keine Änderungen vorgenommen';
      default:
        return '';
    }
  }
  String tPostUpdatedSuccessfully() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تم تحديث المنشور بنجاح';
      case 'en':
        return 'Post updated successfully';
      case 'Es':
        return 'Publicación actualizada con éxito';
      case '中文':
        return '帖子更新成功';
      case 'हिन्दी':
        return 'पोस्ट सफलतापूर्वक अपडेट किया गया';
      case 'Português':
        return 'Postagem atualizada com sucesso';
      case 'Русский':
        return 'Пост успешно обновлен';
      case '日本語':
        return '投稿が正常に更新されました';
      case 'Français':
        return 'Publication mise à jour avec succès';
      case 'Deutsch':
        return 'Beitrag erfolgreich aktualisiert';
      default:
        return '';
    }
  }
  String tErrorUpdatingPost() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'خطأ في تحديث المنشور';
      case 'en':
        return 'Error updating post';
      case 'Es':
        return 'Error al actualizar la publicación';
      case '中文':
        return '更新帖子时出错';
      case 'हिन्दी':
        return 'पोस्ट अपडेट करने में त्रुटि';
      case 'Português':
        return 'Erro ao atualizar postagem';
      case 'Русский':
        return 'Ошибка обновления поста';
      case '日本語':
        return '投稿の更新エラー';
      case 'Français':
        return 'Erreur lors de la mise à jour du post';
      case 'Deutsch':
        return 'Fehler beim Aktualisieren des Beitrags';
      default:
        return '';
    }
  }
  String tAddMediaText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'إضافة وسائط';
      case 'es':
        return 'Agregar medios';
      default:
        return 'Add Media';
    }
  }
  String tChoosePhotosText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'اختر الصور';
      case 'es':
        return 'Elegir fotos';
      default:
        return 'Choose Photos';
    }
  }
  String tChooseVideoText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'اختر فيديو';
      case 'es':
        return 'Elegir video';
      default:
        return 'Choose Video';
    }
  }
  String tSelectFromGalleryText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'اختر من المعرض';
      case 'es':
        return 'Seleccionar de la galería';
      default:
        return 'Select from gallery';
    }
  }
  String tProcessingMediaText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'جاري معالجة الوسائط...';
      case 'es':
        return 'Procesando medios...';
      default:
        return 'Processing media...';
    }
  }
  String tMaxImagesLimitText(int max) {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'لقد تجاوزت الحد الأقصى المسموح لعدد الصور المختارة ($max صورة).';
      case 'es':
        return 'Has superado el número máximo permitido de imágenes seleccionadas ($max imágenes).';
      default:
        return 'You have exceeded the maximum allowed number of selected images ($max images).';
    }
  }
  String tOkText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'موافق';
      case 'es':
        return 'Aceptar';
      default:
        return 'OK';
    }
  }
  String tRemainingImagesText(int count) {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'متبقي $count صور';
      case 'es':
        return '$count restantes';
      default:
        return '$count remaining';
    }
  }
  String tInvalidNumberText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الرجاء إدخال رقم صحيح';
      case 'en':
        return 'Please enter a valid number';
      case 'Es':
        return 'Por favor ingrese un número válido';
      default:
        return 'Please enter a valid number';
    }
  }
  String tPriceNotRequiredText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'السعر غير مطلوب لهذه الفئة';
      case 'en':
        return 'Price not required for this category';
      case 'Es':
        return 'Precio no requerido para esta categoría';
      default:
        return 'Price not required for this category';
    }
  }
  String tDayText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'يوم';
      case 'en':
        return 'Day';
      case 'Es':
        return 'Día';
      default:
        return 'Day';
    }
  }
  String tSelectImagesText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الرجاء اختيار صورة واحدة على الأقل';
      case 'en':
        return 'Please select at least one image';
      case 'Es':
        return 'Por favor seleccione al menos una imagen';
      default:
        return 'Please select at least one image';
    }
  }
  String tFillAllFieldsText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الرجاء ملء جميع الحقول المطلوبة';
      case 'en':
        return 'Please fill all required fields';
      case 'Es':
        return 'Por favor complete todos los campos requeridos';
      default:
        return 'Please fill all required fields';
    }
  }
  String tSelectCategoryText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الرجاء اختيار الفئة والفئة الفرعية';
      case 'en':
        return 'Please select a category and subcategory';
      case 'Es':
        return 'Por favor seleccione una categoría y subcategoría';
      default:
        return 'Please select a category and subcategory';
    }
  }
  String tEnterPriceText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الرجاء إدخال السعر';
      case 'en':
        return 'Please enter a price';
      case 'Es':
        return 'Por favor ingrese un precio';
      default:
        return 'Please enter a price';
    }
  }
  String tFeaturesNotAvailableText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الميزات غير متوفرة لهذه الفئة';
      case 'en':
        return 'Features not available for this category';
      case 'Es':
        return 'Características no disponibles para esta categoría';
      case '中文':
        return '此类别不可用功能';
      case 'हिन्दी':
        return 'इस श्रेणी के लिए सुविधाएं उपलब्ध नहीं हैं';
      case 'Português':
        return 'Recursos não disponíveis para esta categoria';
      case 'Русский':
        return 'Функции недоступны для этой категории';
      case '日本語':
        return 'このカテゴリーでは機能が利用できません';
      case 'Français':
        return 'Fonctionnalités non disponibles pour cette catégorie';
      case 'Deutsch':
        return 'Funktionen für diese Kategorie nicht verfügbar';
      default:
        return 'Features not available for this category';
    }
  }
  String tCreateText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'إنشاء';
      case 'en':
        return 'Create';
      case 'Es':
        return 'Crear';
      default:
        return 'Create';
    }
  }
  String tPostCreatedSuccessText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تم إنشاء المنشور بنجاح';
      case 'en':
        return 'Post created successfully';
      case 'Es':
        return 'Publicación creada exitosamente';
      default:
        return 'Post created successfully';
    }
  }
  String tContentTooLargeText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'المحتوى كبير جداً';
      case 'en':
        return 'Content too large';
      case 'Es':
        return 'Contenido demasiado grande';
      default:
        return 'Content too large';
    }
  }
  String tFileSizeLimitText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الرجاء اختيار ملف أصغر من 20 ميجابايت';
      case 'en':
        return 'Please select a file smaller than 20MB';
      case 'Es':
        return 'Por favor seleccione un archivo menor a 20MB';
      default:
        return 'Please select a file smaller than 20MB';
    }
  }
  String tErrorText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'خطأ';
      case 'en':
        return 'Error';
      case 'Es':
        return 'Error';
      default:
        return 'Error';
    }
  }
  String tImageText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الصور';
      case 'en':
        return 'Images';
      case 'Es':
        return 'Imágenes';
      case '中文':
        return '图片';
      case 'हिन्दी':
        return 'छवियां';
      case 'Português':
        return 'Imagens';
      case 'Русский':
        return 'Изображения';
      case '日本語':
        return '画像';
      case 'Français':
        return 'Images';
      case 'Deutsch':
        return 'Bilder';
      default:
        return 'Images';
    }
  }
  String tTitleText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'العنوان';
      case 'en':
        return 'Title';
      case 'Es':
        return 'Título';
      case '中文':
        return '标题';
      case 'हिन्दी':
        return 'शीर्षक';
      case 'Português':
        return 'Título';
      case 'Русский':
        return 'Заголовок';
      case '日本語':
        return 'タイトル';
      case 'Français':
        return 'Titre';
      case 'Deutsch':
        return 'Titel';
      default:
        return 'Title';
    }
  }
  String tDescriptionText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الوصف';
      case 'en':
        return 'Description';
      case 'Es':
        return 'Descripción';
      case '中文':
        return '描述';
      case 'हिन्दी':
        return 'विवरण';
      case 'Português':
        return 'Descrição';
      case 'Русский':
        return 'Описание';
      case '日本語':
        return '説明';
      case 'Français':
        return 'Description';
      case 'Deutsch':
        return 'Beschreibung';
      default:
        return 'Description';
    }
  }
  String tCategoryText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'التصنيف';
      case 'en':
        return 'Category';
      case 'Es':
        return 'Categoría';
      case '中文':
        return '类别';
      case 'हिन्दी':
        return 'श्रेणी';
      case 'Português':
        return 'Categoria';
      case 'Русский':
        return 'Категория';
      case '日本語':
        return 'カテゴリー';
      case 'Français':
        return 'Catégorie';
      case 'Deutsch':
        return 'Kategorie';
      default:
        return 'Category';
    }
  }
  String tPriceText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'السعر';
      case 'en':
        return 'Price';
      case 'Es':
        return 'Precio';
      case '中文':
        return '价格';
      case 'हिन्दी':
        return 'मूल्य';
      case 'Português':
        return 'Preço';
      case 'Русский':
        return 'Цена';
      case '日本語':
        return '価格';
      case 'Français':
        return 'Prix';
      case 'Deutsch':
        return 'Preis';
      default:
        return 'Price';
    }
  }
  String tCurrencyText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'العملة';
      case 'en':
        return 'Currency';
      case 'Es':
        return 'Moneda';
      case '中文':
        return '货币';
      case 'हिन्दी':
        return 'मुद्रा';
      case 'Português':
        return 'Moeda';
      case 'Русский':
        return 'Валюта';
      case '日本語':
        return '通貨';
      case 'Français':
        return 'Devise';
      case 'Deutsch':
        return 'Währung';
      default:
        return 'Currency';
    }
  }
  String tFeaturedText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'مميز';
      case 'en':
        return 'Featured';
      case 'Es':
        return 'Destacado';
      case '中文':
        return '特色';
      case 'हिन्दी':
        return 'विशेष';
      case 'Português':
        return 'Destaque';
      case 'Русский':
        return 'Рекомендуемые';
      case '日本語':
        return 'おすすめ';
      case 'Français':
        return 'En vedette';
      case 'Deutsch':
        return 'Empfohlen';
      default:
        return 'Featured';
    }
  }
  String tDurationText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'المدة';
      case 'en':
        return 'Duration';
      case 'Es':
        return 'Duración';
      case '中文':
        return '时长';
      case 'हिन्दी':
        return 'अवधि';
      case 'Português':
        return 'Duração';
      case 'Русский':
        return 'Продолжительность';
      case '日本語':
        return '期間';
      case 'Français':
        return 'Durée';
      case 'Deutsch':
        return 'Dauer';
      default:
        return 'Duration';
    }
  }
  String tCreatePostText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'إنشاء منشور';
      case 'en':
        return 'Create Post';
      case 'Es':
        return 'Crear Publicación';
      case '中文':
        return '创建帖子';
      case 'हिन्दी':
        return 'पोस्ट बनाएं';
      case 'Português':
        return 'Criar Post';
      case 'Русский':
        return 'Создать пост';
      case '日本語':
        return '投稿を作成';
      case 'Français':
        return 'Créer un post';
      case 'Deutsch':
        return 'Beitrag erstellen';
      default:
        return 'Create Post';
    }
  }
  String tRequiredText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'هذا الحقل مطلوب';
      case 'en':
        return 'This field is required';
      case 'Es':
        return 'Este campo es requerido';
      case '中文':
        return '此字段为必填项';
      case 'हिन्दी':
        return 'यह फ़ील्ड आवश्यक है';
      case 'Português':
        return 'Este campo é obrigatório';
      case 'Русский':
        return 'Это поле обязательно';
      case '日本語':
        return 'この項目は必須です';
      case 'Français':
        return 'Ce champ est requis';
      case 'Deutsch':
        return 'Dieses Feld ist erforderlich';
      default:
        return 'This field is required';
    }
  }
  String tNextText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'التالي';
      case 'en':
        return 'Next';
      case 'Es':
        return 'Siguiente';
      case '中文':
        return '下一步';
      case 'हिन्दी':
        return 'अगला';
      case 'Português':
        return 'Próximo';
      case 'Русский':
        return 'Далее';
      case '日本語':
        return '次へ';
      case 'Français':
        return 'Suivant';
      case 'Deutsch':
        return 'Weiter';
      default:
        return 'Next';
    }
  }
  String tPreviousText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'السابق';
      case 'en':
        return 'Previous';
      case 'Es':
        return 'Anterior';
      case '中文':
        return '上一步';
      case 'हिन्दी':
        return 'पिछला';
      case 'Português':
        return 'Anterior';
      case 'Русский':
        return 'Назад';
      case '日本語':
        return '戻る';
      case 'Français':
        return 'Précédent';
      case 'Deutsch':
        return 'Zurück';
      default:
        return 'Previous';
    }
  }
  String tTypeText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'النوع';
      case 'en':
        return 'Type';
      case 'Es':
        return 'Tipo';
      case '中文':
        return '类型';
      case 'हिन्दी':
        return 'प्रकार';
      case 'Português':
        return 'Tipo';
      case 'Русский':
        return 'Тип';
      case '日本語':
        return 'タイプ';
      case 'Français':
        return 'Type';
      case 'Deutsch':
        return 'Typ';
      default:
        return 'Type';
    }
  }
  String tPurchasePointsText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'شراء نقاط';
      case 'en':
        return 'Purchase Points';
      case 'Es':
        return 'Comprar Puntos';
      case '中文':
        return '购买积分';
      case 'हिन्दी':
        return 'पॉइंट्स खरीदें';
      case 'Português':
        return 'Comprar Pontos';
      case 'Русский':
        return 'Купить баллы';
      case '日本語':
        return 'ポイントを購入';
      case 'Français':
        return 'Acheter des points';
      case 'Deutsch':
        return 'Punkte kaufen';
      default:
        return 'Purchase Points';
    }
  }
  String tInsufficientBalanceText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'رصيد غير كافي';
      case 'en':
        return 'Insufficient Balance';
      case 'Es':
        return 'Saldo Insuficiente';
      case '中文':
        return '余额不足';
      case 'हिन्दी':
        return 'अपर्याप्त शेष राशि';
      case 'Português':
        return 'Saldo Insuficiente';
      case 'Русский':
        return 'Недостаточно средств';
      case '日本語':
        return '残高不足';
      case 'Français':
        return 'Solde insuffisant';
      case 'Deutsch':
        return 'Unzureichendes Guthaben';
      default:
        return 'Insufficient Balance';
    }
  }
  String tPointsDeductionText(int points, String badge, int duration) {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'سيتم خصم $points نقطة مقابل شارة $badge لمدة $duration يوم';
      case 'en':
        return 'Will deduct $points points for $badge badge for $duration days';
      case 'Es':
        return 'Se deducirán $points puntos por la insignia $badge durante $duration días';
      case '中文':
        return '将扣除 $points 点数用于 $badge 徽章，持续 $duration 天';
      case 'हिन्दी':
        return '$badge बैज के लिए $duration दिनों के लिए $points अंक काटे जाएंगे';
      case 'Português':
        return 'Será deduzido $points pontos para o distintivo $badge por $duration dias';
      case 'Русский':
        return 'Будет списано $points баллов за значок $badge на $duration дней';
      case '日本語':
        return '$badge バッジに対して $points ポイントを $duration 日間差し引きます';
      case 'Français':
        return 'Déduira $points points pour le badge $badge pendant $duration jours';
      case 'Deutsch':
        return 'Es werden $points Punkte für das $badge-Abzeichen für $duration Tage abgezogen';
      default:
        return 'Will deduct $points points for $badge badge for $duration days';
    }
  }
  String tDeviceTextHome() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'أجهزة';
      case 'en':
        return 'devices';
      case 'Es':
        return 'dispositivos';
      case '中文':
        return '设备';
      case 'हिन्दी':
        return 'डिवाइसेस';
      case 'Português':
        return 'dispositivos';
      case 'Русский':
        return 'устройства';
      case '日本語':
        return 'デバイス';
      case 'Français':
        return 'dispositifs';
      case 'Deutsch':
        return 'Geräte';
      default:
        return '';
    }
  }
  String tRealEstateTextHome() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'عقارات';
      case 'en':
        return 'real estate';
      case 'Es':
        return 'bienes raíces';
      case '中文':
        return '房地产';
      case 'हिन्दी':
        return 'रियल एस्टेट';
      case 'Português':
        return 'imóveis';
      case 'Русский':
        return 'недвижимость';
      case '日本語':
        return '不動産';
      case 'Français':
        return 'immobilier';
      case 'Deutsch':
        return 'Immobilien';
      default:
        return '';
    }
  }
  String tVideoTextHome() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'فيديو';
      case 'en':
        return 'video';
      case 'Es':
        return 'video';
      case '中文':
        return '视频';
      case 'हिन्दी':
        return 'वीडियो';
      case 'Português':
        return 'vídeo';
      case 'Русский':
        return 'видео';
      case '日本語':
        return 'ビデオ';
      case 'Français':
        return 'vidéo';
      case 'Deutsch':
        return 'Video';
      default:
        return '';
    }
  }
  String tCarsTextHome() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'سيارات';
      case 'en':
        return 'cars';
      case 'Es':
        return 'coches';
      case '中文':
        return '汽车';
      case 'हिन्दी':
        return 'कारें';
      case 'Português':
        return 'carros';
      case 'Русский':
        return 'машины';
      case '日本語':
        return '車';
      case 'Français':
        return 'voitures';
      case 'Deutsch':
        return 'Autos';
      default:
        return '';
    }
  }
  String tServicesTextHome() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'خدمات';
      case 'en':
        return 'services';
      case 'Es':
        return 'servicios';
      case '中文':
        return '服务';
      case 'हिन्दी':
        return 'सेवाएँ';
      case 'Português':
        return 'serviços';
      case 'Русский':
        return 'услуги';
      case '日本語':
        return 'サービス';
      case 'Français':
        return 'services';
      case 'Deutsch':
        return 'Dienstleistungen';
      default:
        return '';
    }
  }
  String tNearYouText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'بالقرب';
      case 'en':
        return 'near';
      case 'Es':
        return 'cerca';
      case '中文':
        return '附近';
      case 'हिन्दी':
        return 'पास';
      case 'Português':
        return 'perto';
      case 'Русский':
        return 'рядом';
      case '日本語':
        return '近く';
      case 'Français':
        return 'près';
      case 'Deutsch':
        return 'in der Nähe';
      default:
        return '';
    }
  }
  String tProfileText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الملف الشخصي';
      case 'en':
        return 'Profile';
      case 'Es':
        return 'Perfil';
      case '中文':
        return '个人资料';
      case 'हिन्दी':
        return 'प्रोफ़ाइल';
      case 'Português':
        return 'Perfil';
      case 'Русский':
        return 'Профиль';
      case '日本語':
        return 'プロフィール';
      case 'Français':
        return 'Profil';
      case 'Deutsch':
        return 'Profil';
      default:
        return '';
    }
  }
  String tFavoriteText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'المفضلة';
      case 'en':
        return 'Favorite';
      case 'Es':
        return 'Favorito';
      case '中文':
        return '收藏';
      case 'हिन्दी':
        return 'पसंदीदा';
      case 'Português':
        return 'Favorito';
      case 'Русский':
        return 'Избранное';
      case '日本語':
        return 'お気に入り';
      case 'Français':
        return 'Favori';
      case 'Deutsch':
        return 'Favorit';
      default:
        return '';
    }
  }
  String tUpdateInfoText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تحديث المعلومات';
      case 'en':
        return 'Update Info';
      case 'Es':
        return 'Actualizar información';
      case '中文':
        return '更新信息';
      case 'हिन्दी':
        return 'जानकारी अपडेट करें';
      case 'Português':
        return 'Atualizar informações';
      case 'Русский':
        return 'Обновить информацию';
      case '日本語':
        return '情報を更新する';
      case 'Français':
        return 'Mettre à jour les informations';
      case 'Deutsch':
        return 'Informationen aktualisieren';
      default:
        return '';
    }
  }
  String tSwitchSubcategoryList() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تصنيف الخدمات';
      case 'en':
        return 'Category list';
      case 'es':
        return 'Lista de categorías';
      case 'zh':
        return '类别列表';
      case 'hi':
        return 'श्रेणी सूची';
      case 'pt':
        return 'Lista de categorias';
      case 'ru':
        return 'Список категорий';
      case 'ja':
        return 'カテゴリーリスト';
      case 'fr':
        return 'Liste des catégories';
      case 'de':
        return 'Kategorieliste';
      default:
        return 'Category list'; // Default to English instead of an empty string
    }
  }
  String tSettingsText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الإعدادات';
      case 'en':
        return 'Settings';
      case 'Es':
        return 'Ajustes';
      case '中文':
        return '设置';
      case 'हिन्दी':
        return 'सेटिंग्स';
      case 'Português':
        return 'Configurações';
      case 'Русский':
        return 'Настройки';
      case '日本語':
        return '設定';
      case 'Français':
        return 'Paramètres';
      case 'Deutsch':
        return 'Einstellungen';
      default:
        return '';
    }
  }
  String tChangeLanguageText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تغيير اللغة';
      case 'en':
        return 'Change Language';
      case 'Es':
        return 'Cambiar Idioma';
      case '中文':
        return '更改语言';
      case 'हिन्दी':
        return 'भाषा बदलें';
      case 'Português':
        return 'Alterar Idioma';
      case 'Русский':
        return 'Изменить язык';
      case '日本語':
        return '言語を変更';
      case 'Français':
        return 'Changer de Langue';
      case 'Deutsch':
        return 'Sprache ändern';
      default:
        return '';
    }
  }
  String tChangeEmailText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تغيير البريد الإلكتروني';
      case 'en':
        return 'Change Email';
      case 'Es':
        return 'Cambiar Correo Electrónico';
      case '中文':
        return '更改电子邮件';
      case 'हिन्दी':
        return 'ईमेल बदलें';
      case 'Português':
        return 'Alterar Email';
      case 'Русский':
        return 'Изменить адрес электронной почты';
      case '日本語':
        return 'メールを変更';
      case 'Français':
        return 'Changer d\'adresse e-mail';
      case 'Deutsch':
        return 'E-Mail ändern';
      default:
        return '';
    }
  }
  String tChangePasswordText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تغيير كلمة المرور';
      case 'en':
        return 'Change Password';
      case 'Es':
        return 'Cambiar Contraseña';
      case '中文':
        return '更改密码';
      case 'हिन्दी':
        return 'पासवर्ड बदलें';
      case 'Português':
        return 'Alterar Senha';
      case 'Русский':
        return 'Изменить пароль';
      case '日本語':
        return 'パスワードを変更';
      case 'Français':
        return 'Changer de mot de passe';
      case 'Deutsch':
        return 'Passwort ändern';
      default:
        return '';
    }
  }
  String tDarkModeText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الوضع الليلي';
      case 'en':
        return 'Dark Mode';
      case 'Es':
        return 'Modo Oscuro';
      case '中文':
        return '深色模式';
      case 'हिन्दी':
        return 'डार्क मोड';
      case 'Português':
        return 'Modo Escuro';
      case 'Русский':
        return 'Темный режим';
      case '日本語':
        return 'ダークモード';
      case 'Français':
        return 'Mode Sombre';
      case 'Deutsch':
        return 'Dunkelmodus';
      default:
        return '';
    }
  }
  String tLogoutText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تسجيل الخروج';
      case 'en':
        return 'Logout';
      case 'Es':
        return 'Cerrar sesión';
      case '中文':
        return '登出';
      case 'हिन्दी':
        return 'लॉग आउट';
      case 'Português':
        return 'Sair';
      case 'Русский':
        return 'Выйти';
      case '日本語':
        return 'ログアウト';
      case 'Français':
        return 'Déconnexion';
      case 'Deutsch':
        return 'Abmelden';
      default:
        return '';
    }
  }
  String tPasswordText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'كلمة المرور';
      case 'en':
        return 'Password';
      case 'Es':
        return 'Contraseña';
      case '中文':
        return '密码';
      case 'हिन्दी':
        return 'पासवर्ड';
      case 'Português':
        return 'Senha';
      case 'Русский':
        return 'Пароль';
      case '日本語':
        return 'パスワード';
      case 'Français':
        return 'Mot de passe';
      case 'Deutsch':
        return 'Passwort';
      default:
        return '';
    }
  }
  String tNewPasswordText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'كلمة المرور الجديدة';
      case 'en':
        return 'New Password';
      case 'Es':
        return 'Nueva Contraseña';
      case '中文':
        return '新密码';
      case 'हिन्दी':
        return 'नया पासवर्ड';
      case 'Português':
        return 'Nova Senha';
      case 'Русский':
        return 'Новый пароль';
      case '日本語':
        return '新しいパスワード';
      case 'Français':
        return 'Nouveau mot de passe';
      case 'Deutsch':
        return 'Neues Passwort';
      default:
        return '';
    }
  }
  String tSaveText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'حفظ';
      case 'en':
        return 'Save';
      case 'Es':
        return 'Guardar';
      case '中文':
        return '保存';
      case 'हिन्दी':
        return 'सहेजें';
      case 'Português':
        return 'Salvar';
      case 'Русский':
        return 'Сохранить';
      case '日本語':
        return '保存';
      case 'Français':
        return 'Enregistrer';
      case 'Deutsch':
        return 'Speichern';
      default:
        return 'Save';
    }
  }
  String tUpdateText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تحديث';
      case 'en':
        return 'Update';
      case 'Es':
        return 'Actualizar';
      case '中文':
        return '更新';
      case 'हिन्दी':
        return 'अपडेट';
      case 'Português':
        return 'Atualizar';
      case 'Русский':
        return 'Обновить';
      case '日本語':
        return '更新';
      case 'Français':
        return 'Mettre à jour';
      case 'Deutsch':
        return 'Aktualisieren';
      default:
        return 'Update';
    }
  }
  String tDeleteText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'حذف';
      case 'en':
        return 'Delete';
      case 'Es':
        return 'Eliminar';
      case '中文':
        return '删除';
      case 'हिन्दी':
        return 'हटाना';
      case 'Português':
        return 'Excluir';
      case 'Русский':
        return 'Удалить';
      case '日本語':
        return '削除';
      case 'Français':
        return 'Supprimer';
      case 'Deutsch':
        return 'Löschen';
      default:
        return 'Delete';
    }
  }
  String tPurchaseText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'شراء';
      case 'en':
        return 'Purchase';
      case 'Es':
        return 'Comprar';
      case '中文':
        return '购买';
      case 'हिन्दी':
        return 'खरीद';
      case 'Português':
        return 'Comprar';
      case 'Русский':
        return 'Покупка';
      case '日本語':
        return '購入';
      case 'Français':
        return 'Acheter';
      case 'Deutsch':
        return 'Kaufen';
      default:
        return 'Purchase';
    }
  }
  String tReportText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الإبلاغ';
      case 'en':
        return 'Report';
      case 'Es':
        return 'Reportar';
      case '中文':
        return '举报';
      case 'हिन्दी':
        return 'रिपोर्ट करें';
      case 'Português':
        return 'Denunciar';
      case 'Русский':
        return 'Сообщить';
      case '日本語':
        return '報告する';
      case 'Français':
        return 'Signaler';
      case 'Deutsch':
        return 'Melden';
      default:
        return 'Report';
    }
  }
  String tSubcategoryText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الفئة الفرعية';
      case 'en':
        return 'Subcategory';
      case 'Es':
        return 'Subcategoría';
      case '中文':
        return '子类别';
      case 'हिन्दी':
        return 'उपश्रेणी';
      case 'Português':
        return 'Subcategoria';
      case 'Русский':
        return 'Подкатегория';
      case '日本語':
        return 'サブカテゴリー';
      case 'Français':
        return 'Sous-catégorie';
      case 'Deutsch':
        return 'Unterkategorie';
      default:
        return 'Subcategory';
    }
  }
  String tCountryText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الدولة';
      case 'en':
        return 'Country';
      case 'Es':
        return 'País';
      case '中文':
        return '国家';
      case 'हिन्दी':
        return 'देश';
      case 'Português':
        return 'País';
      case 'Русский':
        return 'Страна';
      case '日本語':
        return '国';
      case 'Français':
        return 'Pays';
      case 'Deutsch':
        return 'Land';
      default:
        return 'Country';
    }
  }
  String tCityText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'المدينة';
      case 'en':
        return 'City';
      case 'Es':
        return 'Ciudad';
      case '中文':
        return '城市';
      case 'हिन्दी':
        return 'शहर';
      case 'Português':
        return 'Cidade';
      case 'Русский':
        return 'Город';
      case '日本語':
        return '市';
      case 'Français':
        return 'Ville';
      case 'Deutsch':
        return 'Stadt';
      default:
        return 'City';
    }
  }
  String tGenderText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الجنس';
      case 'en':
        return 'Gender';
      case 'Es':
        return 'Género';
      case '中文':
        return '性别';
      case 'हिन्दी':
        return 'लिंग';
      case 'Português':
        return 'Gênero';
      case 'Русский':
        return 'Пол';
      case '日本語':
        return '性別';
      case 'Français':
        return 'Genre';
      case 'Deutsch':
        return 'Geschlecht';
      default:
        return 'Gender';
    }
  }
  String tDateOfBirthText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تاريخ الميلاد';
      case 'en':
        return 'Date of Birth';
      case 'Es':
        return 'Fecha de Nacimiento';
      case '中文':
        return '出生日期';
      case 'हिन्दी':
        return 'जन्म तिथि';
      case 'Português':
        return 'Data de Nascimento';
      case 'Русский':
        return 'Дата рождения';
      case '日本語':
        return '生年月日';
      case 'Français':
        return 'Date de Naissance';
      case 'Deutsch':
        return 'Geburtsdatum';
      default:
        return 'Date of Birth';
    }
  }
  String tWhatsappNumberText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'رقم الواتساب';
      case 'en':
        return 'WhatsApp Number';
      case 'Es':
        return 'Número de WhatsApp';
      case '中文':
        return 'WhatsApp号码';
      case 'हिन्दी':
        return 'WhatsApp नंबर';
      case 'Português':
        return 'Número do WhatsApp';
      case 'Русский':
        return 'Номер WhatsApp';
      case '日本語':
        return 'WhatsApp番号';
      case 'Français':
        return 'Numéro WhatsApp';
      case 'Deutsch':
        return 'WhatsApp-Nummer';
      default:
        return 'WhatsApp Number';
    }
  }
  String tPhoneNumberText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'رقم الهاتف';
      case 'en':
        return 'Phone Number';
      case 'Es':
        return 'Número de teléfono';
      case '中文':
        return '电话号码';
      case 'हिन्दी':
        return 'फ़ोन नंबर';
      case 'Português':
        return 'Número de telefone';
      case 'Русский':
        return 'Номер телефона';
      case '日本語':
        return '電話番号';
      case 'Français':
        return 'Numéro de téléphone';
      case 'Deutsch':
        return 'Telefonnummer';
      default:
        return 'Phone Number';
    }
  }
  String tEditText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تعديل';
      case 'en':
        return 'Edit';
      case 'Es':
        return 'Editar';
      case '中文':
        return '编辑';
      case 'हिन्दी':
        return 'संपादित करें';
      case 'Português':
        return 'Editar';
      case 'Русский':
        return 'Редактировать';
      case '日本語':
        return '編集';
      case 'Français':
        return 'Modifier';
      case 'Deutsch':
        return 'Bearbeiten';
      default:
        return 'Edit';
    }
  }
  String tChangeCategoryText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تغيير الفئة';
      case 'en':
        return 'Change Category';
      case 'Es':
        return 'Cambiar Categoría';
      case '中文':
        return '更改类别';
      case 'हिन्दी':
        return 'श्रेणी बदलें';
      case 'Português':
        return 'Mudar Categoria';
      case 'Русский':
        return 'Изменить категорию';
      case '日本語':
        return 'カテゴリを変更';
      case 'Français':
        return 'Changer de catégorie';
      case 'Deutsch':
        return 'Kategorie ändern';
      default:
        return 'Change Category';
    }
  }
  String tChangeBadgeText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تغيير التمييز';
      case 'en':
        return 'Change Badge';
      case 'Es':
        return 'Cambiar Insignia';
      case '中文':
        return '更改徽章';
      case 'हिन्दी':
        return 'बैज बदलें';
      case 'Português':
        return 'Alterar Distintivo';
      case 'Русский':
        return 'Изменить значок';
      case '日本語':
        return 'バッジを変更';
      case 'Français':
        return 'Changer de badge';
      case 'Deutsch':
        return 'Abzeichen ändern';
      default:
        return 'Change Badge';
    }
  }
  String tPostsText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'المنشورات';
      case 'en':
        return 'Posts';
      case 'Es':
        return 'Publicaciones';
      case '中文':
        return '帖子';
      case 'हिन्दी':
        return 'पोस्ट्स';
      case 'Português':
        return 'Postagens';
      case 'Русский':
        return 'Посты';
      case '日本語':
        return '投稿';
      case 'Français':
        return 'Publications';
      case 'Deutsch':
        return 'Beiträge';
      default:
        return 'Posts';
    }
  }
  String tFollowersText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'المتابعين';
      case 'en':
        return 'Followers';
      case 'Es':
        return 'Seguidores';
      case '中文':
        return '粉丝';
      case 'हिन्दी':
        return 'फॉलोअर्स';
      case 'Português':
        return 'Seguidores';
      case 'Русский':
        return 'Подписчики';
      case '日本語':
        return 'フォロワー';
      case 'Français':
        return 'Abonnés';
      case 'Deutsch':
        return 'Follower';
      default:
        return 'Followers';
    }
  }
  String tFollowingText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'متابع';
      case 'en':
        return 'Following';
      case 'Es':
        return 'Siguiendo';
      case '中文':
        return '正在关注';
      case 'हिन्दी':
        return 'फॉलो कर रहे हैं';
      case 'Português':
        return 'Seguindo';
      case 'Русский':
        return 'Подписан';
      case '日本語':
        return 'フォロー中';
      case 'Français':
        return 'Abonnements';
      case 'Deutsch':
        return 'Folgen';
      default:
        return 'Following';
    }
  }
  String tOverviewText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'لمحة';
      case 'en':
        return 'Overview';
      case 'Es':
        return 'Resumen';
      case '中文':
        return '概览';
      case 'हिन्दी':
        return 'अवलोकन';
      case 'Português':
        return 'Visão Geral';
      case 'Русский':
        return 'Обзор';
      case '日本語':
        return '概要';
      case 'Français':
        return 'Aperçu';
      case 'Deutsch':
        return 'Übersicht';
      default:
        return 'Overview';
    }
  }
  String tStatusText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الحالة';
      case 'en':
        return 'Status';
      case 'Es':
        return 'Estado';
      case '中文':
        return '状态';
      case 'हिन्दी':
        return 'स्थिति';
      case 'Português':
        return 'Status';
      case 'Русский':
        return 'Статус';
      case '日本語':
        return 'ステータス';
      case 'Français':
        return 'Statut';
      case 'Deutsch':
        return 'Status';
      default:
        return 'Status';
    }
  }
  String tConvertPointsText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'ارسال النقاط';
      case 'en':
        return 'Send Points';
      case 'Es':
        return 'Enviar Puntos';
      case '中文':
        return '发送积分';
      case 'हिन्दी':
        return 'पॉइंट्स भेजें';
      case 'Português':
        return 'Enviar Pontos';
      case 'Русский':
        return 'Отправить баллы';
      case '日本語':
        return 'ポイントを送信';
      case 'Français':
        return 'Envoyer des Points';
      case 'Deutsch':
        return 'Punkte senden';
      default:
        return 'Send Points'; // Default to en if the language is not recognized
    }
  }
  String incompleteInformationText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'معلومات غير مكتملة';
      case 'en':
        return 'Incomplete Information';
      case 'Es':
        return 'Información Incompleta';
      case '中文':
        return '信息不完整';
      case 'हिन्दी':
        return 'अपूर्ण जानकारी';
      case 'Português':
        return 'Informação Incompleta';
      case 'Русский':
        return 'Неполная информация';
      case '日本語':
        return '情報が不完全です';
      case 'Français':
        return 'Information incomplète';
      case 'Deutsch':
        return 'Unvollständige Informationen';
      default:
        return 'Incomplete Information';
    }
  }
  String completeInformationText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'يرجى استكمال المعلومات الخاصة بك.';
      case 'en':
        return 'Please complete your information.';
      case 'Es':
        return 'Por favor, complete su información.';
      case '中文':
        return '请完善您的信息。';
      case 'हिन्दी':
        return 'कृपया अपनी जानकारी पूरी करें।';
      case 'Português':
        return 'Por favor, complete suas informações.';
      case 'Русский':
        return 'Пожалуйста, заполните вашу информацию.';
      case '日本語':
        return '情報を入力してください。';
      case 'Français':
        return 'Veuillez compléter vos informations.';
      case 'Deutsch':
        return 'Bitte vervollständigen Sie Ihre Informationen.';
      default:
        return 'Please complete your information.';
    }
  }
  String okText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'موافق';
      case 'en':
        return 'OK';
      case 'Es':
        return 'Aceptar';
      case '中文':
        return '确定';
      case 'हिन्दी':
        return 'ठीक है';
      case 'Português':
        return 'OK';
      case 'Русский':
        return 'OK';
      case '日本語':
        return 'OK';
      case 'Français':
        return 'OK';
      case 'Deutsch':
        return 'OK';
      default:
        return 'OK';
    }
  }
  String logoutConfirmationText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'هل أنت متأكد أنك تريد تسجيل الخروج؟';
      case 'en':
        return 'Are you sure you want to log out?';
      case 'Es':
        return '¿Estás seguro de que quieres cerrar sesión?';
      case '中文':
        return '您确定要注销吗？';
      case 'हिन्दी':
        return 'क्या आप वाकई लॉग आउट करना चाहते हैं?';
      case 'Português':
        return 'Tem certeza de que deseja sair?';
      case 'Русский':
        return 'Вы уверены, что хотите выйти?';
      case '日本語':
        return '本当にログアウトしますか？';
      case 'Français':
        return 'Êtes-vous sûr de vouloir vous déconnecter ?';
      case 'Deutsch':
        return 'Möchten Sie sich wirklich abmelden?';
      default:
        return 'Are you sure you want to log out?';
    }
  }
  String emailText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'البريد الإلكتروني';
      case 'en':
        return 'Email';
      case 'Es':
        return 'Correo electrónico';
      case '中文':
        return '电子邮件';
      case 'हिन्दी':
        return 'ईमेल';
      case 'Português':
        return 'Email';
      case 'Русский':
        return 'Электронная почта';
      case '日本語':
        return 'Eメール';
      case 'Français':
        return 'E-mail';
      case 'Deutsch':
        return 'E-Mail';
      default:
        return 'Email';
    }
  }
  String enterEmailText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الرجاء إدخال البريد الإلكتروني';
      case 'en':
        return 'Please enter your email';
      case 'Es':
        return 'Por favor, ingrese su correo electrónico';
      case '中文':
        return '请输入您的电子邮件';
      case 'हिन्दी':
        return 'कृपया अपना ईमेल दर्ज करें';
      case 'Português':
        return 'Por favor, insira seu e-mail';
      case 'Русский':
        return 'Пожалуйста, введите свой адрес электронной почты';
      case '日本語':
        return 'メールアドレスを入力してください';
      case 'Français':
        return 'Veuillez entrer votre adresse e-mail';
      case 'Deutsch':
        return 'Bitte geben Sie Ihre E-Mail-Adresse ein';
      default:
        return 'Please enter your email';
    }
  }
  String enterPasswordText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الرجاء إدخال كلمة المرور';
      case 'en':
        return 'Please enter your password';
      case 'Es':
        return 'Por favor, introduzca su contraseña';
      case '中文':
        return '请输入您的密码';
      case 'हिन्दी':
        return 'कृपया अपना पासवर्ड दर्ज करें';
      case 'Português':
        return 'Por favor, digite sua senha';
      case 'Русский':
        return 'Пожалуйста, введите пароль';
      case '日本語':
        return 'パスワードを入力してください';
      case 'Français':
        return 'Veuillez entrer votre mot de passe';
      case 'Deutsch':
        return 'Bitte geben Sie Ihr Passwort ein';
      default:
        return 'Please enter your password';
    }
  }
  String loginText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تسجيل الدخول';
      case 'en':
        return 'Login';
      case 'Es':
        return 'Iniciar sesión';
      case '中文':
        return '登录';
      case 'हिन्दी':
        return 'लॉग इन करें';
      case 'Português':
        return 'Entrar';
      case 'Русский':
        return 'Вход';
      case '日本語':
        return 'ログイン';
      case 'Français':
        return 'Connexion';
      case 'Deutsch':
        return 'Anmelden';
      default:
        return 'Login';
    }
  }
  String createAccountText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'لا تمتلك حساب؟ إنشاء حساب';
      case 'en':
        return 'Don\'t have an account? Create an account';
      case 'Es':
        return '¿No tienes una cuenta? Crea una cuenta';
      case '中文':
        return '没有帐号？创建一个帐号';
      case 'हिन्दी':
        return 'क्या आपके पास खाता नहीं है? खाता बनाएं';
      case 'Português':
        return 'Não tem uma conta? Crie uma conta';
      case 'Русский':
        return 'Нет аккаунта? Создать аккаунт';
      case '日本語':
        return 'アカウントをお持ちでないですか？ アカウントを作成';
      case 'Français':
        return 'Vous n\'avez pas de compte ? Créez un compte';
      case 'Deutsch':
        return 'Sie haben kein Konto? Konto erstellen';
      default:
        return 'Don\'t have an account? Create an account';
    }
  }
  String usernameText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'اسم المستخدم';
      case 'en':
        return 'Username';
      case 'Es':
        return 'Nombre de usuario';
      case '中文':
        return '用户名';
      case 'हिन्दी':
        return 'उपयोगकर्ता नाम';
      case 'Português':
        return 'Nome de usuário';
      case 'Русский':
        return 'Имя пользователя';
      case '日本語':
        return 'ユーザー名';
      case 'Français':
        return 'Nom d\'utilisateur';
      case 'Deutsch':
        return 'Benutzername';
      default:
        return 'Username';
    }
  }
  String pleaseEnterUsernameText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الرجاء إدخال اسم المستخدم';
      case 'en':
        return 'Please enter your username';
      case 'Es':
        return 'Por favor, ingrese su nombre de usuario';
      case '中文':
        return '请输入您的用户名';
      case 'हिन्दी':
        return 'कृपया अपना उपयोगकर्ता नाम दर्ज करें';
      case 'Português':
        return 'Por favor, insira seu nome de usuário';
      case 'Русский':
        return 'Пожалуйста, введите ваше имя пользователя';
      case '日本語':
        return 'ユーザー名を入力してください';
      case 'Français':
        return 'Veuillez entrer votre nom d\'utilisateur';
      case 'Deutsch':
        return 'Bitte geben Sie Ihren Benutzernamen ein';
      default:
        return 'Please enter your username';
    }
  }
  String confirmPasswordText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تأكيد كلمة المرور';
      case 'en':
        return 'Confirm Password';
      case 'Es':
        return 'Confirmar contraseña';
      case '中文':
        return '确认密码';
      case 'हिन्दी':
        return 'पासवर्ड की पुष्टि करें';
      case 'Português':
        return 'Confirmar senha';
      case 'Русский':
        return 'Подтвердите пароль';
      case '日本語':
        return 'パスワードを確認';
      case 'Français':
        return 'Confirmer le mot de passe';
      case 'Deutsch':
        return 'Passwort bestätigen';
      default:
        return 'Confirm Password';
    }
  }
  String passwordsDoNotMatchText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'كلمات المرور غير متطابقة';
      case 'en':
        return 'Passwords do not match';
      case 'Es':
        return 'Las contraseñas no coinciden';
      case '中文':
        return '密码不匹配';
      case 'हिन्दी':
        return 'पासवर्ड मेल नहीं खाते';
      case 'Português':
        return 'As senhas não coincidem';
      case 'Русский':
        return 'Пароли не совпадают';
      case '日本語':
        return 'パスワードが一致しません';
      case 'Français':
        return 'Les mots de passe ne correspondent pas';
      case 'Deutsch':
        return 'Passwörter stimmen nicht überein';
      default:
        return 'Passwords do not match';
    }
  }
  String signUpText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'تسجيل';
      case 'en':
        return 'Sign Up';
      case 'Es':
        return 'Registrarse';
      case '中文':
        return '注册';
      case 'हिन्दी':
        return 'साइन अप करें';
      case 'Português':
        return 'Cadastrar';
      case 'Русский':
        return 'Регистрация';
      case '日本語':
        return 'サインアップ';
      case 'Français':
        return 'Sinscrire';
      case 'Deutsch':
        return 'Registrieren';
      default:
        return 'Sign Up';
    }
  }
  String alreadyHaveAccountText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'هل لديك حساب؟ تسجيل الدخول';
      case 'en':
        return 'Already have an account? Log in';
      case 'Es':
        return '¿Ya tienes una cuenta? Iniciar sesión';
      case '中文':
        return '已经有账号了吗？登录';
      case 'हिन्दी':
        return 'क्या आपके पास पहले से ही खाता है? लॉग इन करें';
      case 'Português':
        return 'Já tem uma conta? Entrar';
      case 'Русский':
        return 'У вас уже есть аккаунт? Войти';
      case '日本語':
        return 'すでにアカウントをお持ちですか？ ログイン';
      case 'Français':
        return 'Vous avez déjà un compte ? Se connecter';
      case 'Deutsch':
        return 'Haben Sie bereits ein Konto? Einloggen';
      default:
        return 'Already have an account? Log in';
    }
  }
  String getRequiredPointsText() {
    final currentLanguage = getLanguage();

    switch (currentLanguage) {
      case 'ar':
        return 'يجب تحديد عدد النقاط المطلوبة';
      case 'en':
        return 'You must specify the required points';
      case 'Es':
        return 'Debe especificar la cantidad de puntos requeridos';
      case '中文':
        return '必须指定所需的积分数';
      case 'हिन्दी':
        return 'आवश्यक अंकों की संख्या निर्धारित करनी चाहिए';
      case 'Português':
        return 'Você deve especificar o número de pontos necessários';
      case 'Русский':
        return 'Вы должны указать требуемое количество баллов';
      case '日本語':
        return '必要なポイント数を指定する必要があります';
      case 'Français':
        return 'Vous devez spécifier le nombre de points requis';
      case 'Deutsch':
        return 'Sie müssen die erforderliche Punktzahl angeben';
      default:
        return 'You must specify the required number of points'; // Default to en if the language is not recognized
    }
  }
  String getAddRequiredPointsText() {
    final currentLanguage = getLanguage();

    switch (currentLanguage) {
      case 'ar':
        return 'اضافة النقاط المطلوبة';
      case 'en':
        return 'Add the required points';
      case 'Es':
        return 'Agregar los puntos requeridos';
      case '中文':
        return '添加所需的积分';
      case 'हिन्दी':
        return 'आवश्यक अंक जोड़ें';
      case 'Português':
        return 'Adicione os pontos necessários';
      case 'Русский':
        return 'Добавьте необходимое количество баллов';
      case '日本語':
        return '必要なポイントを追加';
      case 'Français':
        return 'Ajoutez les points requis';
      case 'Deutsch':
        return 'Fügen Sie die erforderlichen Punkte hinzu';
      default:
        return 'Add the required points'; // Default to en if the language is not recognized
    }
  }
  String getChangePasswordText() {
    final currentLanguage = getLanguage();

    switch (currentLanguage) {
      case 'ar':
        return 'تغيير كلمة المرور';
      case 'en':
        return 'Change Password';
      case 'Es':
        return 'Cambiar Contraseña';
      case '中文':
        return '修改密码';
      case 'हिन्दी':
        return 'पासवर्ड बदलें';
      case 'Português':
        return 'Alterar Senha';
      case 'Русский':
        return 'Изменить пароль';
      case '日本語':
        return 'パスワード変更';
      case 'Français':
        return 'Changer de mot de passe';
      case 'Deutsch':
        return 'Passwort ändern';
      default:
        return 'Change Password'; // Default to en if the language is not recognized
    }
  }
  String getCurrentPasswordText() {
    final currentLanguage = getLanguage();

    switch (currentLanguage) {
      case 'ar':
        return 'كلمة المرور الحالية';
      case 'en':
        return 'Current Password';
      case 'Es':
        return 'Contraseña Actual';
      case '中文':
        return '当前密码';
      case 'हिन्दी':
        return 'वर्तमान पासवर्ड';
      case 'Português':
        return 'Senha Atual';
      case 'Русский':
        return 'Текущий пароль';
      case '日本語':
        return '現在のパスワード';
      case 'Français':
        return 'Mot de passe actuel';
      case 'Deutsch':
        return 'Aktuelles Passwort';
      default:
        return 'Current Password'; // Default to en if the language is not recognized
    }
  }
  String getNewPasswordText() {
    final currentLanguage = getLanguage();

    switch (currentLanguage) {
      case 'ar':
        return 'كلمة المرور الجديدة';
      case 'en':
        return 'New Password';
      case 'Es':
        return 'Nueva Contraseña';
      case '中文':
        return '新密码';
      case 'हिन्दी':
        return 'नई पासवर्ड';
      case 'Português':
        return 'Nova Senha';
      case 'Русский':
        return 'Новый пароль';
      case '日本語':
        return '新しいパスワード';
      case 'Français':
        return 'Nouveau Mot de passe';
      case 'Deutsch':
        return 'Neues Passwort';
      default:
        return 'New Password'; // Default to en if the language is not recognized
    }
  }
  String getCodeText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'الكود';
      case 'en':
        return 'Code';
      case 'Es':
        return 'Código';
      case '中文':
        return '代码';
      case 'हिन्दी':
        return 'कोड';
      case 'Português':
        return 'Código';
      case 'Русский':
        return 'Код';
      case '日本語':
        return 'コード';
      case 'Français':
        return 'Code';
      case 'Deutsch':
        return 'Code';
      default:
        return 'Code'; // Default to en if the language is not recognized
    }
  }
  String getPurchaseInstructionText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'بعد إرسال الطلب بعدد النقاط المطلوبة،قم بنسخ الرقم التعريفي وتواصل مع فريق المبيعات لاتمام عملية الشراء';
      case 'en':
        return 'After submitting the order with the required points, copy the reference number and contact the sales team to complete the purchase process';
      case 'Es':
        return 'Después de enviar el pedido con los puntos requeridos, copie el número de referencia y póngase en contacto con el equipo de ventas para completar el proceso de compra';
      case '中文':
        return '在提交具有所需积分的订单后，复制参考号码并与销售团队联系以完成购买过程';
      case 'हिन्दी':
        return 'आवश्यक अंकों के साथ आर्डर सबमिट करने के बाद, संदर्भ संख्या की प्रतिलिपि बनाएं और खरीददारी प्रक्रिया पूरी करने के लिए बेचने की टीम से संपर्क करें';
      case 'Português':
        return 'Após enviar o pedido com os pontos necessários, copie o número de referência e entre em contato com a equipe de vendas para concluir o processo de compra';
      case 'Русский':
        return 'После отправки заказа с необходимыми баллами скопируйте номер и свяжитесь с командой по продажам, чтобы завершить процесс покупки';
      case '日本語':
        return '必要なポイントで注文を送信した後、参照番号をコピーして購入プロセスを完了するために販売チームに連絡してください';
      case 'Français':
        return "Après avoir soumis la commande avec les points requis, copiez le numéro de référence et contactez l'équipe de vente pour finaliser le processus d'achat";
      case 'Deutsch':
        return 'Nach dem Einreichen der Bestellung mit den erforderlichen Punkten kopieren Sie die Referenznummer und kontaktieren Sie das Verkaufsteam, um den Kaufprozess abzuschließen';
      default:
        return 'After submitting the order with the required points, copy the reference number and contact the sales team to complete the purchase process'; // Default to en if the language is not recognized
    }
  }
  String getFollowText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'متابعة';
      case 'en':
        return 'Follow';
      case 'Es':
        return 'Seguir';
      case '中文':
        return '关注';
      case 'हिन्दी':
        return 'फॉलो करें';
      case 'Português':
        return 'Seguir';
      case 'Русский':
        return 'Подписаться';
      case '日本語':
        return 'フォロー';
      case 'Français':
        return 'Suivre';
      case 'Deutsch':
        return 'Folgen';
      default:
        return 'Follow'; // Default to en if the language is not recognized
    }
  }
  String getUnfollowText() {
    final currentLanguage = getLanguage();

    switch (currentLanguage) {
      case 'ar':
        return 'إلغاء المتابعة';
      case 'en':
        return 'Unfollow';
      case 'Es':
        return 'Dejar de seguir';
      case '中文':
        return '取消关注';
      case 'हिन्दी':
        return 'अनफॉलो करें';
      case 'Português':
        return 'Deixar de seguir';
      case 'Русский':
        return 'Отписаться';
      case '日本語':
        return 'フォロー解除';
      case 'Français':
        return 'Ne plus suivre';
      case 'Deutsch':
        return 'Nicht mehr folgen';
      default:
        return 'Unfollow'; // Default to en if the language is not recognized
    }
  }
  String getMoreText() {
    final currentLanguage = getLanguage();
    switch (currentLanguage) {
      case 'ar':
        return 'المزيد...';
      case 'en':
        return 'More...';
      case 'Es':
        return 'Más...';
      case '中文':
        return '更多...';
      case 'हिन्दी':
        return 'अधिक...';
      case 'Português':
        return 'Mais...';
      case 'Русский':
        return 'Еще...';
      case '日本語':
        return 'もっと...';
      case 'Français':
        return 'Plus...';
      case 'Deutsch':
        return 'Mehr...';
      default:
        return 'More...'; // Default to en if the language is not recognized
    }
  }
  String getShowDetailsText() {
    final currentLanguage = getLanguage();

    switch (currentLanguage) {
      case 'ar':
        return 'عرض التفاصيل';
      case 'en':
        return 'Show Details';
      case 'Es':
        return 'Mostrar Detalles';
      case '中文':
        return '显示详细信息';
      case 'हिन्दी':
        return 'विवरण दिखाएं';
      case 'Português':
        return 'Mostrar Detalhes';
      case 'Русский':
        return 'Показать детали';
      case '日本語':
        return '詳細を表示';
      case 'Français':
        return 'Afficher les détails';
      case 'Deutsch':
        return 'Details anzeigen';
      default:
        return 'Show Details'; // Default to en if the language is not recognized
    }
  }
  String getCreateText() {
    final currentLanguage = getLanguage();

    switch (currentLanguage) {
      case 'ar':
        return 'إنشاء';
      case 'en':
        return 'Create';
      case 'Es':
        return 'Crear';
      case '中文':
        return '创建';
      case 'हिन्दी':
        return 'बनाएँ';
      case 'Português':
        return 'Criar';
      case 'Русский':
        return 'Создать';
      case '日本語':
        return '作成';
      case 'Français':
        return 'Créer';
      case 'Deutsch':
        return 'Erstellen';
      default:
        return 'Create'; // Default to en if the language is not recognized
    }
  }
  String getCommentsText() {
    final currentLanguage = getLanguage();

    switch (currentLanguage) {
      case 'ar':
        return 'التعليقات';
      case 'en':
        return 'Comments';
      case 'Es':
        return 'Comentarios';
      case '中文':
        return '评论';
      case 'हिन्दी':
        return 'टिप्पणियाँ';
      case 'Português':
        return 'Comentários';
      case 'Русский':
        return 'Комментарии';
      case '日本語':
        return 'コメント';
      case 'Français':
        return 'Commentaires';
      case 'Deutsch':
        return 'Kommentare';
      default:
        return 'Comments'; // Default to en if the language is not recognized
    }
  }
  String getNotificationText() {
    final currentLanguage = getLanguage();

    switch (currentLanguage) {
      case 'ar':
        return 'الإشعارات';
      case 'en':
        return 'Notification';
      case 'Es':
        return 'Notificación';
      case '中文':
        return '通知';
      case 'हिन्दी':
        return 'सूचना';
      case 'Português':
        return 'Notificação';
      case 'Русский':
        return 'Уведомление';
      case '日本語':
        return '通知';
      case 'Français':
        return 'Notification';
      case 'Deutsch':
        return 'Benachrichtigung';
      default:
        return 'Notification'; // Default to en if the language is not recognized
    }
  }
}