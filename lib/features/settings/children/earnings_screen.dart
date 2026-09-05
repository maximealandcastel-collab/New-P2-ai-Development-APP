import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/core/services/tenant_brand_service.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _selectedRefill = 'Elite';
  String _selectedSubscription = 'Pro';

  static const _orange = Color(0xFFFF6B00);
  static const _ink = Color(0xFF111318);
  static const _muted = Color(0xFF777A82);
  static const _page = Color(0xFFF7F7F8);

  final _refillPlans = const [
    _RefillPlan('Starter', '250', '\$9.99', '\$0.039 / token'),
    _RefillPlan('Pro', '750', '\$24.99', '\$0.033 / token'),
    _RefillPlan('Power', '2,000', '\$59.99', '\$0.030 / token'),
    _RefillPlan('Elite', '5,000', '\$129.99', '\$0.026 / token', bestValue: true),
  ];

  final _subscriptionPlans = const [
    _SubscriptionPlan('Basic', '500 tokens / mo', '\$14.99 / mo'),
    _SubscriptionPlan('Pro', '1,500 tokens / mo', '\$34.99 / mo', popular: true),
    _SubscriptionPlan('Premium', '3,000 tokens / mo', '\$64.99 / mo'),
    _SubscriptionPlan('Ultimate', '10,000 tokens / mo', '\$149.99 / mo'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildBalanceCard(),
                  SizedBox(height: 22.h),
                  _buildSectionHeading(
                    'What You Get With Your Refill',
                    'Your tokens power the AI tools available in ${TenantBrandService.to.displayName}.',
                  ),
                  SizedBox(height: 12.h),
                  _buildProviderRow(),
                  SizedBox(height: 22.h),
                  _buildSectionHeading(
                    'Choose Your Refill',
                    'More tokens. More power. More results.',
                  ),
                  SizedBox(height: 12.h),
                  _buildRefillPlans(),
                  SizedBox(height: 22.h),
                  _buildSectionHeading(
                    'Subscribe & Save More',
                    'Lock in value with bulk subscriptions.',
                  ),
                  SizedBox(height: 12.h),
                  _buildSubscriptionPlans(),
                  SizedBox(height: 20.h),
                  _buildPaymentMethods(),
                  SizedBox(height: 14.h),
                  _buildSecurityNote(),
                  SizedBox(height: 12.h),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCheckoutBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _roundHeaderButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => Navigator.maybePop(context),
              ),
              _roundHeaderButton(
                icon: Icons.help_outline_rounded,
                onTap: () => _showHelp(context),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Image.asset(
            TenantBrandService.to.logoAssetPath ?? 'assets/images/app_logo.png',
            height: 54.h,
            width: 92.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 5.h),
          Text(
            'Refill Tokens',
            style: TextStyle(
              color: Colors.black,
              fontSize: 27.sp,
              height: 1.08,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Power your AI. Unlock your potential.',
            style: TextStyle(color: _muted, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _roundHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1.5,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42.r,
          height: 42.r,
          child: Icon(icon, color: _ink, size: 23.r),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: EdgeInsets.fromLTRB(15.w, 13.h, 14.w, 13.h),
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Token Balance',
                  style: TextStyle(color: Colors.white, fontSize: 11.sp),
                ),
                SizedBox(height: 3.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '0',
                      style: TextStyle(
                        color: _orange,
                        fontSize: 34.sp,
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      'Tokens',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _showHistory(context),
            icon: Icon(Icons.bar_chart_rounded, size: 16.r),
            label: Text('Usage History', style: TextStyle(fontSize: 10.sp)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: _orange, width: 1),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          subtitle,
          style: TextStyle(color: _muted, fontSize: 10.5.sp),
        ),
      ],
    );
  }

  Widget _buildProviderRow() {
    final providers = const [
      _Provider('ANAM', 'Anam AI', 'Advanced content generation for workouts, nutrition plans, and more.', Color(0xFF101010)),
      _Provider('R', 'Replit', 'Scalable infrastructure and seamless deployment.', Color(0xFFFF7A00)),
      _Provider('◎', 'ChatGPT', 'AI-powered coaching support, smart responses, and personalized advice.', Color(0xFF101010)),
      _Provider('✳', 'Claude', 'Intelligent analysis and insights for your fitness and health journey.', Color(0xFFC76F4B)),
    ];

    return SizedBox(
      height: 194.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: providers.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, index) => _buildProviderCard(providers[index]),
      ),
    );
  }

  Widget _buildProviderCard(_Provider provider) {
    return Container(
      width: 107.w,
      padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFEAEAEC)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: provider.color,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              provider.badge,
              style: TextStyle(
                color: Colors.white,
                fontSize: provider.badge == 'ANAM' ? 9.sp : 26.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 9.h),
          Text(
            provider.name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 5.h),
          Expanded(
            child: Text(
              provider.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 9.2.sp,
                height: 1.25,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E6),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              'Included',
              style: TextStyle(
                color: _orange,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefillPlans() {
    return SizedBox(
      height: 128.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _refillPlans.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, index) {
          final plan = _refillPlans[index];
          final selected = _selectedRefill == plan.name;
          return _buildRefillCard(plan, selected);
        },
      ),
    );
  }

  Widget _buildRefillCard(_RefillPlan plan, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedRefill = plan.name),
      child: Container(
        width: 107.w,
        padding: EdgeInsets.fromLTRB(10.w, 10.h, 8.w, 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? _orange : const Color(0xFFEAEAEC),
            width: selected ? 1.3 : 1,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x08000000), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.name, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 5.h),
                Text(
                  plan.tokens,
                  style: TextStyle(color: _orange, fontSize: 18.sp, fontWeight: FontWeight.w700),
                ),
                Text('Tokens', style: TextStyle(color: _muted, fontSize: 9.sp)),
                const Spacer(),
                Text(plan.price, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 2.h),
                Text(plan.unitPrice, style: TextStyle(color: _muted, fontSize: 8.5.sp)),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: _radio(selected),
            ),
            if (plan.bestValue)
              Positioned(
                top: -10.h,
                left: 3.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _orange,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                  child: Text(
                    'BEST VALUE',
                    style: TextStyle(color: Colors.white, fontSize: 6.5.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlans() {
    return SizedBox(
      height: 104.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _subscriptionPlans.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, index) {
          final plan = _subscriptionPlans[index];
          final selected = _selectedSubscription == plan.name;
          return GestureDetector(
            onTap: () => setState(() => _selectedSubscription = plan.name),
            child: Container(
              width: 107.w,
              padding: EdgeInsets.fromLTRB(9.w, 11.h, 7.w, 7.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: selected ? _orange : const Color(0xFFEAEAEC),
                  width: selected ? 1.2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (plan.popular)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0E6),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        'MOST POPULAR',
                        style: TextStyle(
                          color: _orange,
                          fontSize: 6.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      _radio(selected),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Text(
                          plan.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(plan.tokens, style: TextStyle(color: _muted, fontSize: 8.5.sp)),
                  SizedBox(height: 5.h),
                  Text(plan.price, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _radio(bool selected) {
    return Container(
      width: 16.r,
      height: 16.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? _orange : const Color(0xFFD6D8DC), width: 1.2),
      ),
      padding: EdgeInsets.all(3.r),
      child: selected
          ? Container(decoration: const BoxDecoration(color: _orange, shape: BoxShape.circle))
          : null,
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE9EAEC)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 22.r, color: _ink),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Secure Checkout\nAll payments are encrypted and secure.',
              style: TextStyle(color: _muted, fontSize: 8.5.sp, height: 1.35),
            ),
          ),
          _paymentPill('VISA'),
          SizedBox(width: 4.w),
          _paymentPill('●●'),
          SizedBox(width: 4.w),
          _paymentPill(' Pay'),
          SizedBox(width: 4.w),
          _paymentPill('G Pay'),
        ],
      ),
    );
  }

  Widget _paymentPill(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: const Color(0xFFE1E2E5)),
      ),
      child: Text(label, style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildSecurityNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user_outlined, size: 14.r, color: _muted),
        SizedBox(width: 5.w),
        Text(
          'Your purchase is protected and tokens are delivered instantly.',
          style: TextStyle(color: _muted, fontSize: 9.sp),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 9.h, 16.w, 10.h),
        decoration: const BoxDecoration(
          color: _page,
          boxShadow: [
            BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, -3)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 49.h,
                child: ElevatedButton.icon(
                  onPressed: () => _showPurchaseNotice(context),
                  icon: const Icon(Icons.bolt_rounded, color: Colors.white),
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Refill Now', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                      Text('Instant delivery to your account', style: TextStyle(fontSize: 8.sp)),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            SizedBox(
              width: 108.w,
              height: 49.h,
              child: ElevatedButton.icon(
                onPressed: () => _showPurchaseNotice(context),
                icon: const Icon(Icons.apple, color: Colors.white, size: 21),
                label: Text('Pay', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Secure checkout for ${_selectedRefill} tokens will be available once payments are connected.',
        ),
      ),
    );
  }

  void _showHistory(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Usage History'),
        content: const Text('No token usage has been recorded yet.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About tokens'),
        content: const Text(
          'Tokens can be used for workout generation, AI coach conversations, and Anam AI sessions.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
        ],
      ),
    );
  }
}

class _RefillPlan {
  const _RefillPlan(this.name, this.tokens, this.price, this.unitPrice, {this.bestValue = false});

  final String name;
  final String tokens;
  final String price;
  final String unitPrice;
  final bool bestValue;
}

class _SubscriptionPlan {
  const _SubscriptionPlan(this.name, this.tokens, this.price, {this.popular = false});

  final String name;
  final String tokens;
  final String price;
  final bool popular;
}

class _Provider {
  const _Provider(this.badge, this.name, this.description, this.color);

  final String badge;
  final String name;
  final String description;
  final Color color;
}