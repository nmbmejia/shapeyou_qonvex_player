import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class VimeoPlayerValue {
  final bool isReady;
  bool isPlaying;
  final bool isFullscreen;
  bool isBuffering;
  final bool hasEnded;
  final bool hasPreloaded;
  final String? videoTitle;
  final double? videoPosition;
  final double? videoDuration;
  final double? videoWidth;
  final double? videoHeight;
  final InAppWebViewController? webViewController;

  VimeoPlayerValue({
    this.isReady = false,
    this.isPlaying = false,
    this.isFullscreen = false,
    this.isBuffering = false,
    this.hasEnded = false,
    this.hasPreloaded = false,
    this.videoTitle,
    this.videoPosition,
    this.videoDuration,
    this.videoWidth,
    this.videoHeight,
    required this.webViewController,
  });
  VimeoPlayerValue copyWith(
      {bool? isReady,
      bool? isPlaying,
      bool? isFullscreen,
      bool? isBuffering,
      bool? hasEnded,
      bool? hasPreloaded,
      String? videoTitle,
      double? videoPosition,
      double? videoDuration,
      double? videoWidth,
      double? videoHeight,
      InAppWebViewController? webViewController}) {
    return VimeoPlayerValue(
      isReady: isReady ?? this.isReady,
      isPlaying: isPlaying ?? this.isPlaying,
      hasPreloaded: hasPreloaded ?? this.hasPreloaded,
      isFullscreen: isFullscreen ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      hasEnded: hasEnded ?? this.hasEnded,
      videoTitle: videoTitle ?? this.videoTitle,
      videoDuration: videoDuration ?? this.videoDuration,
      videoWidth: videoWidth ?? this.videoWidth,
      videoHeight: videoHeight ?? this.videoHeight,
      videoPosition: videoPosition ?? this.videoPosition,
      webViewController: webViewController ?? this.webViewController,
    );
  }
}
