import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/dio_api_client.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════════════════════

class _TopTrainer {
  final String name;
  final String role;
  final String experience;
  final String avatarUrl;

  const _TopTrainer({
    required this.name,
    required this.role,
    required this.experience,
    required this.avatarUrl,
  });
}

class _LiveTrainer {
  final String id;
  final String name;
  final String specialty;
  final String? profileImage;
  final String gender;
  final num? rating;
  final num? yearsExperience;

  const _LiveTrainer({
    required this.id,
    required this.name,
    required this.specialty,
    this.profileImage,
    required this.gender,
    this.rating,
    this.yearsExperience,
  });

  factory _LiveTrainer.fromJson(Map<String, dynamic> j) => _LiveTrainer(
        id: j['_id']?.toString() ?? '',
        name: j['name']?.toString() ?? 'Trainer',
        specialty: j['specialty']?.toString() ?? 'Fitness',
        profileImage: j['profileImage']?.toString(),
        gender: j['gender']?.toString() ?? 'male',
        rating: j['rating'] as num?,
        yearsExperience: j['yearsExperience'] as num?,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// HARDCODED TOP PICKS  (pinned trainers — stay fixed, males first)
// ═══════════════════════════════════════════════════════════════════════════════

const List<_TopTrainer> _topPicks = [
  _TopTrainer(
    name: 'Noah Sinclair',
    role: 'Lead Trainer',
    experience: '8 Years of Experience',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
  ),
  _TopTrainer(
    name: 'Ethan Hawthorne',
    role: 'Trainer',
    experience: '12 Years of Experience',
    avatarUrl: 'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=200',
  ),
  _TopTrainer(
    name: 'Lucas Brighton',
    role: 'Lead Trainer',
    experience: '5 Years of Experience',
    avatarUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=200',
  ),
  _TopTrainer(
    name: 'Mason Caldwell',
    role: 'Senior Trainer',
    experience: '10 Years of Experience',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
  ),
  _TopTrainer(
    name: 'Oliver Kingsley',
    role: 'Trainer',
    experience: '12 Years of Experience',
    avatarUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200',
  ),
  _TopTrainer(
    name: 'James Fletcher',
    role: 'Junior Trainer',
    experience: '1 Year of Experience',
    avatarUrl: 'https://images.unsplash.com/photo-1567515004624-219c11d31f2e?w=200',
  ),
];

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class FindTrainerScreen extends StatefulWidget {
  const FindTrainerScreen({super.key});

  @override
  State<FindTrainerScreen> createState() => _FindTrainerScreenState();
}

class _FindTrainerScreenState extends State<FindTrainerScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  // Gender filter — null means "All"
  String? _genderFilter; // null | 'male' | 'female'

  // Live trainer list state
  final List<_LiveTrainer> _trainers = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  static const int _pageSize = 20;

  // Search debounce
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPage();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _fetchPage();
    }
  }

  Future<void> _fetchPage() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      if (_genderFilter == null) {
        // No filter — fetch male + female in parallel, then interleave
        await _fetchInterleaved();
      } else {
        await _fetchFiltered(_genderFilter!);
      }
    } catch (_) {
      // silently ignore network errors
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchInterleaved() async {
    final half = (_pageSize / 2).ceil();

    final results = await Future.wait([
      _getTrainers(gender: 'male', limit: half),
      _getTrainers(gender: 'female', limit: half),
    ]);

    final males = results[0];
    final females = results[1];

    // Interleave: M, F, M, F …
    final merged = <_LiveTrainer>[];
    final max = males.length > females.length ? males.length : females.length;
    for (int i = 0; i < max; i++) {
      if (i < males.length) merged.add(males[i]);
      if (i < females.length) merged.add(females[i]);
    }

    if (mounted) {
      setState(() {
        _trainers.addAll(merged);
        _page++;
        _hasMore = males.length == half || females.length == half;
      });
    }
  }

  Future<void> _fetchFiltered(String gender) async {
    final items = await _getTrainers(gender: gender, limit: _pageSize);
    if (mounted) {
      setState(() {
        _trainers.addAll(items);
        _page++;
        _hasMore = items.length == _pageSize;
      });
    }
  }

  Future<List<_LiveTrainer>> _getTrainers({
    required String gender,
    required int limit,
  }) async {
    final params = <String, dynamic>{
      'catalogOnly': 'true',
      'skipPinned': 'true',
      'gender': gender,
      'page': _page.toString(),
      'limit': limit.toString(),
      if (_searchQuery.isNotEmpty) 'search': _searchQuery,
    };

    final url = '${ApiUrls.baseUrl}/trainers';
    final response = await NetworkCaller.instance.getRequest(
      url: url,
      queryParameters: params,
    );

    if (!response.isSuccess) return [];
    final body = response.responseBody;
    final List raw = body?['data']?['trainers'] ?? body?['trainers'] ?? [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(_LiveTrainer.fromJson)
        .toList();
  }

  void _resetAndFetch() {
    setState(() {
      _trainers.clear();
      _page = 1;
      _hasMore = true;
    });
    _fetchPage();
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchQuery = val.trim();
      _resetAndFetch();
    });
  }

  void _onGenderChanged(String? gender) {
    if (_genderFilter == gender) return;
    _genderFilter = gender;
    _resetAndFetch();
  }

  void _openRequestSheet(_LiveTrainer trainer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TrainerRequestSheet(name: trainer.name),
    );
  }

  void _openTopPickSheet(_TopTrainer trainer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TrainerRequestSheet(name: trainer.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _searchFocus.unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: SafeArea(
          child: Column(
            children: [
              // ── App Bar
              _AppBarWidget(),
              SizedBox(height: 14.h),

              // ── Search + Filter row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _SearchBar(
                  controller: _searchCtrl,
                  focusNode: _searchFocus,
                  onChanged: _onSearchChanged,
                ),
              ),
              SizedBox(height: 12.h),

              // ── Gender filter tabs
              _GenderTabs(
                selected: _genderFilter,
                onChanged: _onGenderChanged,
              ),
              SizedBox(height: 12.h),

              // ── Scrollable content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _resetAndFetch(),
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _listItemCount,
                    itemBuilder: _buildItem,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── List item count: section header + top picks + divider + live cards + loader
  int get _listItemCount {
    int count = 0;
    // Top picks section (only when no search query)
    if (_searchQuery.isEmpty) {
      count += 1; // "Top Picks" header
      count += _topPicks.length; // 6 pinned cards
      count += 1; // divider/spacer before live section
    }
    count += 1; // "Browse Trainers" header
    count += _trainers.length;
    if (_isLoading) count += 1; // loading indicator
    if (!_isLoading && !_hasMore && _trainers.isNotEmpty) count += 1; // end label
    return count;
  }

  Widget _buildItem(BuildContext context, int index) {
    if (_searchQuery.isEmpty) {
      // "Top Picks" header
      if (index == 0) return _SectionHeader(title: 'Top Picks');

      // Top pick cards
      if (index >= 1 && index <= _topPicks.length) {
        final t = _topPicks[index - 1];
        return _TopPickCard(
          trainer: t,
          onRequest: () => _openTopPickSheet(t),
        );
      }

      // Divider
      if (index == _topPicks.length + 1) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Divider(color: Colors.grey.shade300, thickness: 1),
        );
      }

      // Shift index past the pinned section
      index -= (_topPicks.length + 2); // +2 for header + divider
    }

    // "Browse Trainers" header
    if (index == 0) return _SectionHeader(title: 'Browse Trainers');

    // Live trainer cards
    final liveIdx = index - 1;
    if (liveIdx < _trainers.length) {
      final t = _trainers[liveIdx];
      return _LiveTrainerCard(
        trainer: t,
        onRequest: () => _openRequestSheet(t),
      );
    }

    // Loading / end of list
    final afterCards = liveIdx - _trainers.length;
    if (afterCards == 0) {
      if (_isLoading) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }
      if (!_hasMore && _trainers.isNotEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Center(
            child: Text('All trainers loaded',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400)),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h, bottom: 10.h),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────
class _AppBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 34.w,
              height: 34.h,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child:
                  Icon(Icons.chevron_left, size: 20.sp, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              'Find Trainer',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
          SizedBox(width: 34.w),
        ],
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Icon(Icons.search, size: 18.sp, color: Colors.grey.shade400),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: TextStyle(fontSize: 13.sp, color: Colors.black87),
              decoration: InputDecoration.collapsed(
                hintText: 'Search trainer by name or specialty',
                hintStyle:
                    TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
      ),
    );
  }
}

