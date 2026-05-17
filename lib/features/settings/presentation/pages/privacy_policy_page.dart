import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/style/colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        title: Text('privacy_policy'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last updated: May 2024',
                style: TextStyle(
                  fontSize: 13,
                  color: ColorManager.darkTextMuted.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 20),
              _buildParagraph(
                '1. Introduction',
                'Bloot ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
              ),
              _buildParagraph(
                '2. Information We Collect',
                'We collect information that you provide directly to us, including your name, username, phone number, profile picture, and game statistics. We also collect usage data and device information to improve our services.',
              ),
              _buildParagraph(
                '3. How We Use Your Information',
                'We use the information we collect to provide, maintain, and improve our services, to communicate with you, to match you with other players, and to ensure fair gameplay.',
              ),
              _buildParagraph(
                '4. Voice and Video Data',
                'Voice and video calls during gameplay are processed in real-time and are not stored on our servers. We do not record or retain your conversations.',
              ),
              _buildParagraph(
                '5. Data Sharing',
                'We do not sell your personal information. We may share aggregated, anonymized data for analytics and improvement purposes.',
              ),
              _buildParagraph(
                '6. Your Rights',
                'You have the right to access, correct, or delete your personal information. You can manage your data through the Settings menu or by contacting our support team.',
              ),
              _buildParagraph(
                '7. Contact Us',
                'If you have any questions about this Privacy Policy, please contact us at privacy@bloot.app.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParagraph(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ColorManager.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: ColorManager.darkTextSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}