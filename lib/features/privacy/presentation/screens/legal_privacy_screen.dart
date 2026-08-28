import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LegalPrivacyScreen — hub showing all 6 policy items
// Tapping any item pushes _PolicyDetailScreen with hardcoded real content.
// Fully self-contained — no API dependency.
// ─────────────────────────────────────────────────────────────────────────────

class LegalPrivacyScreen extends StatelessWidget {
  const LegalPrivacyScreen({super.key});

  static const _policies = [
    _PolicyItem(
      icon: Icons.description_outlined,
      title: 'Terms of Service',
      subtitle: 'Read the rules and guidelines for using P2P Fit Tech AI.',
      key: 'terms',
    ),
    _PolicyItem(
      icon: Icons.lock_outline,
      title: 'Privacy Policy',
      subtitle: 'Learn how we collect, use and protect your information.',
      key: 'privacy',
    ),
    _PolicyItem(
      icon: Icons.favorite_border,
      title: 'Fitness & Medical Disclaimer',
      subtitle: 'Important information about fitness risks and medical recommendations.',
      key: 'fitness',
    ),
    _PolicyItem(
      icon: Icons.credit_card_outlined,
      title: 'Subscription & Cancellation Policy',
      subtitle: 'Details about subscriptions, billing and cancellations.',
      key: 'subscription',
    ),
    _PolicyItem(
      icon: Icons.people_outline,
      title: 'Community Guidelines',
      subtitle: 'Our standards for a safe and positive community.',
      key: 'community',
    ),
    _PolicyItem(
      icon: Icons.delete_outline,
      title: 'Delete Account & Data',
      subtitle: 'Request deletion of your account and personal data.',
      key: 'delete',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 34.w,
                      height: 34.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.chevron_left, size: 20.sp, color: Colors.black87),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Legal & Privacy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: AppFontWeight.section,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 34.w),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                child: Column(
                  children: [
                    // Logo header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 28.h),
                      child: Column(
                        children: [
                          // Brand logo circle
                          Container(
                            width: 80.w,
                            height: 80.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFF6B35),
                                width: 2.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'P2P',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: AppFontWeight.display,
                                  color: const Color(0xFFFF6B35),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: AppFontWeight.display,
                                letterSpacing: 1.5,
                              ),
                              children: const [
                                TextSpan(text: 'P2P FIT TECH ', style: TextStyle(color: Colors.black)),
                                TextSpan(text: 'AI', style: TextStyle(color: Color(0xFFFF6B35))),
                              ],
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Important policies and information\nabout using P2P Fit Tech AI.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Policy list card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: _policies
                            .asMap()
                            .entries
                            .map((e) => _PolicyTile(
                                  item: e.value,
                                  showDivider: e.key < _policies.length - 1,
                                ))
                            .toList(),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Footer contact card
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38.w,
                            height: 38.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.shield_outlined,
                                size: 18.sp, color: const Color(0xFFFF6B35)),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your privacy and safety are our priority.',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: AppFontWeight.label,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Questions? Contact us at',
                                  style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                                ),
                                Text(
                                  'support@p2pfitchai.com',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: AppFontWeight.label,
                                    color: const Color(0xFFFF6B35),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String key;

  const _PolicyItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.key,
  });
}

class _PolicyTile extends StatelessWidget {
  final _PolicyItem item;
  final bool showDivider;

  const _PolicyTile({required this.item, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Get.to(() => _PolicyDetailScreen(item: item)),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, size: 20.sp, color: const Color(0xFFFF6B35)),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: AppFontWeight.section,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item.subtitle,
                        style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 18.sp, color: Colors.black38),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 72.w, endIndent: 16.w, color: Colors.grey.shade100),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail screen — hardcoded real content per policy key
// ─────────────────────────────────────────────────────────────────────────────

class _PolicyDetailScreen extends StatelessWidget {
  final _PolicyItem item;

  const _PolicyDetailScreen({super.key, required this.item});