// ─── Gender Tabs ──────────────────────────────────────────────────────────────
class _GenderTabs extends StatelessWidget {
  final String? selected; // null = All
  final ValueChanged<String?> onChanged;

  const _GenderTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tabs = <String?>['All', 'Male', 'Female'];
    final values = <String?>[null, 'male', 'female'];

    return SizedBox(
      height: 36.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: tabs.length,
        itemBuilder: (_, i) {
          final isSelected = selected == values[i];
          return GestureDetector(
            onTap: () => onChanged(values[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: 8.w),
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: isSelected
                    ? []
                    : [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4)
                      ],
              ),
              child: Text(
                tabs[i]!,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Top Pick Card (hardcoded) ────────────────────────────────────────────────
class _TopPickCard extends StatelessWidget {
  final _TopTrainer trainer;
  final VoidCallback onRequest;

  const _TopPickCard({required this.trainer, required this.onRequest});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26.r,
            backgroundImage: NetworkImage(trainer.avatarUrl),
            backgroundColor: const Color(0xFFEEEEEE),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(trainer.name,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black)),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text('⭐ Top Pick',
                          style: TextStyle(
                              fontSize: 10.sp, color: Colors.black54)),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  '${trainer.role} · ${trainer.experience}',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                        child: _CardBtn(
                            label: 'View profile', onTap: () {})),
                    SizedBox(width: 8.w),
                    Expanded(
                        child:
                            _CardBtn(label: 'Request', onTap: onRequest)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Live Trainer Card (from API) ─────────────────────────────────────────────
class _LiveTrainerCard extends StatelessWidget {
  final _LiveTrainer trainer;
  final VoidCallback onRequest;

  const _LiveTrainerCard({required this.trainer, required this.onRequest});

  String get _experienceLabel {
    final yrs = trainer.yearsExperience?.toInt() ?? 0;
    if (yrs == 0) return 'Trainer';
    return yrs == 1 ? '1 Year of Experience' : '$yrs Years of Experience';
  }

  String get _ratingLabel {
    final r = trainer.rating?.toStringAsFixed(1) ?? '';
    return r.isNotEmpty ? '⭐ $r' : '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 26.r,
            backgroundColor: const Color(0xFFEEEEEE),
            backgroundImage: trainer.profileImage != null &&
                    trainer.profileImage!.isNotEmpty
                ? NetworkImage(trainer.profileImage!)
                : null,
            child: (trainer.profileImage == null ||
                    trainer.profileImage!.isEmpty)
                ? Icon(Icons.person, size: 24.sp, color: Colors.grey.shade400)
                : null,
          ),
          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(trainer.name,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black)),
                    ),
                    if (_ratingLabel.isNotEmpty)
                      Text(_ratingLabel,
                          style: TextStyle(
                              fontSize: 11.sp, color: Colors.grey.shade500)),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  '${trainer.specialty} · $_experienceLabel',
                  style:
                      TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                        child: _CardBtn(
                            label: 'View profile', onTap: () {})),
                    SizedBox(width: 8.w),
                    Expanded(
                        child:
                            _CardBtn(label: 'Request', onTap: onRequest)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card Button ──────────────────────────────────────────────────────────────
class _CardBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CardBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

// ─── Trainer Request Bottom Sheet ─────────────────────────────────────────────
class _TrainerRequestSheet extends StatefulWidget {
  final String name;
  const _TrainerRequestSheet({required this.name});

  @override
  State<_TrainerRequestSheet> createState() => _TrainerRequestSheetState();
}

class _TrainerRequestSheetState extends State<_TrainerRequestSheet> {
  String? _selectedService;
  bool _showServiceDropdown = false;
  final TextEditingController _messageCtrl = TextEditingController();

  final List<String> _serviceTypes = [
    'Strength Training',
    'Cardio',
    'Rehabilitation',
    'Yoga & Flexibility',
    'Weight Loss',
    'Post-Op Recovery',
  ];

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.name,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      Text('Personal Trainer',
                          style: TextStyle(
                              fontSize: 11.sp, color: Colors.grey.shade400)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28.w,
                      height: 28.h,
                      decoration: const BoxDecoration(
                          color: Color(0xFFF5F5F5), shape: BoxShape.circle),
                      child: Icon(Icons.close,
                          size: 15.sp, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Divider(height: 1, color: Colors.grey.shade100),
            SizedBox(height: 20.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trainer request',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  SizedBox(height: 16.h),
                  Text('Service type',
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.grey.shade500)),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () => setState(
                        () => _showServiceDropdown = !_showServiceDropdown),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 13.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedService ?? 'Select a service type',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: _selectedService != null
                                  ? Colors.black87
                                  : Colors.grey.shade400,
                            ),
                          ),
                          Icon(
                            _showServiceDropdown
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 18.sp,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showServiceDropdown) ...[
                    SizedBox(height: 4.h),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: _serviceTypes.asMap().entries.map((e) {
                          final isLast = e.key == _serviceTypes.length - 1;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedService = e.value;
                              _showServiceDropdown = false;
                            }),
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 12.h),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(e.value,
                                        style: TextStyle(
                                            fontSize: 13.sp,
                                            color: Colors.black87)),
                                  ),
                                ),
                                if (!isLast)
                                  Divider(
                                      height: 1,
                                      indent: 14.w,
                                      endIndent: 14.w,
                                      color: Colors.grey.shade100),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  Text('Message (optional)',
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.grey.shade500)),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _messageCtrl,
                      maxLines: 4,
                      style:
                          TextStyle(fontSize: 13.sp, color: Colors.black87),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(14.w),
                        hintText: 'Tell the trainer about your goals…',
                        hintStyle: TextStyle(
                            fontSize: 13.sp, color: Colors.grey.shade400),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      alignment: Alignment.center,
                      child: Text('Send Request',
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
