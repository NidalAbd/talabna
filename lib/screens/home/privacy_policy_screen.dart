import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/provider/language.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final Language _language = Language();
  final String _currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

  String _getPrivacyTitle() {
    final currentLanguage = _language.getLanguage();
    if (currentLanguage == 'ar') {
      return 'سياسة الخصوصية';
    } else {
      return 'Privacy Policy';
    }
  }

  String _getLastUpdatedText() {
    final currentLanguage = _language.getLanguage();
    if (currentLanguage == 'ar') {
      return 'آخر تحديث: $_currentDate';
    } else {
      return 'Last Updated: $_currentDate';
    }
  }

  String _getSectionTitle(String titleEn) {
    final currentLanguage = _language.getLanguage();
    if (currentLanguage == 'ar') {
      switch (titleEn) {
        case 'Introduction':
          return 'مقدمة';
        case 'Information We Collect':
          return 'المعلومات التي نجمعها';
        case 'How We Use Your Information':
          return 'كيف نستخدم معلوماتك';
        case 'Disclosure of Your Information':
          return 'الكشف عن معلوماتك';
        case 'Security of Your Information':
          return 'أمان معلوماتك';
        case 'Contact Us':
          return 'اتصل بنا';
        default:
          return titleEn;
      }
    } else {
      return titleEn;
    }
  }

  String _getSectionContent(String titleEn) {
    final currentLanguage = _language.getLanguage();
    if (currentLanguage == 'ar') {
      switch (titleEn) {
        case 'Introduction':
          return 'مرحبًا بك في سياسة الخصوصية الخاصة بنا. توضح سياسة الخصوصية هذه كيفية جمع واستخدام والكشف عن وحماية معلوماتك عند استخدام تطبيقنا. يرجى قراءة سياسة الخصوصية هذه بعناية. إذا كنت لا توافق على شروط سياسة الخصوصية هذه، يرجى عدم الوصول إلى التطبيق.';
        case 'Information We Collect':
          return 'قد نجمع معلومات عنك بطرق مختلفة. المعلومات التي قد نجمعها عبر التطبيق تشمل:';
        case 'How We Use Your Information':
          return 'إن امتلاك معلومات دقيقة عنك يسمح لنا بتزويدك بتجربة سلسة وفعالة ومخصصة. على وجه التحديد، قد نستخدم المعلومات التي تم جمعها عنك عبر التطبيق لـ:';
        case 'Disclosure of Your Information':
          return 'قد نشارك المعلومات التي جمعناها عنك في حالات معينة. قد يتم الكشف عن معلوماتك على النحو التالي:';
        case 'Security of Your Information':
          return 'نحن نستخدم تدابير أمان إدارية وتقنية ومادية للمساعدة في حماية معلوماتك الشخصية. في حين أننا اتخذنا خطوات معقولة لتأمين المعلومات الشخصية التي تقدمها لنا، يرجى العلم أنه على الرغم من جهودنا، لا توجد تدابير أمنية مثالية أو غير قابلة للاختراق، ولا يمكن ضمان أي طريقة لنقل البيانات ضد أي اعتراض أو نوع آخر من إساءة الاستخدام.';
        case 'Contact Us':
          return 'إذا كانت لديك أسئلة أو تعليقات حول سياسة الخصوصية هذه، يرجى الاتصال بنا على:';
        default:
          return '';
      }
    } else {
      switch (titleEn) {
        case 'Introduction':
          return 'Welcome to our Privacy Policy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our application. Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the application.';
        case 'Information We Collect':
          return 'We may collect information about you in various ways. The information we may collect via the Application includes:';
        case 'How We Use Your Information':
          return 'Having accurate information about you permits us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you via the Application to:';
        case 'Disclosure of Your Information':
          return 'We may share information we have collected about you in certain situations. Your information may be disclosed as follows:';
        case 'Security of Your Information':
          return 'We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure the personal information you provide to us, please be aware that despite our efforts, no security measures are perfect or impenetrable, and no method of data transmission can be guaranteed against any interception or other type of misuse.';
        case 'Contact Us':
          return 'If you have questions or comments about this Privacy Policy, please contact us at:';
        default:
          return '';
      }
    }
  }

  List<String> _getBulletPoints(String sectionTitleEn) {
    final currentLanguage = _language.getLanguage();
    if (currentLanguage == 'ar') {
      switch (sectionTitleEn) {
        case 'Information We Collect':
          return [
            'البيانات الشخصية: الاسم وعنوان البريد الإلكتروني ورقم الهاتف',
            'بيانات الاستخدام: معلومات حول كيفية استخدامك للتطبيق',
            'بيانات الجهاز: معلومات حول جهازك المحمول',
            'بيانات الموقع: معلومات حول موقعك (بإذن منك)'
          ];
        case 'How We Use Your Information':
          return [
            'إنشاء وإدارة حسابك',
            'تقديم إعلانات مستهدفة ونشرات إخبارية ومعلومات أخرى تتعلق بالعروض الترويجية',
            'مراسلتك عبر البريد الإلكتروني بخصوص حسابك أو طلبك',
            'تنفيذ وإدارة عمليات الشراء والطلبات والمدفوعات والمعاملات الأخرى',
            'زيادة كفاءة وتشغيل التطبيق',
            'مراقبة وتحليل الاستخدام والاتجاهات لتحسين تجربتك مع التطبيق',
            'إخطارك بتحديثات التطبيق',
            'طلب التعليقات والاتصال بك بخصوص استخدامك للتطبيق',
            'حل النزاعات ومعالجة المشكلات'
          ];
        case 'Disclosure of Your Information':
          return [
            'بموجب القانون أو لحماية الحقوق: إذا اعتقدنا أن الإفصاح عن المعلومات عنك ضروري للاستجابة للإجراءات القانونية',
            'مزودو الخدمات من جهات خارجية: قد نشارك معلوماتك مع أطراف ثالثة تقدم خدمات لنا أو نيابة عنا',
            'اتصالات تسويقية: بموافقتك، أو مع فرصة لك لسحب الموافقة، قد نشارك معلوماتك مع أطراف ثالثة لأغراض تسويقية'
          ];
        default:
          return [];
      }
    } else {
      switch (sectionTitleEn) {
        case 'Information We Collect':
          return [
            'Personal Data: Name, email address, and phone number',
            'Usage Data: Information about how you use our Application',
            'Device Data: Information about your mobile device',
            'Location Data: Information about your location (with your permission)'
          ];
        case 'How We Use Your Information':
          return [
            'Create and manage your account',
            'Deliver targeted advertising, newsletters, and other information regarding promotions',
            'Email you regarding your account or order',
            'Fulfill and manage purchases, orders, payments, and other transactions',
            'Increase the efficiency and operation of the Application',
            'Monitor and analyze usage and trends to improve your experience with the Application',
            'Notify you of updates to the Application',
            'Request feedback and contact you about your use of the Application',
            'Resolve disputes and troubleshoot problems'
          ];
        case 'Disclosure of Your Information':
          return [
            'By Law or to Protect Rights: If we believe the release of information about you is necessary to respond to legal process',
            'Third-Party Service Providers: We may share your information with third parties that perform services for us or on our behalf',
            'Marketing Communications: With your consent, or with an opportunity for you to withdraw consent, we may share your information with third parties for marketing purposes'
          ];
        default:
          return [];
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_language.getLanguage() == 'ar'
                  ? 'لا يمكن فتح تطبيق البريد الإلكتروني'
                  : 'Could not open email app'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_language.getLanguage() == 'ar'
                ? 'خطأ: $e'
                : 'Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          _language.tPrivacyPolicyText(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
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
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(width: 12),
                        Text(
                          _getPrivacyTitle(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getLastUpdatedText(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),

            // Introduction Section
            _buildSection(
              title: 'Introduction',
              content: _getSectionContent('Introduction'),
              bulletPoints: [],
              isArabic: isArabic,
              primaryColor: primaryColor,
              cardColor: cardColor,
              textColor: textColor,
            ),

            // Information We Collect Section
            _buildSection(
              title: 'Information We Collect',
              content: _getSectionContent('Information We Collect'),
              bulletPoints: _getBulletPoints('Information We Collect'),
              isArabic: isArabic,
              primaryColor: primaryColor,
              cardColor: cardColor,
              textColor: textColor,
            ),

            // How We Use Your Information Section
            _buildSection(
              title: 'How We Use Your Information',
              content: _getSectionContent('How We Use Your Information'),
              bulletPoints: _getBulletPoints('How We Use Your Information'),
              isArabic: isArabic,
              primaryColor: primaryColor,
              cardColor: cardColor,
              textColor: textColor,
            ),

            // Disclosure of Your Information Section
            _buildSection(
              title: 'Disclosure of Your Information',
              content: _getSectionContent('Disclosure of Your Information'),
              bulletPoints: _getBulletPoints('Disclosure of Your Information'),
              isArabic: isArabic,
              primaryColor: primaryColor,
              cardColor: cardColor,
              textColor: textColor,
            ),

            // Security of Your Information Section
            _buildSection(
              title: 'Security of Your Information',
              content: _getSectionContent('Security of Your Information'),
              bulletPoints: [],
              isArabic: isArabic,
              primaryColor: primaryColor,
              cardColor: cardColor,
              textColor: textColor,
            ),

            // Contact Us Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getSectionTitle('Contact Us'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getSectionContent('Contact Us'),
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: textColor,
                      ),
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    ),
                    const SizedBox(height: 16),

                    // Email Button
                    InkWell(
                      onTap: () => _launchEmail('privacy@talbna.com'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.7),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.email_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'talbna@talbna.cloud',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  isArabic
                      ? 'شكرًا لقراءة سياسة الخصوصية الخاصة بنا'
                      : 'Thank you for reading our privacy policy',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required List<String> bulletPoints,
    required bool isArabic,
    required Color primaryColor,
    required Color cardColor,
    required Color textColor,
  }) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
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
        child: Column(
          crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              _getSectionTitle(title),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: textColor,
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
            if (bulletPoints.isNotEmpty) const SizedBox(height: 12),
            ...bulletPoints.map((point) => _buildBulletPoint(
              text: point,
              isArabic: isArabic,
              textColor: textColor,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint({
    required String text,
    required bool isArabic,
    required Color textColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8.0,
        right: isArabic ? 0 : 8.0,
        left: isArabic ? 8.0 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
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