  static const _content = {
    'terms': '''
**Terms of Service**
Last updated: August 1, 2026

Welcome to P2P Fit Tech AI. By accessing or using our app, you agree to be bound by these Terms of Service. Please read them carefully.

**1. Acceptance of Terms**
By downloading, installing, or using the P2P Fit Tech AI application, you agree to comply with and be bound by these Terms of Service and our Privacy Policy. If you do not agree, please do not use our services.

**2. Use of Services**
You must be at least 18 years old to use this application. You agree to use the app only for lawful purposes and in accordance with these Terms. You are responsible for maintaining the confidentiality of your account credentials.

**3. Subscriptions and Payments**
P2P Fit Tech AI offers subscription-based access to personal training services. Subscriptions are billed on a recurring basis. By subscribing, you authorize us to charge your payment method on the applicable billing cycle.

**4. Trainer Relationships**
Trainers on P2P Fit Tech AI are independent professionals. P2P Fit Tech AI acts as a platform connecting clients with trainers and is not responsible for the advice, programs, or conduct of individual trainers.

**5. Intellectual Property**
All content within the P2P Fit Tech AI app, including workout programs, videos, and AI-generated plans, is the property of P2P Fit Tech AI or its licensors. You may not reproduce, distribute, or create derivative works without written permission.

**6. Limitation of Liability**
P2P Fit Tech AI is not liable for any indirect, incidental, or consequential damages arising from your use of the app. Our total liability shall not exceed the amount you paid in the 12 months preceding the claim.

**7. Modifications**
We reserve the right to modify these Terms at any time. We will notify you of significant changes. Continued use of the app after changes constitutes acceptance of the updated Terms.

**8. Termination**
We reserve the right to terminate or suspend your account for violations of these Terms. You may cancel your account at any time through the app settings.

**9. Governing Law**
These Terms are governed by the laws of the State of Florida, United States.

**10. Contact**
For questions about these Terms, contact us at support@p2pfitchai.com
''',
    'privacy': '''
**Privacy Policy**
Last updated: August 1, 2026

P2P Fit Tech AI ("we," "us," or "our") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and protect your information.

**1. Information We Collect**
- **Account Information**: Name, email address, date of birth, and profile photo when you create an account.
- **Health & Fitness Data**: Weight, fitness goals, workout history, and progress metrics you provide.
- **Device Information**: Device type, operating system, IP address, and app usage data.
- **Payment Information**: Billing details processed securely through our payment providers. We do not store full card numbers.
- **Communications**: Messages exchanged between you and your trainer through our platform.

**2. How We Use Your Information**
- To provide and improve our services
- To connect you with qualified personal trainers
- To generate personalized AI workout and nutrition plans
- To process payments and manage subscriptions
- To send important notifications and updates
- To comply with legal obligations

**3. Data Sharing**
We do not sell your personal information. We share data only with:
- Your assigned trainer (workout progress, goals, messages)
- Payment processors (Stripe, Clover) for billing
- Service providers who help us operate the platform
- Law enforcement when required by law

**4. Data Security**
We implement industry-standard security measures including encryption, secure servers, and regular security audits to protect your data.

**5. Data Retention**
We retain your data for as long as your account is active. You may request deletion of your data at any time by contacting us.

**6. Your Rights**
You have the right to access, correct, or delete your personal information. Contact us at support@p2pfitchai.com to exercise these rights.

**7. Cookies and Tracking**
We use analytics tools to understand app usage. You can opt out of analytics through your device settings.

**8. Children's Privacy**
Our services are not directed to children under 18. We do not knowingly collect information from minors.

**9. Contact**
For privacy questions or concerns, contact us at support@p2pfitchai.com
''',
    'fitness': '''
**Fitness & Medical Disclaimer**
Last updated: August 1, 2026

**Important: Please read this disclaimer carefully before using P2P Fit Tech AI.**

**1. Not Medical Advice**
The content provided through P2P Fit Tech AI — including workout programs, nutrition guidance, AI-generated plans, and trainer recommendations — is for informational and fitness purposes only. It is NOT a substitute for professional medical advice, diagnosis, or treatment.

**2. Consult Your Doctor**
Before beginning any exercise program or making significant changes to your diet, consult with your physician or a qualified healthcare provider, especially if you:
- Have a pre-existing medical condition
- Are pregnant or postpartum
- Have experienced recent injury or surgery
- Are over 40 and not currently active
- Have cardiovascular, metabolic, or musculoskeletal conditions

**3. Exercise Risks**
Physical exercise involves inherent risks including but not limited to: muscle strains, joint injuries, cardiovascular events, and falls. By using this app, you acknowledge and assume these risks.

**4. Trainer Qualifications**
Trainers on our platform are fitness professionals, not licensed medical practitioners. Their guidance does not constitute medical advice.

**5. AI-Generated Content**
AI-generated workout and nutrition plans are based on the information you provide. The accuracy of these plans depends on the accuracy of your input. Always use your own judgment and consult a professional before following any AI-generated advice.

**6. Stop If You Feel Unwell**
If you experience pain, dizziness, shortness of breath, chest pain, or any unusual symptoms during exercise, stop immediately and seek medical attention.

**7. Limitation of Liability**
P2P Fit Tech AI, its trainers, and affiliates are not liable for any injuries, health complications, or adverse effects resulting from the use of our services.

**Contact**: support@p2pfitchai.com
''',
    'subscription': '''
**Subscription & Cancellation Policy**
Last updated: August 1, 2026

**1. Subscription Plans**
P2P Fit Tech AI offers monthly and annual subscription plans that provide access to personal trainer connections, AI workout generation, AI coaching, and premium content.

**2. Free Trial**
New users may be eligible for a free trial period. After the trial ends, you will be automatically charged the subscription fee unless you cancel before the trial period expires.

**3. Billing**
- Subscriptions are billed in advance on a recurring monthly or annual basis.
- Payment is charged to your Apple App Store or Google Play account at confirmation of purchase.
- Subscription renews automatically unless cancelled at least 24 hours before the end of the current period.

**4. Price Changes**
We may change subscription prices. We will notify you at least 30 days in advance of any price change. Continued use of the app after the price change constitutes acceptance.

**5. Cancellation**
You may cancel your subscription at any time through:
- iOS: Settings → [Your Name] → Subscriptions → P2P Fit Tech AI → Cancel
- Android: Google Play Store → Subscriptions → P2P Fit Tech AI → Cancel

Cancellation takes effect at the end of the current billing period. You retain access until that date.

**6. Refunds**
Subscription fees are generally non-refundable. Refund requests are handled according to the App Store or Google Play Store's refund policies. Contact support@p2pfitchai.com for exceptional circumstances.

**7. Trainer Subscriptions**
If you subscribe to an individual trainer's plan, that subscription is separate from the platform subscription. Cancellation policies for trainer-specific plans may differ — review the trainer's plan details before subscribing.

**8. Account Pausing**
At this time, we do not offer the ability to pause subscriptions. Cancel and re-subscribe when ready.

**Contact**: support@p2pfitchai.com
''',
    'community': '''
**Community Guidelines**
Last updated: August 1, 2026

P2P Fit Tech AI is built on the belief that fitness is better together. To keep our community safe, positive, and empowering, all members — users and trainers alike — must follow these guidelines.

**1. Be Respectful**
Treat every member of the community with respect. Harassment, bullying, hate speech, or discrimination based on race, gender, body type, religion, nationality, sexual orientation, or disability will result in immediate account suspension.

**2. Keep It Appropriate**
Do not share explicit, offensive, or inappropriate content. All profile photos, content posts, and messages must be suitable for a professional fitness environment.

**3. No Spam or Self-Promotion**
Do not use the platform to send unsolicited promotional messages or spam. Trainers may share their services only through designated channels.

**4. Accurate Information**
Provide accurate information about your fitness level, health conditions, and goals. Misleading information can lead to inappropriate training plans and potential injury.

**5. Protect Privacy**
Do not share other members' personal information, photos, or messages without their explicit consent.

**6. Trainers: Professional Standards**
Trainers are expected to maintain professional conduct at all times. Trainers must not provide medical diagnoses, guarantee specific results, or engage in inappropriate relationships with clients.

**7. Reporting**
If you witness a violation of these guidelines, report it immediately through the app's report function or by contacting support@p2pfitchai.com. We take all reports seriously.

**8. Enforcement**
Violations may result in content removal, account suspension, or permanent ban depending on severity. We reserve the right to make enforcement decisions at our sole discretion.

**9. Changes**
We may update these guidelines as our community grows. Continued use of the platform constitutes acceptance of any changes.

**Contact**: support@p2pfitchai.com
''',
    'delete': '''
**Delete Account & Data**
Last updated: August 1, 2026

We respect your right to control your personal data. This page explains how to request deletion of your account and associated data.

**1. What Gets Deleted**
When you delete your account, we permanently remove:
- Your profile information (name, email, photo, bio)
- Your fitness data (goals, workout history, progress metrics)
- Your messages with trainers
- Your payment methods (we do not store full card details)
- Your AI-generated workout and nutrition plans

**2. What Is Retained**
We may retain certain data as required by law or for legitimate business purposes:
- Transaction records for tax and accounting purposes (up to 7 years)
- Anonymized aggregate data used for analytics
- Data where retention is required by applicable law

**3. How to Request Deletion**
**Option A — In-App:**
Go to Settings → Delete My Account and follow the prompts.

**Option B — Email:**
Send a deletion request to support@p2pfitchai.com from your registered email address with the subject line "Account Deletion Request." Include your full name and registered email.

**4. Processing Time**
Account deletion is processed within 30 days of your request. You will receive a confirmation email when deletion is complete.

**5. Active Subscriptions**
Deleting your account does not automatically cancel active subscriptions. Cancel your subscription through the App Store or Google Play before requesting account deletion to avoid future charges.

**6. Reactivation**
Account deletion is permanent and cannot be undone. If you wish to use P2P Fit Tech AI in the future, you will need to create a new account.

**7. Data Portability**
Before deleting, you may request a copy of your data by contacting support@p2pfitchai.com.

**Contact**: support@p2pfitchai.com
''',
  };

