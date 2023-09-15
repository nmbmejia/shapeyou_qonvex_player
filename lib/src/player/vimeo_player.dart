import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';
import 'package:qonvex_player/src/controllers/vimeo_player_controller.dart';
import 'package:qonvex_player/src/models/vimeo_meta_data.dart';
import 'package:qonvex_player/src/models/vimeo_player_data_callback.dart';
import 'package:qonvex_player/src/player/raw_vimeo_player.dart';
// ignore: import_of_legacy_library_into_null_safe

// ignore: must_be_immutable
class QonvexVimeoPlayer extends StatefulWidget {
  final Key? key;
  VimeoPlayerController controller;
  final double? height;
  final double? width;
  final double aspectRatio;
  final bool allowFullscreen;
  final String url;
  final bool isMuted;
  final ValueChanged<VimeoPlayerDataCallback>? dataCallback;
  int? skipDuration;
  final ValueChanged<bool> isCompleted;
  final ValueChanged<double>? currentSecCallback;
  final VoidCallback? onReady;
  final ValueChanged<bool>? isFullscreenCallback;
  final bool showDebugLogging, showControl, loop;

  QonvexVimeoPlayer(
      {this.key,
      required this.controller,
      this.currentSecCallback,
      this.allowFullscreen = true,
      this.isFullscreenCallback,
      this.width,
      this.isMuted = false,
      required this.url,
      this.showDebugLogging = true,
      this.height,
      this.aspectRatio = 16 / 9,
      this.skipDuration = 5,
      this.dataCallback,
      required this.isCompleted,
      this.onReady,
      this.loop = false,
      this.showControl = true})
      : super(key: key);

  @override
  _QonvexVimeoPlayerState createState() => _QonvexVimeoPlayerState();
}

class _QonvexVimeoPlayerState extends State<QonvexVimeoPlayer>
    with SingleTickerProviderStateMixin {
  late VimeoPlayerController controller;
  late final AnimationController _animationController;
  bool _initialLoad = true;
  late double _position;
  late double _aspectRatio;
  late bool _seekingF;
  late bool _seekingB;
  late bool _isPlayerReady;
  late bool _centerUiVisible;
  late bool _bottomUiVisible;
  late double _uiOpacity;
  bool _isBuffering = false;
  bool _isPlaying = false;
  late int _seekDuration;
  late final CancelableCompleter completer;
  Timer? t;
  Timer? t2;
  // late final Animation _playPauseAnimation;

  void listener() async {
    if (controller.value.isReady) {
      if (!_isPlayerReady) {
        if (widget.onReady != null) {
          widget.onReady!();
          setState(() {
            _centerUiVisible = true;
            _isPlayerReady = true;
          });
        }
      }
    }
    setState(() {
      _isPlaying = controller.value.isPlaying;
      _isBuffering = controller.value.isBuffering;
    });
    if (controller.value.videoWidth != null &&
        controller.value.videoHeight != null) {
      setState(() {
        _aspectRatio = (double.parse((controller.value.videoWidth ??
                    MediaQuery.of(context).size.width)
                .toString()) /
            double.parse((controller.value.videoHeight ??
                    MediaQuery.of(context).size.height)
                .toString()));
      });
    }
    if (controller.value.videoPosition != null) {
      setState(() {
        _position = controller.value.videoPosition!;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller..addListener(listener);
    _aspectRatio = widget.aspectRatio;
    _position = 0.0;
    _seekingF = false;
    _seekingB = false;
    _bottomUiVisible = false;
    _uiOpacity = 1.0;
    _isPlaying = false;
    _initialLoad = true;
    _isBuffering = false;
    _centerUiVisible = true;
    _isPlayerReady = false;
    _seekDuration = 0;

    completer = CancelableCompleter(onCancel: () {
      setState(() {
        _bottomUiVisible = true;
        _uiOpacity = 1.0;
      });
    });

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void didUpdateWidget(QonvexVimeoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(listener);
    widget.controller.addListener(listener);
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: InheritedVimeoPlayer(
        controller: controller,
        child: SizedBox(
          width: widget.width ?? MediaQuery.of(context).size.width,
          child: AspectRatio(
            aspectRatio: _aspectRatio,
            child: RawVimeoPlayer(
              showControls: widget.showControl,
              loop: widget.loop,
              showDebugLogging: widget.showDebugLogging,
              isFullscreenCallback: widget.isFullscreenCallback,
              mute: widget.isMuted,
              key: widget.key,
              dataCallback: widget.dataCallback,
              currentSecCallback: widget.currentSecCallback,
              controller: widget.controller,
              onEnded: (VimeoMetaData metadata) {
                print(
                    "PLAYER ON END FULLSCREEN VALUE: ${metadata.isFullscreen}");
                widget.isCompleted(metadata.isFullscreen);
                controller.reset();
              },
              baseUrl: widget.url,
            ),
          ),
        ),
      ),
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    var ret = '';

    String twoDigitHours = twoDigits(duration.inHours.remainder(60));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (twoDigitHours != '00') {
      ret += '$twoDigitHours:';
    }
    ret += '$twoDigitMinutes:';
    ret += twoDigitSeconds;

    return ret == '' ? '0:00' : ret;
  }

  _getTimestamp() {
    var position = _printDuration(
        Duration(seconds: (controller.value.videoPosition ?? 0).round()));
    var duration = _printDuration(
        Duration(seconds: (controller.value.videoDuration ?? 0).round()));

    return '$position/$duration';
  }
}
