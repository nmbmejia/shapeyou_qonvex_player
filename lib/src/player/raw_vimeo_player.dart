import 'dart:collection';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:qonvex_player/src/controllers/vimeo_player_controller.dart';
import 'package:qonvex_player/src/helpers/raw_player_helper.dart';
import 'package:qonvex_player/src/models/vimeo_meta_data.dart';
import 'package:qonvex_player/src/models/vimeo_player_data_callback.dart';

// ignore: must_be_immutable
class RawVimeoPlayer extends StatefulWidget {
  final Key? key;
  final String baseUrl;
  final VimeoPlayerController controller;
  final bool showDebugLogging;
  final ValueChanged<VimeoPlayerDataCallback>? dataCallback;
  final ValueChanged<double>? currentSecCallback;
  final ValueChanged<bool>? isFullscreenCallback;
  final ValueChanged<bool>? onControllerStateCallback;
  final VoidCallback? onLoadPlayer;
  final VoidCallback? onPlayCallback;
  final VoidCallback? onPlayerReady;
  final void Function(VimeoMetaData metaData) onEnded;
  // final bool mute;
  // final bool playInBackground;
  // final bool
  //     allowAutoPause; // autopause player kun mayda current na nag plaplay
  const RawVimeoPlayer({
    this.key,
    required this.baseUrl,
    this.onPlayCallback,
    required this.isFullscreenCallback,
    required this.onEnded,
    this.showDebugLogging = true,
    this.onControllerStateCallback,
    this.onLoadPlayer,
    // this.mute = false,
    this.onPlayerReady,
    required this.controller,
    this.currentSecCallback,
    this.dataCallback,
    // this.allowAutoPause = true,
    // this.playInBackground = false,
  }) : super(key: key);

  @override
  _RawVimeoPlayerState createState() => _RawVimeoPlayerState();
}

class _RawVimeoPlayerState extends State<RawVimeoPlayer>
    with WidgetsBindingObserver, RawPlayerHelper {
  late VimeoPlayerController controller = widget.controller
    ..controllerStateCallback = widget.onControllerStateCallback;
  late InAppWebViewController _webViewController;
  // ignore: prefer_final_fields
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _width = window.physicalSize.width;
    _height = window.physicalSize.height;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  double _width = 0.0;
  double _height = 0.0;
  @override
  void didChangeMetrics() {
    setState(() {
      _width = window.physicalSize.width;
      _height = window.physicalSize.height;
    });
  }

  // bool _fullscreenHeartbeatEnable = false;
  int fullscreenIndex = 0;
  Future<IOSNavigationResponseAction> action() async =>
      IOSNavigationResponseAction.ALLOW;
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: InAppWebView(
        // key: _key,
        initialUserScripts: UnmodifiableListView<UserScript>([]),
        initialData: InAppWebViewInitialData(
          data: player(
            autoPlay: widget.controller.flags.autoPlay,
            loop: widget.controller.flags.loop,
            showControl: widget.controller.flags.controls,
            vimeoId: widget.controller.initialVideoId,
            hash: widget.controller.securityId,
            isMuted: widget.controller.flags.muted,
            autopause: widget.controller.flags.autoPause,
            isBackground: widget.controller.flags.background,
          ),
          baseUrl: Uri.parse(widget.baseUrl),
          encoding: 'utf-8',
          mimeType: 'text/html',
        ),

        initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true,
          ),
          ios: IOSInAppWebViewOptions(
            allowsInlineMediaPlayback: true,
          ),
          crossPlatform: InAppWebViewOptions(
            userAgent: userAgent(controller.type == PlayerDeviceType.IPHONE),
            mediaPlaybackRequiresUserGesture: false,
            transparentBackground: true,
            clearCache: true,
          ),
        ),
        onLoadStart: (controller, url) {
          // print("LOAD START");
        },
        onEnterFullscreen: (f) {
          print("IN FULLSCREEN");
          widget.controller.updateValue(
            controller.value.copyWith(isFullscreen: true),
          );
          if (widget.isFullscreenCallback != null) {
            widget.isFullscreenCallback!(true);
          }
          if (mounted) setState(() {});
        },
        onExitFullscreen: (f) {
          print("EXIT FULLSCREEN");
          widget.controller.updateValue(
            controller.value.copyWith(isFullscreen: false),
          );
          if (widget.isFullscreenCallback != null) {
            widget.isFullscreenCallback!(false);
          }
          if (mounted) setState(() {});
        },

        onWebViewCreated: (InAppWebViewController webController) async {
          _webViewController = webController;

          if (mounted) setState(() {});
          // _loadJavaScript();
          await webController.clearCache();
          controller.updateValue(
            controller.value.copyWith(webViewController: webController),
          );
          _webViewController
            ..addJavaScriptHandler(
                handlerName: "onVideoEnd",
                callback: (_) {
                  widget.onEnded(
                    VimeoMetaData(
                      isFullscreen: widget.controller.value.isFullscreen,
                    ),
                  );
                  widget.currentSecCallback!(
                      double.parse(_.first['seconds'].toString()));
                })
            ..addJavaScriptHandler(
                handlerName: "onLoad",
                callback: (_) {
                  if (!controller.value.isReady) {
                    controller.updateValue(
                      controller.value.copyWith(isReady: true),
                    );
                  }
                  if (widget.onLoadPlayer != null) {
                    widget.onLoadPlayer!();
                  }
                })
            ..addJavaScriptHandler(
                handlerName: 'videoPosition',
                callback: (params) {
                  if (widget.currentSecCallback != null) {
                    widget.currentSecCallback!(
                        double.parse(params.first['seconds'].toString()));
                  }
                  controller.updateValue(controller.value.copyWith(
                      videoPosition:
                          double.parse(params.first['seconds'].toString())));
                })
            ..addJavaScriptHandler(
              handlerName: 'onPlay',
              callback: (_) {
                if (widget.onPlayCallback != null) {
                  widget.onPlayCallback!();
                }
                // if (widget.controller.flags.autoPlay &&
                //     !widget.controller.value.hasPreloaded) {
                //   // hasPlayed = true;
                //   widget.controller.value.copyWith(hasPreloaded: true);
                //   widget.controller.pause();
                //   if (mounted) setState(() {});
                // }
              },
            )
            ..addJavaScriptHandler(
              handlerName: 'onReady',
              callback: (_) {
                if (widget.onPlayerReady != null) {
                  widget.onPlayerReady!();
                }
              },
            );
        },
      ),
    );
  }

  String boolean({required bool value}) => value ? "'1'" : "'0'";
}
