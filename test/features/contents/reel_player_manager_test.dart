import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'dart:ui';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/reels/core/reel_player_manager.dart';

class FakeCacheManager extends Fake implements CacheManager {}

final class FakePreferences extends SharedPreferencesAsyncPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeVideoPlatform extends VideoPlayerPlatform {
  final streams = <int, StreamController<VideoEvent>>{};
  final playing = <int>{};
  final disposed = <int>{};
  int nextId = 0;
  @override
  Future<void> init() async {}
  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final id = nextId++;
    streams[id] = StreamController<VideoEvent>();
    return id;
  }
  void ready(int id) => streams[id]!.add(VideoEvent(
    eventType: VideoEventType.initialized, duration: const Duration(seconds: 10),
    size: const Size(100, 100),
  ));
  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => streams[playerId]!.stream;
  @override
  Future<void> dispose(int playerId) async { disposed.add(playerId); playing.remove(playerId); }
  @override
  Future<void> play(int playerId) async { playing.add(playerId); }
  @override
  Future<void> pause(int playerId) async { playing.remove(playerId); }
  @override
  Future<void> setLooping(int playerId, bool looping) async {}
  @override
  Future<void> setVolume(int playerId, double volume) async {}
  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}
  @override
  Future<void> seekTo(int playerId, Duration position) async {}
  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  CachedVideoPlayerPlus.cacheManager = FakeCacheManager();
  late FakeVideoPlatform platform;
  late VideoPlayerPlatform original;
  late ReelPlayerManager manager;
  final content = ContentModel(id: 'a', videoUrl: 'https://example.com/a.mp4');
  setUp(() {
    SharedPreferencesAsyncPlatform.instance = FakePreferences();
    original = VideoPlayerPlatform.instance;
    platform = FakeVideoPlatform();
    VideoPlayerPlatform.instance = platform;
    manager = ReelPlayerManager();
  });
  tearDown(() async {
    await manager.releaseAll();
    for (final stream in platform.streams.values) { unawaited(stream.close()); }
    VideoPlayerPlatform.instance = original;
  });
  test('leaving during initialization prevents late autoplay', () async {
    final load = manager.sync(index: 0, contents: [content]);
    await Future<void>.delayed(Duration.zero);
    await manager.pauseActive();
    platform.ready(0);
    await Future<void>.delayed(Duration.zero);
    await load;
    expect(manager.isReady(0), isTrue);
    expect(platform.playing, isEmpty);
    await manager.playActive();
    expect(platform.playing, {0});
    final reset = manager.sync(index: 0, contents: []);
    await Future<void>.delayed(Duration.zero);
    await reset;
    expect(platform.playing, isEmpty);
    expect(platform.disposed, contains(0));
  });
  test('slow HLS falls back and disposes a late primary player', () async {
    final load = manager.sync(index: 0, contents: [ContentModel(id: 'hls',
      muxPlaybackId: 'stream', processingStatus: 'ready', videoUrl: 'https://example.com/a.mp4')]);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(const Duration(seconds: 13));
    expect(platform.nextId, 2);
    platform.ready(1);
    await Future<void>.delayed(Duration.zero);
    await load;
    expect(platform.playing, {1});
    platform.ready(0);
    await Future<void>.delayed(Duration.zero);
    expect(platform.disposed, contains(0));
    expect(platform.playing, {1});
  });
  test('reset disposes a late initialization and leaves no active slot', () async {
    final load = manager.sync(index: 0, contents: [content]);
    await Future<void>.delayed(Duration.zero);
    await manager.reset();
    platform.ready(0);
    await Future<void>.delayed(Duration.zero);
    await load;
    expect(manager.slotFor(0), isNull);
    expect(platform.playing, isEmpty);
    expect(platform.disposed, contains(0));
  });
  test('replacing a video under the same content ID creates a new player', () async {
    var load = manager.sync(index: 0, contents: [content]);
    await Future<void>.delayed(Duration.zero);
    platform.ready(0);
    await Future<void>.delayed(Duration.zero);
    await load;
    load = manager.sync(index: 0, contents: [ContentModel(id: 'a', videoUrl: 'https://example.com/b.mp4')]);
    await Future<void>.delayed(Duration.zero);
    platform.ready(1);
    await Future<void>.delayed(Duration.zero);
    await load;
    expect(platform.disposed, contains(0));
    expect(platform.playing, {1});
  });
}
