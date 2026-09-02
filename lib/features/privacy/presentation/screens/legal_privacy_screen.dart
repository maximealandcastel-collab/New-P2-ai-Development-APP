import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';

/// The two documents shown in the Legal & Privacy center.
enum LegalDocument {
  privacy,
  terms,
}

class LegalPrivacyScreen extends StatefulWidget {
  final LegalDocument initialDocument;
  final bool consentMode;

  const LegalPrivacyScreen({
    super.key,
    this.initialDocument = LegalDocument.privacy,
    this.consentMode = false,
  });

  @override
  State<LegalPrivacyScreen> createState() => _LegalPrivacyScreenState();
}

class _LegalPrivacyScreenState extends State<LegalPrivacyScreen> {
  static const _accent = Color(0xFFFF5B1A);
  late LegalDocument _selectedDocument;
  int? _expandedIndex;
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    _selectedDocument = widget.initialDocument;
    _expandedIndex = widget.consentMode ? 0 : null;
  }

  @override
  Widget build(BuildContext context) {
    final document = _selectedDocument == LegalDocument.privacy
        ? _privacyPolicy
        : _termsOfService;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.consentMode) _buildConsentHeader() else _buildAppBar(),
            if (widget.consentMode)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildDocumentSwitcher(),
              ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 22.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.consentMode) _buildDocumentSwitcher(),
                    SizedBox(height: widget.consentMode ? 18.h : 25.h),
                    if (!widget.consentMode) _buildDocumentHeader(document),
                    if (!widget.consentMode) SizedBox(height: 20.h),
                    ...document.sections.asMap().entries.map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(bottom: 9.h),
                            child: _LegalSectionCard(
                              section: entry.value,
                              number: entry.key + 1,
                              isExpanded: _expandedIndex == entry.key,
                              accent: _accent,
                              onTap: () => setState(() {
                                _expandedIndex = _expandedIndex == entry.key
                                    ? null
                                    : entry.key;
                              }),
                            ),
                          ),
                        ),
                    SizedBox(height: 10.h),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
            if (widget.consentMode) _buildConsentFooter(),
          ],
        ),
      ),
    );
  }


  Widget _buildConsentHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF78A1D), Color(0xFFE85A12)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.monitor_heart_outlined, color: Colors.white, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                'Before you get started',
                style: TextStyle(color: const Color(0xFF76777C), fontSize: 14.sp),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Text(
            'Privacy & Terms',
            style: TextStyle(
              color: const Color(0xFF15161A),
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.35,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            "Everything's laid out below — no PDFs to chase down. Skim it, expand what you need, and accept when you're ready.",
            style: TextStyle(
              color: const Color(0xFF76777C),
              fontSize: 14.sp,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 10.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E8EA))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            checked: _agreed,
            label: 'Agree to the Privacy Policy and Terms of Service',
            child: InkWell(
              onTap: () => setState(() => _agreed = !_agreed),
              borderRadius: BorderRadius.circular(10.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreed,
                      activeColor: _accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                      onChanged: (value) => setState(() => _agreed = value ?? false),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(color: const Color(0xFF3C3D42), fontSize: 13.sp, height: 1.35),
                            children: const [
                              TextSpan(text: "I've read and agree to the "),
                              TextSpan(text: 'Privacy Policy', style: TextStyle(fontWeight: FontWeight.w700)),
                              TextSpan(text: ' and '),
                              TextSpan(text: 'Terms of Service', style: TextStyle(fontWeight: FontWeight.w700)),
                              TextSpan(text: ' above.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 9.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _agreed ? _acceptConsent : null,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _accent,
                disabledBackgroundColor: const Color(0xFFE2E3E6),
                foregroundColor: Colors.white,
                disabledForegroundColor: const Color(0xFF98999E),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
              ),
              child: Text(
                'Accept & continue',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Not right now', style: TextStyle(color: const Color(0xFF77787D), fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacyAccepted', true);
    if (!mounted) return;
    Get.offAllNamed(AppRoute.onboardingMainScreen);
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Go back',
            child: GestureDetector(
              onTap: () => Get.back(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 25.sp,
                  color: const Color(0xFF171717),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Legal & Privacy',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF111111),
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
          SizedBox(width: 38.w),
        ],
      ),
    );
  }

  Widget _buildDocumentSwitcher() {
    return Container(
      height: 48.h,
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE5E5E7)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _DocumentTab(
              label: 'Privacy Policy',
              selected: _selectedDocument == LegalDocument.privacy,
              accent: _accent,
              onTap: () => _selectDocument(LegalDocument.privacy),
            ),
          ),
          Expanded(
            child: _DocumentTab(
              label: 'Terms of Service',
              selected: _selectedDocument == LegalDocument.terms,
              accent: _accent,
              onTap: () => _selectDocument(LegalDocument.terms),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentHeader(_LegalDocumentContent document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          document.title,
          style: TextStyle(
            color: const Color(0xFF12131A),
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: -0.45,
          ),
        ),
        SizedBox(height: 7.h),
        Text(
          'Last updated: August 29, 2026',
          style: TextStyle(
            color: const Color(0xFF55565C),
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          document.introduction,
          style: TextStyle(
            color: const Color(0xFF36373C),
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.w, 8.h, 5.w, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.mail_outline_rounded, color: _accent, size: 18.sp),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              'Questions about these documents? Contact us at '
              'support@p2pfitchai.com.',
              style: TextStyle(
                color: const Color(0xFF67686D),
                fontSize: 12.sp,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDocument(LegalDocument document) {
    if (_selectedDocument == document) return;
    setState(() {
      _selectedDocument = document;
      _expandedIndex = null;
    });
  }
}

class _DocumentTab extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _DocumentTab({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.14)
                : const Color(0xFFE9EAED),
            borderRadius: BorderRadius.circular(21.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? accent : const Color(0xFF67686D),
              fontSize: 12.5.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalSectionCard extends StatelessWidget {
  final _LegalSection section;
  final int number;
  final bool isExpanded;
  final Color accent;
  final VoidCallback onTap;

  const _LegalSectionCard({
    required this.section,
    required this.number,
    required this.isExpanded,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      expanded: isExpanded,
      label: '$number. ${section.title}',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(13.w, 13.h, 12.w, 13.h),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _SectionIcon(icon: section.icon, accent: accent),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$number. ${section.title}',
                              style: TextStyle(
                                color: const Color(0xFF191A1F),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              section.summary,
                              maxLines: isExpanded ? null : 2,
                              overflow: isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFF64656A),
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w400,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: const Color(0xFF202126),
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                  if (isExpanded) ...[
                    SizedBox(height: 13.h),
                    Divider(height: 1, color: const Color(0xFFEDEDEF)),
                    SizedBox(height: 12.h),
                    ...section.paragraphs.map(
                      (paragraph) => Padding(
                        padding: EdgeInsets.only(bottom: 9.h),
                        child: Text(
                          paragraph,
                          style: TextStyle(
                            color: const Color(0xFF404146),
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionIcon extends StatelessWidget {
  final IconData icon;
  final Color accent;

  const _SectionIcon({
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Icon(icon, color: accent, size: 21.sp),
    );
  }
}

class _LegalDocumentContent {
  final String title;
  final String introduction;
  final List<_LegalSection> sections;

  const _LegalDocumentContent({
    required this.title,
    required this.introduction,
    required this.sections,
  });
}

class _LegalSection {
  final IconData icon;
  final String title;
  final String summary;
  final List<String> paragraphs;

  const _LegalSection({
    required this.icon,
    required this.title,
    required this.summary,
    required this.paragraphs,
  });
}

const _privacyPolicy = _LegalDocumentContent(
  title: 'Privacy Policy',
  introduction:
      'Your privacy is important to us. This Privacy Policy explains how '
      'P2P Fit Tech AI collects, uses, shares, and protects your information '
      'when you use our app and services.',
  sections: [
    _LegalSection(
      icon: Icons.person_outline_rounded,
      title: 'Information We Collect',
      summary: 'Profile, device, usage, health and fitness information.',
      paragraphs: [
        'When you create an account, we collect information such as your name, email address, date of birth, gender, profile photo, and contact details you choose to provide.',
        'You may also provide health and fitness information, including goals, measurements, equipment, injuries, workout history, preferences, and progress. Please only provide information you are comfortable sharing.',
        'We automatically receive limited device, diagnostic, and usage information needed to keep the app secure and improve reliability. We do not collect precise GPS location for the fitness experience.',
      ],
    ),
    _LegalSection(
      icon: Icons.track_changes_rounded,
      title: 'How We Use Information',
      summary: 'To provide, personalize, improve and secure our services.',
      paragraphs: [
        'We use your information to create and maintain your account, match you with trainers, deliver workouts and content, respond to support requests, and keep the service working.',
        'We also use it to personalize recommendations, understand product performance, prevent fraud or abuse, communicate important service updates, and comply with applicable law.',
      ],
    ),
    _LegalSection(
      icon: Icons.psychology_outlined,
      title: 'AI & Fitness Personalization',
      summary: 'How information powers personalized AI recommendations.',
      paragraphs: [
        'Information you provide about your goals, experience, schedule, equipment, limitations, and progress may be used to generate personalized workouts, nutrition guidance, and coaching responses.',
        'AI-generated guidance is based on the information available to the service and may not always be complete or appropriate for you. Review recommendations carefully and consult a qualified healthcare professional when needed.',
        'We may use aggregated or de-identified information to understand how the service performs and improve our tools. We do not use your private messages to advertise to you.',
      ],
    ),
    _LegalSection(
      icon: Icons.groups_outlined,
      title: 'Service Providers & Partners',
      summary: 'Trusted providers who help us operate the platform.',
      paragraphs: [
        'We work with carefully selected providers for hosting and storage, authentication, payments, customer support, push notifications, video delivery, analytics, and AI features.',
        'These providers receive only the information needed to perform services for us and must handle it under appropriate confidentiality and security obligations. Their own privacy notices may also apply.',
      ],
    ),
    _LegalSection(
      icon: Icons.share_outlined,
      title: 'Data Sharing, Licensing & Commercial Use',
      summary: 'We do not sell personal information.',
      paragraphs: [
        'We do not sell your personal information. We may share information with a trainer you choose when it is needed to deliver coaching, programs, messages, or progress support.',
        'If you post a review, profile photo, or other content publicly, you allow P2P Fit Tech AI to display and use that content to operate and promote the platform. You control what you choose to make public.',
        'We may disclose information when required by law, to protect users and the service, or in connection with a merger, acquisition, financing, or sale of business assets.',
      ],
    ),
    _LegalSection(
      icon: Icons.business_outlined,
      title: 'Gym & Enterprise Partners',
      summary: 'Information shared through a gym or employer program.',
      paragraphs: [
        'If you join through a gym, employer, or other enterprise program, the organization may receive limited participation or account information needed to administer that program.',
        'Your private conversations, detailed health information, and individual coaching content are not shared with a partner unless you clearly authorize it or disclosure is required by law.',
      ],
    ),
    _LegalSection(
      icon: Icons.credit_card_outlined,
      title: 'Payments & Subscriptions',
      summary: 'How billing, transactions and subscription access work.',
      paragraphs: [
        'Payments are processed by our payment partners, including the Apple App Store, Google Play, Stripe, or other providers shown at checkout. P2P Fit Tech AI does not store complete payment card numbers.',
        'We receive transaction details such as purchase status, plan, amount, currency, and subscription dates so we can activate access, provide support, prevent fraud, and keep required financial records.',
      ],
    ),
    _LegalSection(
      icon: Icons.schedule_outlined,
      title: 'Data Retention',
      summary: 'How long we keep information and why.',
      paragraphs: [
        'We keep account and fitness information while your account is active or for as long as it is reasonably needed to provide the service, resolve disputes, enforce agreements, and meet legal obligations.',
        'When you request account deletion, we delete or anonymize personal information within a reasonable period, except for records we must retain by law or legitimate business necessity. De-identified aggregate information may remain.',
      ],
    ),
    _LegalSection(
      icon: Icons.privacy_tip_outlined,
      title: 'Your Privacy Choices & Rights',
      summary: 'Access, correct, export or delete your information.',
      paragraphs: [
        'Depending on where you live, you may have rights to access, correct, export, restrict, or delete personal information, and to withdraw consent where processing relies on consent.',
        'You can update profile information in the app, manage notifications through device settings, and request account or data deletion through Settings or by emailing support@p2pfitchai.com. We may need to verify your identity before completing a request.',
      ],
    ),
    _LegalSection(
      icon: Icons.lock_outline_rounded,
      title: 'Security',
      summary: 'How we protect your information.',
      paragraphs: [
        'We use administrative, technical, and organizational safeguards designed to protect information, including access controls, encryption in transit, secure infrastructure, and monitoring for suspicious activity.',
        'No online service can guarantee absolute security. Please use a unique password, keep your device protected, and contact us promptly if you believe your account has been accessed without permission.',
      ],
    ),
  ],
);

const _termsOfService = _LegalDocumentContent(
  title: 'Terms of Service',
  introduction:
      'These Terms explain the rules for using P2P Fit Tech AI. By creating '
      'an account or using our app, you agree to these Terms and our Privacy '
      'Policy.',
  sections: [
    _LegalSection(
      icon: Icons.check_circle_outline_rounded,
      title: 'Acceptance of Terms',
      summary: 'The agreement that applies when you use P2P.',
      paragraphs: [
        'By downloading, accessing, or using P2P Fit Tech AI, you confirm that you have read and understood these Terms and agree to follow them. If you do not agree, do not use the service.',
        'You must be old enough to enter a binding agreement under the laws that apply to you. If you use the service for an organization, you confirm that you are authorized to accept these Terms for that organization.',
      ],
    ),
    _LegalSection(
      icon: Icons.fitness_center_outlined,
      title: 'Our Services',
      summary: 'What P2P Fit Tech AI provides.',
      paragraphs: [
        'P2P Fit Tech AI is a technology platform that connects people with trainers and provides workout content, AI-assisted workout and nutrition planning, coaching tools, messaging, and related fitness features.',
        'Features may change, be paused, or become unavailable as we improve the platform. We will make reasonable efforts to keep important services available and communicate material changes when appropriate.',
      ],
    ),
    _LegalSection(
      icon: Icons.account_circle_outlined,
      title: 'Accounts & Responsibilities',
      summary: 'Keep your account information accurate and secure.',
      paragraphs: [
        'Provide accurate information when you register and keep it current. You are responsible for protecting your password and for activity that occurs through your account. Do not share your account or use another person’s account without permission.',
        'Tell us promptly if you suspect unauthorized access. We may suspend or restrict an account to protect the user, the community, or the platform.',
      ],
    ),
    _LegalSection(
      icon: Icons.payments_outlined,
      title: 'Subscriptions & Billing',
      summary: 'Plans, renewals, cancellations and refunds.',
      paragraphs: [
        'Some features require a paid subscription. The price, billing cycle, trial terms, and included features are shown before purchase. Subscriptions may renew automatically unless you cancel through the store or payment provider before the renewal deadline.',
        'Apple App Store and Google Play purchases are managed by the applicable store. Refunds are handled under the store’s policies, except where applicable law requires otherwise. Contact support@p2pfitchai.com for help with a billing issue.',
        'Trainer plans and platform plans may be separate. A cancellation normally stops the next renewal while access continues through the current paid period.',
      ],
    ),
    _LegalSection(
      icon: Icons.groups_2_outlined,
      title: 'Trainers & Coaching Relationships',
      summary: 'How users and independent trainers work together.',
      paragraphs: [
        'Trainers may be independent professionals using P2P Fit Tech AI to offer coaching. P2P provides the technology and marketplace connection; a trainer remains responsible for their own services, communications, qualifications, and commitments.',
        'Evaluate whether a trainer’s services are appropriate for your needs. Do not ask a trainer or AI tool to replace a licensed healthcare professional.',
      ],
    ),
    _LegalSection(
      icon: Icons.health_and_safety_outlined,
      title: 'Fitness & Medical Disclaimer',
      summary: 'Important safety information before you train.',
      paragraphs: [
        'Workouts, nutrition information, trainer guidance, and AI-generated recommendations are for general educational and fitness purposes. They are not medical advice, diagnosis, or treatment.',
        'Exercise carries inherent risks. Speak with a qualified healthcare professional before starting a program, especially if you have an injury, medical condition, pregnancy, or other concern. Stop if you feel pain, dizziness, chest pain, severe shortness of breath, or unwell in any way, and seek medical help.',
        'Results vary from person to person. P2P Fit Tech AI does not guarantee a particular weight, strength, health, or performance result.',
      ],
    ),
    _LegalSection(
      icon: Icons.people_alt_outlined,
      title: 'Community Standards',
      summary: 'Keep the platform respectful, safe and professional.',
      paragraphs: [
        'Do not harass, threaten, discriminate against, impersonate, or exploit another person. Do not post hateful, sexually explicit, violent, illegal, deceptive, or malicious content.',
        'Do not spam, phish, distribute malware, misuse another person’s data, circumvent platform fees, or move a platform transaction outside the approved payment flow to avoid applicable charges.',
        'Report concerning content or behavior to support@p2pfitchai.com. We may remove content, limit features, suspend, or permanently close accounts that violate these standards.',
      ],
    ),
    _LegalSection(
      icon: Icons.copyright_outlined,
      title: 'Content & Intellectual Property',
      summary: 'Rules for using P2P content and sharing your own.',
      paragraphs: [
        'The app, brand, software, AI systems, videos, programs, graphics, and training materials are owned by or licensed to P2P Fit Tech AI. You may use them for personal, non-commercial fitness purposes only.',
        'You retain ownership of content you submit. You grant P2P a limited, non-exclusive license to host, display, process, and distribute that content as needed to operate and improve the platform. Do not upload content you do not have permission to use.',
      ],
    ),
    _LegalSection(
      icon: Icons.gavel_outlined,
      title: 'Liability & Indemnity',
      summary: 'Important limits on responsibility.',
      paragraphs: [
        'To the maximum extent permitted by law, P2P Fit Tech AI is not responsible for indirect, incidental, special, consequential, or punitive losses arising from your use of or inability to use the platform.',
        'Nothing in these Terms excludes liability that cannot legally be excluded, including liability for fraud or certain personal injury claims. You agree to reimburse us for reasonable losses arising from your violation of these Terms, misuse of the platform, or infringement of another person’s rights.',
      ],
    ),
    _LegalSection(
      icon: Icons.block_outlined,
      title: 'Suspension & Termination',
      summary: 'When access may be restricted or ended.',
      paragraphs: [
        'You may stop using the service at any time. We may suspend or terminate access when reasonably necessary to enforce these Terms, protect users, investigate abuse, comply with law, or address security or payment issues.',
        'When an account is closed, your right to use the service ends. Provisions that should continue by their nature, including intellectual property, disclaimers, liability limits, and dispute terms, remain effective.',
      ],
    ),
    _LegalSection(
      icon: Icons.mail_outline_rounded,
      title: 'Changes & Contact',
      summary: 'How we update these Terms and how to reach us.',
      paragraphs: [
        'We may update these Terms as the platform changes or legal requirements develop. For material changes, we will provide notice through the app, email, or another reasonable channel. Continued use after the effective date means you accept the updated Terms.',
        'Questions, complaints, or requests about these Terms can be sent to support@p2pfitchai.com. We will make a reasonable effort to respond and resolve concerns informally first.',
      ],
    ),
  ],
);
