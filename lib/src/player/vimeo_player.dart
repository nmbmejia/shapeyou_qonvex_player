import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';
import 'package:qonvex_player/src/controllers/vimeo_player_controller.dart';
import 'package:qonvex_player/src/models/vimeo_meta_data.dart';
import 'package:qonvex_player/src/player/raw_vimeo_player.dart';
// ignore: import_of_legacy_library_into_null_safe

// ignore: must_be_immutable
class QonvexVimeoPlayer extends StatefulWidget {
  final Key? key;
  final VimeoPlayerController controller;
  final double? height;
  final double? width;
  final double aspectRatio;
  final String url;
  int? skipDuration;
  final VoidCallback? onReady;

  QonvexVimeoPlayer(
      {this.key,
      required this.controller,
      this.width,
      required this.url,
      this.height,
      this.aspectRatio = 16 / 9,
      this.skipDuration = 5,
      this.onReady})
      : super(key: key);

  @override
  _QonvexVimeoPlayerState createState() => _QonvexVimeoPlayerState();
}

class _QonvexVimeoPlayerState extends State<QonvexVimeoPlayer>
    with SingleTickerProviderStateMixin {
  late final VimeoPlayerController controller;
  late final AnimationController _animationController;
  bool _initialLoad = true;
  late double _position;
  late double _aspectRatio;
  late final bool _seekingF;
  late final bool _seekingB;
  late final bool _isPlayerReady;
  late final bool _centerUiVisible;
  late final bool _bottomUiVisible;
  late final double _uiOpacity;
  bool _isBuffering = false;
  bool _isPlaying = false;
  late final int _seekDuration;
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

  _hideUi() {
    setState(() {
      _bottomUiVisible = false;
      _centerUiVisible = false;
      _uiOpacity = 0.0;
    });
  }

  _onPlay() {
    if (controller.value.isPlaying) {
      controller.pause();
      _animationController.forward();
    } else {
      controller.play();
      _animationController.reverse();
    }

    if (_initialLoad) {
      setState(() {
        _initialLoad = false;
        _centerUiVisible = false;
        _bottomUiVisible = true;
      });
    } else {
      setState(() {
        _centerUiVisible = false;
        _bottomUiVisible = true;
      });

      t = Timer(const Duration(seconds: 3), () {
        _hideUi();
      });
    }
  }

  // _onBottomPlayButton() {
  //   if (controller.value.isPlaying) {
  //     controller.pause();
  //     setState(() {
  //       _centerUiVisible = true;
  //       _bottomUiVisible = false;
  //       _uiOpacity = 1.0;
  //     });
  //     if (t != null && t!.isActive) {
  //       t!.cancel();
  //     }
  //   } else {
  //     controller.play();
  //   }
  // }

  _onUiTouched() {
    if (t != null && t!.isActive) {
      t!.cancel();
    }
    if (_isPlaying) {
      setState(() {
        _bottomUiVisible = true;
        _centerUiVisible = false;
        _uiOpacity = 1.0;
      });
      /* delayed animation */
      t = Timer(const Duration(seconds: 3), () {
        _hideUi();
      });
    }
  }

  _handleDoublTap(TapPosition details) {
    if (t != null && t!.isActive) {
      t!.cancel();
    }
    if (t2 != null && t2!.isActive) {
      t2!.cancel();
    }

    setState(() {
      _bottomUiVisible = true;
      _centerUiVisible = false;
      _uiOpacity = 1.0;
    });
    if (details.global.dx > MediaQuery.of(context).size.width / 2) {
      setState(() {
        _seekingF = true;
        _seekDuration = _seekDuration +
            (widget.skipDuration == null ? 0 : widget.skipDuration!);
      });
      /* seek fwd */
      controller.seekTo(
          _position + (widget.skipDuration == null ? 0 : widget.skipDuration!));
    } else {
      setState(() {
        _seekingB = true;
        _seekDuration = _seekDuration -
            (widget.skipDuration == null ? 0 : widget.skipDuration!);
      });
      /* seek Backward */
      controller.seekTo(
          _position - (widget.skipDuration == null ? 0 : widget.skipDuration!));
    }
    /* delayed animation */
    t = Timer(const Duration(seconds: 3), () {
      _hideUi();
    });
    t2 = Timer(const Duration(seconds: 1), () {
      setState(() {
        _seekingF = false;
        _seekingB = false;
        _seekDuration = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Material(
      elevation: 0,
      color: Colors.black,
      child: InheritedVimeoPlayer(
        controller: controller,
        child: SizedBox(
          width: widget.width ?? MediaQuery.of(context).size.width,
          child: AspectRatio(
            aspectRatio: _aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: <Widget>[
                RawVimeoPlayer(
                  controller: widget.controller,
                  key: widget.key,
                  onEnded: (VimeoMetaData metadata) {
                    setState(() {
                      _uiOpacity = 1.0;
                      _bottomUiVisible = false;
                      _centerUiVisible = true;
                      _initialLoad = true;
                    });
                    controller.reload();
                  },
                  baseUrl: widget.url,
                ),
                // PositionedTapDetector2(
                //   onTap: (TapPosition position) {
                //     _onUiTouched();
                //   },
                //   onDoubleTap: _handleDoublTap,
                //   child: AnimatedOpacity(
                //     opacity: _uiOpacity,
                //     curve: const Interval(0.5, 1),
                //     duration: const Duration(milliseconds: 600),
                //     child: controller.value.isReady
                //         ? Container(
                //             decoration: const BoxDecoration(
                //                 gradient: LinearGradient(
                //                     colors: [
                //                   Colors.transparent,
                //                   Colors.transparent,
                //                   Colors.black
                //                 ],
                //                     stops: [
                //                   0.0,
                //                   0.75,
                //                   1
                //                 ],
                //                     begin: Alignment.topCenter,
                //                     end: Alignment.bottomCenter)),
                //             child: controller.value.isReady
                //                 ? Center(
                //                     child: Row(
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.spaceEvenly,
                //                       children: <Widget>[
                //                         _seekingB
                //                             ? Row(
                //                                 children: <Widget>[
                //                                   Text(
                //                                     '${_seekDuration.toString()}s',
                //                                     style: const TextStyle(
                //                                         color: Colors.white,
                //                                         fontSize: 18),
                //                                   ),
                //                                   const Icon(
                //                                     Icons.fast_rewind,
                //                                     color: Colors.white,
                //                                   ),
                //                                 ],
                //                               )
                //                             : const SizedBox(),
                //                         _isBuffering
                //                             ? const CircularProgressIndicator(
                //                                 strokeWidth: 4,
                //                               )
                //                             : _centerUiVisible
                //                                 ? FloatingActionButton(
                //                                     elevation: 0,
                //                                     backgroundColor:
                //                                         Colors.white54,
                //                                     child: const Icon(
                //                                       Icons.play_arrow,
                //                                       color: Colors.white,
                //                                       size: 34,
                //                                     ),
                //                                     onPressed: () {
                //                                       _onPlay();
                //                                     })
                //                                 : const SizedBox(),
                //                         _seekingF
                //                             ? Row(
                //                                 children: <Widget>[
                //                                   const Icon(
                //                                     Icons.fast_forward,
                //                                     color: Colors.white,
                //                                   ),
                //                                   Text(
                //                                     '${_seekDuration.toString()}s',
                //                                     style: const TextStyle(
                //                                       color: Colors.white,
                //                                     ),
                //                                   )
                //                                 ],
                //                               )
                //                             : const SizedBox(),
                //                       ],
                //                     ),
                //                   )
                //                 : const SizedBox(
                //                     width: 1,
                //                   ),
                //           )
                //         : const SizedBox(),
                //   ),
                // ),
                // controller.value.isReady && _bottomUiVisible && !_initialLoad
                //     ? Positioned(
                //         height: height * 0.05,
                //         bottom: 0,
                //         child: AnimatedOpacity(
                //           duration: const Duration(milliseconds: 500),
                //           opacity: _uiOpacity,
                //           child: Flex(
                //               direction: Axis.horizontal,
                //               children: <Widget>[
                //                 GestureDetector(
                //                   child: SizedBox(
                //                     height: height * 0.05,
                //                     width: width * 0.1,
                //                     child: Icon(
                //                       controller.value.isPlaying
                //                           ? Icons.pause
                //                           : Icons.play_arrow,
                //                       color: Colors.white,
                //                     ),
                //                   ),
                //                   onTap: () {
                //                     /* pause button clicked */
                //                     _onBottomPlayButton();
                //                   },
                //                 ),
                //                 SizedBox(
                //                   width: width * 0.6,
                //                   child: Slider(
                //                     onChangeStart: (val) {
                //                       setState(() {
                //                         _seekingF = true;
                //                       });
                //                     },
                //                     label: _getTimestamp(),
                //                     onChangeEnd: (end) {
                //                       controller.seekTo(end.roundToDouble());
                //                       setState(() {
                //                         _seekingF = false;
                //                       });
                //                     },
                //                     inactiveColor: Colors.blueGrey,
                //                     min: 0,
                //                     max: controller.value.videoDuration != null
                //                         ? (controller.value.videoDuration ??
                //                                 0) +
                //                             1.0
                //                         : 0.0,
                //                     value: _position,
                //                     onChanged: (value) {
                //                       if (!_seekingF) {
                //                         setState(() {
                //                           if (value >= 0 &&
                //                               value <= _position) {
                //                             _position = value;
                //                           }
                //                         });
                //                       }
                //                     },
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   child: Text(
                //                     _getTimestamp() + "",
                //                     style: const TextStyle(
                //                         color: Colors.white, fontSize: 10),
                //                   ),
                //                 ),
                //                 GestureDetector(
                //                   child: SizedBox(
                //                     width: width * 0.1,
                //                     child: const Icon(
                //                       Icons.settings,
                //                       color: Colors.white,
                //                     ),
                //                   ),
                //                   onTap: () {},
                //                 ),
                //                 GestureDetector(
                //                   child: SizedBox(
                //                     width: width * 0.1,
                //                     child: const Icon(
                //                       Icons.fullscreen,
                //                       color: Colors.white,
                //                     ),
                //                   ),
                //                   onTap: () {},
                //                 )
                //               ]),
                //         ),
                //       )
                //     : const SizedBox(
                //         height: 1,
                //       )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _formatDuration(Duration time) {
  //   var ret = '';
  //   if (time.inHours > 0) {
  //     if (time.inHours < 10) {
  //       ret += '0${time.inHours}:';
  //     } else {
  //       ret += '${time.inHours}:';
  //     }
  //   }
  //   if (time.inSeconds > 0) {
  //     if (time.inSeconds < 10) {
  //       ret += '0${time.inSeconds}';
  //     } else {
  //       ret += '${time.inSeconds}';
  //     }
  //   } else {
  //     ret += '00';
  //   }

  //   return ret;
  // }

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
