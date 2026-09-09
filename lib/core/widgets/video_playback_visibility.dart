import 'package:flutter/widgets.dart';

/// Playback eligibility for a tab kept alive under a navigator.
/// The tab host must disable TickerMode for unselected tabs.
class VideoPlaybackVisibility extends StatefulWidget {
  const VideoPlaybackVisibility({
    super.key,
    required this.onVisibilityChanged,
    required this.child,
  });

  final ValueChanged<bool> onVisibilityChanged;
  final Widget child;

  @override
  State<VideoPlaybackVisibility> createState() =>
      _VideoPlaybackVisibilityState();
}

class _VideoPlaybackVisibilityState extends State<VideoPlaybackVisibility>
    with WidgetsBindingObserver {
  bool _tabActive = false;
  bool _routeCurrent = false;
  bool _foreground = true;
  bool? _visible;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Keep compatibility with the pinned Flutter SDK.
    // ignore: deprecated_member_use
    _tabActive = TickerMode.of(context);
    _routeCurrent = ModalRoute.isCurrentOf(context) ?? true;
    // Notify after build so the owning screen can safely update its state.
    // Read the latest gates then, so a queued callback cannot restart a hidden feed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _sync();
  }

  void _sync() {
    final visible = _tabActive && _routeCurrent && _foreground;
    if (_visible == visible) return;
    _visible = visible;
    widget.onVisibilityChanged(visible);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
