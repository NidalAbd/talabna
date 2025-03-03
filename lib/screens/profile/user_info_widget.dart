import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/main.dart';
import 'package:talbna/screens/interaction_widget/email_tile.dart';
import 'package:talbna/screens/interaction_widget/phone_tile.dart';
import 'package:talbna/screens/interaction_widget/user_contact.dart';
import 'package:talbna/screens/interaction_widget/watsapp_tile.dart';
import 'package:intl/intl.dart';

class UserInfoWidget extends StatefulWidget {
  final int userId;
  final User user;

  const UserInfoWidget({
    super.key,
    required this.userId,
    required this.user,
  });

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode
        ? AppTheme.darkSecondaryColor
        : AppTheme.lightPrimaryColor;
    final backgroundColor = isDarkMode
        ? Colors.grey[900]!
        : Colors.white;
    final textColor = isDarkMode
        ? Colors.white
        : Colors.black87;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Contact Information Section
        _buildSectionHeader(
            'Contact Information',
            Icons.contact_page_outlined,
            primaryColor
        ),
        _buildContactInfoCard(context),
        const SizedBox(height: 24),

        // Personal Details Section
        _buildSectionHeader(
            'Personal Details',
            Icons.person_outline_rounded,
            primaryColor
        ),
        _buildPersonalDetailsSection(
            primaryColor,
            backgroundColor,
            textColor
        ),
        const SizedBox(height: 24),

        // Additional Information Section
        _buildSectionHeader(
            'Additional Information',
            Icons.info_outline_rounded,
            primaryColor
        ),
        _buildAdditionalInfoSection(
            primaryColor,
            backgroundColor,
            textColor
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          UserContact(
            username: widget.user.userName!,
            whatsApp: widget.user.watsNumber,
            phone: widget.user.phones,
            email: widget.user.email,
          ),
          EmailTile(email: widget.user.email),
          PhoneWidget(phone: widget.user.phones),
          WhatsAppWidget(
            whatsAppNumber: widget.user.watsNumber,
            username: widget.user.userName!,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsSection(Color primaryColor, Color backgroundColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildDetailTile(
            icon: Icons.person_outline_rounded,
            title: 'Gender',
            subtitle: widget.user.gender ?? 'Not Specified',
            primaryColor: primaryColor,
          ),
          _buildDetailTile(
            icon: Icons.location_city_outlined,
            title: 'City',
            subtitle: widget.user.city?.getName(language) ?? 'Not Specified',
            primaryColor: primaryColor,
          ),
          _buildDetailTile(
            icon: Icons.cake_outlined,
            title: 'Date of Birth',
            subtitle: widget.user.dateOfBirth != null
                ? DateFormat('MMMM dd, yyyy').format(widget.user.dateOfBirth!)
                : 'Not Specified',
            primaryColor: primaryColor,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection(Color primaryColor, Color backgroundColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: _buildDetailTile(
        icon: Icons.check_circle_outline_rounded,
        title: 'Account Status',
        subtitle: widget.user.isActive == true ? 'Active' : 'Inactive',
        primaryColor: primaryColor,
        showDivider: false,
        highlightSubtitle: true,
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryColor,
    bool showDivider = true,
    bool highlightSubtitle = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: highlightSubtitle ? BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ) : null,
            child: Text(
              subtitle,
              style: TextStyle(
                color: highlightSubtitle ? primaryColor : Colors.grey[600],
                fontWeight: highlightSubtitle ? FontWeight.w500 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Colors.grey[200],
            indent: 64,
            endIndent: 16,
          ),
      ],
    );
  }
}