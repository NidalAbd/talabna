import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/provider/language.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final Language _language = Language();
  String _appVersion = '';
  String _appName = '';
  String _currentYear = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final DateTime now = DateTime.now();
      final DateFormat formatter = DateFormat('yyyy');

      setState(() {
        _appName = packageInfo.appName;
        _appVersion = packageInfo.version;
        _currentYear = formatter.format(now);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _appName = 'Talbna';
        _appVersion = '1.0.0';
        _currentYear = DateTime.now().year.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_language.getLanguage() == 'ar'
                  ? 'لا يمكن فتح الرابط'
                  : 'Could not launch URL'),
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

  String _getAppDescription() {
    final currentLanguage = _language.getLanguage();
    if (currentLanguage == 'ar') {
      return 'طلبنا هو تطبيق متعدد الاستخدامات يتيح للمستخدمين نشر وتصفح فئات مختلفة مثل الوظائف والعقارات والسيارات والأجهزة والخدمات العامة. سواء كنت تبحث عن فرصة عمل جديدة أو مكان للعيش أو سيارة أو أي نوع من الخدمات، فإن طلبنا يغطي احتياجاتك. واجهة المستخدم سهلة الاستخدام وميزات البحث تجعل من السهل العثور على ما تبحث عنه والتواصل مع المشترين أو البائعين المحتملين.';
    } else {
      return 'Talbna is a versatile app that allows users to post and browse various categories such as jobs, real estate, cars, devices, and general services. Whether you\'re looking for a new career opportunity, a place to live, a car or any kind of service, Talbna has got you covered. Its user-friendly interface and search features make it easy to find what you\'re looking for and connect with potential buyers or sellers.';
    }
  }

  String _getFeatureTitle(int index) {
    final currentLanguage = _language.getLanguage();
    if (currentLanguage == 'ar') {
      switch (index) {
        case 0: return 'فئات متعددة';
        case 1: return 'نشر سهل';
        case 2: return 'بحث متقدم';
        case 3: return 'تواصل مباشر';
        case 4: return 'دعم متعدد اللغات';
        default: return '';
      }
    } else {
      switch (index) {
        case 0: return 'Multiple Categories';
        case 1: return 'Easy Posting';
        case 2: return 'Advanced Search';
        case 3: return 'Connect Directly';
        case 4: return 'Multi-language Support';
        default: return '';
      }
    }
  }

  String _getFeatureDescription(int index) {
    final currentLanguage = _language.getLanguage();
    if (currentLanguage == 'ar') {
      switch (index) {
        case 0: return 'تصفح الخدمات عبر الوظائف والعقارات والسيارات والأجهزة والمزيد';
        case 1: return 'قم بإنشاء وإدارة إعلاناتك بسرعة بنقرات قليلة فقط';
        case 2: return 'ابحث عما تريده بالضبط باستخدام خيارات البحث القوية';
        case 3: return 'تحدث مباشرة مع المشترين والبائعين لإتمام الصفقات';
        case 4: return 'استخدم التطبيق بلغتك المفضلة للحصول على تجربة مريحة';
        default: return '';
      }
    } else {
      switch (index) {
        case 0: return 'Browse services across jobs, real estate, cars, devices, and more';
        case 1: return 'Quickly create and manage your listings in just a few taps';
        case 2: return 'Find exactly what you\'re looking for with powerful search options';
        case 3: return 'Chat directly with buyers and sellers to finalize deals';
        case 4: return 'Use the app in your preferred language for a comfortable experience';
        default: return '';
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
    final currentLanguage = _language.getLanguage();
    final isArabic = currentLanguage == 'ar';

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            _language.tAboutText(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _language.tAboutText(),
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
            SliverToBoxAdapter(
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.home_work_rounded,
                        size: 50,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // App Name
                    Text(
                      _appName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),

                    // App Version
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        isArabic
                            ? 'الإصدار $_appVersion'
                            : 'Version $_appVersion',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Description Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text(
                  isArabic ? 'حول التطبيق' : 'About',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                child: Text(
                  _getAppDescription(),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: textColor,
                  ),
                ),
              ),
            ),

            // Features Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text(
                  isArabic ? 'المميزات الرئيسية' : 'Key Features',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index >= 5) return null;

                  IconData featureIcon;
                  switch (index) {
                    case 0: featureIcon = Icons.category_rounded; break;
                    case 1: featureIcon = Icons.post_add_rounded; break;
                    case 2: featureIcon = Icons.search_rounded; break;
                    case 3: featureIcon = Icons.chat_rounded; break;
                    case 4: featureIcon = Icons.language_rounded; break;
                    default: featureIcon = Icons.star_rounded;
                  }

                  return _buildModernFeatureItem(
                    icon: featureIcon,
                    title: _getFeatureTitle(index),
                    description: _getFeatureDescription(index),
                    isArabic: isArabic,
                  );
                },
                childCount: 5,
              ),
            ),

            // Contact Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text(
                  isArabic ? 'تواصل معنا' : 'Contact Us',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildModernContactButton(
                          icon: Icons.language_rounded,
                          label: isArabic ? 'الموقع' : 'Website',
                          onTap: () => _launchURL('https://www.talbna.com'),
                        ),
                        _buildModernContactButton(
                          icon: Icons.email_rounded,
                          label: isArabic ? 'البريد' : 'Email',
                          onTap: () => _launchURL('mailto:contact@talbna.com'),
                        ),
                        _buildModernContactButton(
                          icon: Icons.support_agent_rounded,
                          label: isArabic ? 'الدعم' : 'Support',
                          onTap: () => _launchURL('https://www.talbna.com/support'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(Icons.facebook_rounded, () => _launchURL('https://facebook.com/talbna')),
                        const SizedBox(width: 16),
                        _buildSocialButton(Icons.phone_rounded, () => _launchURL('tel:+1234567890')),
                        const SizedBox(width: 16),
                        _buildSocialButton(Icons.smartphone_rounded, () => _launchURL('https://wa.me/1234567890')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(
                      isArabic
                          ? 'صنع بكل ❤️ بواسطة فريق طلبنا'
                          : 'Made with ❤️ by Talbna Team',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArabic
                          ? '© $_currentYear طلبنا. جميع الحقوق محفوظة'
                          : '© $_currentYear Talbna. All rights reserved.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isArabic,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {}, // Optional feature tap action
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        primaryColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.9),
                  primaryColor.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: primaryColor,
          size: 26,
        ),
      ),
    );
  }
}