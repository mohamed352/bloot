import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:bloot/core/style/colors.dart';
import 'package:bloot/core/constants/app_spacing.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        title: Text('terms_of_service'.tr()),
        backgroundColor: const Color(0x00000000),
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
                '1. Acceptance of Terms',
                'By accessing or using the Bloot application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services.',
              ),
              _buildParagraph(
                '2. Eligibility',
                'You must be at least 18 years old to use Bloot. By using our services, you represent and warrant that you meet this age requirement.',
              ),
              _buildParagraph(
                '3. User Accounts',
                'You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorized use of your account.',
              ),
              _buildParagraph(
                '4. Fair Play',
                'Users must play fairly and honestly. Cheating, use of unauthorized software, or any form of manipulation is strictly prohibited and may result in account termination.',
              ),
              _buildParagraph(
                '5. Content Guidelines',
                'Users are prohibited from posting offensive, harmful, or illegal content. We reserve the right to remove content and suspend accounts that violate these guidelines.',
              ),
              _buildParagraph(
                '6. Virtual Currency',
                'Coins and other virtual items have no real-world value and cannot be exchanged for real money. All purchases are final and non-refundable.',
              ),
              _buildParagraph(
                '7. Limitation of Liability',
                'Bloot is provided "as is" without warranties of any kind. We are not liable for any damages arising from your use of our services.',
              ),
              _buildParagraph(
                '8. Changes to Terms',
                'We may update these terms from time to time. Continued use of Bloot after changes constitutes acceptance of the updated terms.',
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
          const SizedBox(height: AppSpacing.sm),
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
