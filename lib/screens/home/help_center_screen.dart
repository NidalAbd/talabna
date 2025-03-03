import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/provider/language.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final Language _language = Language();
  late List<HelpTopic> _helpTopics;

  @override
  void initState() {
    super.initState();
    _initializeHelpTopics();
  }

  void _initializeHelpTopics() {
    final isArabic = _language.getLanguage() == 'ar';

    if (isArabic) {
      _helpTopics = [
        HelpTopic(
          title: 'مشاكل الحساب',
          icon: Icons.account_circle_rounded,
          sections: [
            HelpSection(
              title: 'كيفية إعادة تعيين كلمة المرور',
              content: 'لإعادة تعيين كلمة المرور الخاصة بك، انتقل إلى شاشة تسجيل الدخول واضغط على "نسيت كلمة المرور". اتبع التعليمات المرسلة إلى بريدك الإلكتروني.',
            ),
            HelpSection(
              title: 'كيفية تحديث معلومات الملف الشخصي',
              content: 'انتقل إلى الإعدادات > الحساب > تغيير البريد الإلكتروني أو تغيير كلمة المرور لتحديث معلومات ملفك الشخصي.',
            ),
          ],
        ),
        HelpTopic(
          title: 'ميزات التطبيق',
          icon: Icons.apps_rounded,
          sections: [
            HelpSection(
              title: 'كيفية تغيير اللغة',
              content: 'انتقل إلى الإعدادات > التفضيلات > تغيير اللغة لاختيار لغتك المفضلة.',
            ),
            HelpSection(
              title: 'كيفية التبديل بين الوضع المظلم/الفاتح',
              content: 'انتقل إلى الإعدادات > التفضيلات > المظهر للتبديل بين الوضع المظلم والفاتح.',
            ),
          ],
        ),
        HelpTopic(
          title: 'حل المشكلات',
          icon: Icons.build_rounded,
          sections: [
            HelpSection(
              title: 'انهيار التطبيق',
              content: 'إذا تعطل التطبيق، يرجى المحاولة: 1) إغلاق وإعادة فتح التطبيق 2) التحقق من تحديثات التطبيق 3) إعادة تشغيل جهازك.',
            ),
            HelpSection(
              title: 'مشاكل الاتصال',
              content: 'إذا كنت تواجه مشاكل في الاتصال، يرجى التحقق من اتصال الإنترنت الخاص بك والمحاولة مرة أخرى.',
            ),
          ],
        ),
      ];
    } else {
      _helpTopics = [
        HelpTopic(
          title: 'Account Issues',
          icon: Icons.account_circle_rounded,
          sections: [
            HelpSection(
              title: 'How to reset password',
              content: 'To reset your password, go to the login screen and tap "Forgot Password". Follow the instructions sent to your email.',
            ),
            HelpSection(
              title: 'How to update profile information',
              content: 'Go to Settings > Account > Change Email or Change Password to update your profile information.',
            ),
          ],
        ),
        HelpTopic(
          title: 'App Features',
          icon: Icons.apps_rounded,
          sections: [
            HelpSection(
              title: 'How to change language',
              content: 'Go to Settings > Preferences > Change Language to select your preferred language.',
            ),
            HelpSection(
              title: 'How to toggle dark/light mode',
              content: 'Go to Settings > Preferences > Appearance to switch between dark and light mode.',
            ),
          ],
        ),
        HelpTopic(
          title: 'Troubleshooting',
          icon: Icons.build_rounded,
          sections: [
            HelpSection(
              title: 'App crashing',
              content: 'If the app crashes, please try: 1) Close and reopen the app 2) Check for app updates 3) Restart your device.',
            ),
            HelpSection(
              title: 'Connectivity issues',
              content: 'If you\'re having connectivity issues, please check your internet connection and try again.',
            ),
          ],
        ),
      ];
    }
  }

  // Contact Support
  Future<void> _contactSupport() async {
    final isArabic = _language.getLanguage() == 'ar';
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'talbna@talbna.cloud',
      queryParameters: {
        'subject': isArabic ? 'طلب دعم' : 'Support Request',
        'body': isArabic ? 'مرحبًا، أحتاج إلى مساعدة في...' : 'Hello, I need help with...',
      },
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        // Show error if email can't be launched
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isArabic
                  ? 'تعذر فتح تطبيق البريد الإلكتروني. يرجى مراسلة talbna@talbna.cloud مباشرة.'
                  : 'Could not open email app. Please email talbna@talbna.cloud directly.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic ? 'خطأ: $e' : 'Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getFAQTitle() {
    return _language.getLanguage() == 'ar'
        ? 'الأسئلة المتكررة'
        : 'Frequently Asked Questions';
  }

  String _getContactSupportText() {
    return _language.getLanguage() == 'ar'
        ? 'اتصل بالدعم'
        : 'Contact Support';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final backgroundColor = isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;
    final isArabic = _language.getLanguage() == 'ar';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _language.tHelpCenterText(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      const Icon(
                        Icons.help_center_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getFAQTitle(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic
                        ? 'اعثر على إجابات للأسئلة الشائعة أدناه'
                        : 'Find answers to common questions below',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  ),
                ],
              ),
            ),

            // FAQ List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _helpTopics.length,
                itemBuilder: (context, index) {
                  final topic = _helpTopics[index];
                  return _buildHelpTopicCard(
                    topic,
                    cardColor,
                    primaryColor,
                    textColor,
                    isArabic,
                  );
                },
              ),
            ),

            // Contact Support Button
            Container(
              margin: const EdgeInsets.all(16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _contactSupport,
                  borderRadius: BorderRadius.circular(16),
                  child: Ink(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        const Icon(
                          Icons.email_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getContactSupportText(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Footer text with email
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'talbna@talbna.cloud',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpTopicCard(
      HelpTopic topic,
      Color cardColor,
      Color primaryColor,
      Color textColor,
      bool isArabic,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          colorScheme: ColorScheme.light(
            primary: primaryColor,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              topic.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            topic.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
          ),
          expandedCrossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: topic.sections.map((section) {
            return _buildHelpSectionItem(
              section,
              cardColor,
              primaryColor,
              textColor,
              isArabic,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHelpSectionItem(
      HelpSection section,
      Color cardColor,
      Color primaryColor,
      Color textColor,
      bool isArabic,
      ) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.only(
          left: isArabic ? 20 : 36,
          right: isArabic ? 36 : 20,
          top: 0,
          bottom: 0,
        ),
        leading: isArabic ? null : Icon(
          Icons.chevron_right_rounded,
          color: primaryColor,
          size: 20,
        ),
        trailing: isArabic ? Icon(
          Icons.chevron_left_rounded,
          color: primaryColor,
          size: 20,
        ) : null,
        title: Text(
          section.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: primaryColor,
          ),
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.only(
              left: isArabic ? 20 : 38,
              right: isArabic ? 38 : 20,
              bottom: 16,
            ),
            padding: const EdgeInsets.all(16),
            child: Text(
              section.content,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: textColor,
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

class HelpTopic {
  final String title;
  final IconData icon;
  final List<HelpSection> sections;

  HelpTopic({
    required this.title,
    required this.icon,
    required this.sections,
  });
}

class HelpSection {
  final String title;
  final String content;

  HelpSection({
    required this.title,
    required this.content,
  });
}