import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/features/contents/core/content_media_resolver.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';

void main() {
  test('ready streams retain the original video as a recovery source', () {
    final content = ContentModel(id: 'one', muxPlaybackId: 'stream',
        processingStatus: 'ready', videoUrl: 'https://example.com/video.mp4');
    expect(ContentMediaResolver.videoCandidates(content), [
      'https://stream.mux.com/stream.m3u8', 'https://example.com/video.mp4',
    ]);
    content.processingStatus = 'processing';
    expect(ContentMediaResolver.videoCandidates(content), ['https://example.com/video.mp4']);
  });
  test('replacing media under the same content ID invalidates the player', () {
    final content = ContentModel(id: 'one', videoUrl: 'https://example.com/a.mp4');
    final original = ContentMediaResolver.sourceKey(content);
    content.videoUrl = 'https://example.com/b.mp4';
    expect(ContentMediaResolver.sourceKey(content), isNot(original));
    final replaced = ContentMediaResolver.sourceKey(content);
    content.updatedAt = '2026-09-15T12:00:00Z';
    expect(ContentMediaResolver.sourceKey(content), isNot(replaced));
  });
  test('empty and duplicate media do not create redundant attempts', () {
    expect(ContentMediaResolver.videoCandidates(ContentModel()), isEmpty);
    expect(ContentMediaResolver.videoCandidates(ContentModel(videoUrl: 'https://example.com/a.mp4')), hasLength(1));
  });
}
