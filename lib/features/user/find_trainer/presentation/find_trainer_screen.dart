import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// MODEL
// ═══════════════════════════════════════════════════════════════════════════════

class TrainerModel {
  final String name;
  final String role;
  final String experience;
  final String avatarUrl;

  const TrainerModel({
    required this.name,
    required this.role,
    required this.experience,
    required this.avatarUrl,
  });
}

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

  int _selectedFilter = 0;
  final List<String> _filterTabs = ['Top rated', 'Relevant', 'Rehab', 'Full re...'];

  // Sort dropdown
  bool _showSortMenu = false;
  String _selectedSort = 'Relevance';
  final List<String> _sortOptions = ['Relevance', 'By name'];

  // Search suggestions
  final List<String> _allSuggestions = [
    'Oliver Kingsley',
    'Oliver Ales',
    'Oliver Sinclair',
    'Olsia Caldwell',
  ];
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  static const List<TrainerModel> _allTrainers = [
    TrainerModel(
      name: 'Oliver Kingsley',
      role: 'Trainer',
      experience: '12 Years of Experience',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    ),
    TrainerModel(
      name: 'Noah Sinclair',
      role: 'Lead trainer',
      experience: '8 Years of Experience',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    ),
    TrainerModel(
      name: 'Ethan Hawthorne',
      role: 'Trainer',
      experience: '12 Yrs Exp',
      avatarUrl: 'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=200',
    ),
    TrainerModel(
      name: 'Lucas Brighton',
      role: 'Lead trainer',
      experience: '5 Years of Experience',
      avatarUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=200',
    ),
    TrainerModel(
      name: 'Mason Caldwell',
      role: 'Junior trainer',
      experience: '1 Year of Experience',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    ),
    TrainerModel(
      name: 'James Fletcher',
      role: 'Senior trainer',
      experience: '10 Years of Experience',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
    ),
  ];

  List<TrainerModel> get _filteredTrainers {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _allTrainers;
    return _allTrainers.where((t) => t.name.toLowerCase().contains(q)).toList();
  }

  void _onSearchChanged(String val) {
    setState(() {
      if (val.isEmpty) {
        _suggestions = [];
        _showSuggestions = false;
      } else {
        _suggestions = _allSuggestions
            .where((s) => s.toLowerCase().startsWith(val.toLowerCase()))
            .toList();
        _showSuggestions = _suggestions.isNotEmpty;
      }
    });
  }

  void _selectSuggestion(String name) {
    _searchCtrl.text = name;
    _searchFocus.unfocus();
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
  }

  void _openRequestSheet(TrainerModel trainer) {
    setState(() => _showSortMenu = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TrainerRequestSheet(trainer: trainer),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _searchFocus.unfocus();
        setState(() {
          _showSuggestions = false;
          _showSortMenu = false;
        });
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: SafeArea(
          child: Column(
            children: [
              // ── App Bar
              _AppBar(),
              SizedBox(height: 14.h),

              // ── Search + Filter row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _SearchBar(
                        controller: _searchCtrl,
                        focusNode: _searchFocus,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    _FilterBtn(
                      onTap: () => setState(() => _showSortMenu = !_showSortMenu),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // ── Filter tabs
              _FilterTabs(
                tabs: _filterTabs,
                selected: _selectedFilter,
                onChanged: (i) => setState(() => _selectedFilter = i),
              ),
              SizedBox(height: 12.h),

              // ── Content (list + overlays)
              Expanded(
                child: Stack(
                  children: [
                    // Trainer list
                    ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: _filteredTrainers.length,
                      itemBuilder: (_, i) => _TrainerCard(
                        trainer: _filteredTrainers[i],
                        onViewProfile: () {},
                        onRequest: () => _openRequestSheet(_filteredTrainers[i]),
                      ),
                    ),

                    // Autocomplete dropdown
                    if (_showSuggestions)
                      Positioned(
                        top: 0,
                        left: 16.w,
                        right: 56.w,
                        child: _SuggestionDropdown(
                          suggestions: _suggestions,
                          query: _searchCtrl.text,
                          onSelect: _selectSuggestion,
                        ),
                      ),

                    // Sort dropdown
                    if (_showSortMenu)
                      Positioned(
                        top: 0,
                        right: 16.w,
                        child: _SortDropdown(
                          options: _sortOptions,
                          selected: _selectedSort,
                          onSelect: (v) => setState(() {
                            _selectedSort = v;
                            _showSortMenu = false;
                          }),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
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
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Icon(Icons.chevron_left, size: 20.sp, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              'Find trainer',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: Colors.black),
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
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
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
                hintText: 'Search trainer by name or needs',
                hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
      ),
    );
  }
}

// ─── Filter Button ────────────────────────────────────────────────────────────
class _FilterBtn extends StatelessWidget {
  final VoidCallback onTap;

  const _FilterBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46.w,
        height: 46.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(Icons.tune, size: 20.sp, color: Colors.black87),
      ),
    );
  }
}

// ─── Filter Tabs ─────────────────────────────────────────────────────────────
class _FilterTabs extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  const _FilterTabs({required this.tabs, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: tabs.length,
        itemBuilder: (_, i) {
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: isSelected
                    ? []
                    : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
              ),
              child: Text(
                tabs[i],
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

// ─── Autocomplete Suggestion Dropdown ─────────────────────────────────────────
class _SuggestionDropdown extends StatelessWidget {
  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSelect;

  const _SuggestionDropdown({
    required this.suggestions,
    required this.query,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: suggestions.asMap().entries.map((e) {
          final isLast = e.key == suggestions.length - 1;
          return GestureDetector(
            onTap: () => onSelect(e.value),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 14.sp, color: Colors.grey.shade400),
                      SizedBox(width: 10.w),
                      _HighlightedText(text: e.value, query: query),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, indent: 14.w, endIndent: 14.w, color: Colors.grey.shade100),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightedText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: TextStyle(fontSize: 13.sp, color: Colors.black87));
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchStart = lowerText.indexOf(lowerQuery);

    if (matchStart == -1) {
      return Text(text, style: TextStyle(fontSize: 13.sp, color: Colors.black87));
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, matchStart),
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
          ),
          TextSpan(
            text: text.substring(matchStart, matchStart + query.length),
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          TextSpan(
            text: text.substring(matchStart + query.length),
            style: TextStyle(fontSize: 13.sp, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

// ─── Sort Dropdown ────────────────────────────────────────────────────────────
class _SortDropdown extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _SortDropdown({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: options.asMap().entries.map((e) {
          final isSelected = e.value == selected;
          final isLast = e.key == options.length - 1;
          return GestureDetector(
            onTap: () => onSelect(e.value),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 10.w,
                          height: 10.h,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, indent: 14.w, endIndent: 14.w, color: Colors.grey.shade100),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Trainer Card ─────────────────────────────────────────────────────────────
class _TrainerCard extends StatelessWidget {
  final TrainerModel trainer;
  final VoidCallback onViewProfile;
  final VoidCallback onRequest;

  const _TrainerCard({
    required this.trainer,
    required this.onViewProfile,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 26.r,
            backgroundImage: NetworkImage(trainer.avatarUrl),
            backgroundColor: const Color(0xFFEEEEEE),
            onBackgroundImageError: (_, __) {},
          ),
          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trainer.name,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black),
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
                        label: 'View profile',
                        filled: false,
                        onTap: onViewProfile,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _CardBtn(
                        label: 'Request',
                        filled: false,
                        onTap: onRequest,
                      ),
                    ),
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

class _CardBtn extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _CardBtn({required this.label, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34.h,
        decoration: BoxDecoration(
          color: filled ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

// ─── Trainer Request Bottom Sheet ─────────────────────────────────────────────
class _TrainerRequestSheet extends StatefulWidget {
  final TrainerModel trainer;

  const _TrainerRequestSheet({required this.trainer});

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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.trainer.name,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                    Text('${widget.trainer.role} · ${widget.trainer.experience}',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400)),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 15.sp, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          Divider(height: 1, color: Colors.grey.shade100),
          SizedBox(height: 20.h),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trainer request',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black)),
                SizedBox(height: 16.h),

                // Service type
                Text('Service type',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500)),
                SizedBox(height: 8.h),

                // Service dropdown trigger
                GestureDetector(
                  onTap: () => setState(() => _showServiceDropdown = !_showServiceDropdown),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
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
                            color: _selectedService != null ? Colors.black87 : Colors.grey.shade400,
                          ),
                        ),
                        Icon(
                          _showServiceDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 18.sp,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                  ),
                ),

                // Dropdown options
                if (_showServiceDropdown) ...[
                  SizedBox(height: 4.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4)),
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
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(e.value,
                                      style: TextStyle(fontSize: 13.sp, color: Colors.black87)),
                                ),
                              ),
                              if (!isLast)
                                Divider(height: 1, indent: 14.w, endIndent: 14.w, color: Colors.grey.shade100),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                SizedBox(height: 10.h),

                // Info box
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 13.sp, color: const Color(0xFF1565C0)),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Based on service hourly rate will be determined. Choose a service to see range price',
                          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF1565C0), height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Short message
                Text('Short message',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500)),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _messageCtrl,
                    maxLines: 3,
                    minLines: 3,
                    style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Write a short message',
                      hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Request trainer button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7A00),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Request trainer',
                      style: TextStyle(
                          color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