  @override
  Widget build(BuildContext context) {
    final rawContent = _content[item.key] ?? 'Content coming soon.';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 34.w,
                      height: 34.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.chevron_left, size: 20.sp, color: Colors.black87),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: AppFontWeight.section,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 34.w),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
                child: Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _MarkdownText(content: rawContent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Simple bold-markdown renderer (no package needed) ───────────────────────
class _MarkdownText extends StatelessWidget {
  final String content;

  const _MarkdownText({required this.content});

  @override
  Widget build(BuildContext context) {
    final lines = content.trim().split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) => _buildLine(line)).toList(),
    );
  }

  Widget _buildLine(String line) {
    if (line.trim().isEmpty) return SizedBox(height: 8.h);

    // Bold heading lines (start and end with **)
    if (line.startsWith('**') && line.endsWith('**') && line.length > 4) {
      final text = line.substring(2, line.length - 2);
      return Padding(
        padding: EdgeInsets.only(bottom: 6.h, top: 10.h),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: AppFontWeight.section,
            color: Colors.black,
          ),
        ),
      );
    }

    // Lines with inline bold (**word**)
    if (line.contains('**')) {
      return Padding(
        padding: EdgeInsets.only(bottom: 5.h),
        child: RichText(text: _parseInlineBold(line)),
      );
    }

    // Plain paragraph
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Text(
        line,
        style: TextStyle(
          fontSize: 13.sp,
          color: Colors.black87,
          height: 1.6,
        ),
      ),
    );
  }

  TextSpan _parseInlineBold(String line) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int last = 0;

    for (final match in regex.allMatches(line)) {
      if (match.start > last) {
        spans.add(TextSpan(
          text: line.substring(last, match.start),
          style: TextStyle(fontSize: 13.sp, color: Colors.black87, height: 1.6),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: AppFontWeight.section,
          color: Colors.black,
          height: 1.6,
        ),
      ));
      last = match.end;
    }
    if (last < line.length) {
      spans.add(TextSpan(
        text: line.substring(last),
        style: TextStyle(fontSize: 13.sp, color: Colors.black87, height: 1.6),
      ));
    }
    return TextSpan(children: spans);
  }
}
