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
  VimeoPlayerController controller;
  final bool showDebugLogging;
  final ValueChanged<VimeoPlayerDataCallback>? dataCallback;
  final ValueChanged<double>? currentSecCallback;
  final ValueChanged<bool>? isFullscreenCallback;
  final bool showControls;
  final bool loop;
  final void Function(VimeoMetaData metaData) onEnded;
  final bool mute;
  RawVimeoPlayer({
    this.key,
    required this.baseUrl,
    required this.isFullscreenCallback,
    required this.onEnded,
    this.showDebugLogging = true,
    this.mute = false,
    required this.controller,
    this.currentSecCallback,
    this.showControls = true,
    this.dataCallback,
    this.loop = false,
  }) : super(key: key);

  @override
  _RawVimeoPlayerState createState() => _RawVimeoPlayerState();
}

class _RawVimeoPlayerState extends State<RawVimeoPlayer>
    with WidgetsBindingObserver, RawPlayerHelper {
  late VimeoPlayerController controller = widget.controller;
  late InAppWebViewController _webViewController;
  // ignore: prefer_final_fields
  bool _isPlayerReady = false;
  bool _isFullscreen = false;
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  void _loadJavaScript() async {
    const String script = '''
      var player = new Vimeo.Player(document.querySelector('iframe'));
      player.on('ended', function() {
        // Handle video end event here
        window.flutter_inappwebview.callHandler('onVideoEnd', 'Video ended');
      });
      player.on('loaded', function(id) {
        window.flutter_inappwebview.callHandler('onLoad', '');
      });
    ''';

    await _webViewController.evaluateJavascript(source: script);
  }

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
            loop: widget.loop,
            showControl: widget.showControls,
            vimeoId: widget.controller.initialVideoId,
            hash: widget.controller.securityId,
            isMuted: widget.mute,
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
            disallowOverScroll: true,
          ),
          crossPlatform: InAppWebViewOptions(
            userAgent: userAgent(controller.type == PlayerDeviceType.IPHONE),
            mediaPlaybackRequiresUserGesture: false,
            transparentBackground: true,
            clearCache: true,
          ),
        ),
        onLoadStart: (controller, url) {
          print("LOAD START");
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
          _loadJavaScript();
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
                    controller
                        .updateValue(controller.value.copyWith(isReady: true));
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
                });

          // _webViewController.evaluateJavascript(
          //   source: """
          //     var player = new Vimeo.Player(document.querySelector('iframe'));
          //     player.on('ended', function() {
          //     // Handle video end event here
          //     window.flutter_inappwebview.callHandler('onVideoEnd', 'Video ended');
          //     player.on('loaded', function(id) {
          //       window.flutter_inappwebview.callHandler('onLoad', '');
          //     });
          //   });
          // """,
          // );

          /* add js handlers */
          // webController
          //   ..addJavaScriptHandler(
          //       handlerName: 'Ready',
          //       callback: (_) {
          //         print('player ready xxx');
          // if (!controller.value.isReady) {
          //   controller
          //       .updateValue(controller.value.copyWith(isReady: true));
          // }
          //       })
          // ..addJavaScriptHandler(
          //     handlerName: 'VideoPosition',
          //     callback: (params) {
          //       print("CURRENT TIME: ${params}");
          //       if (widget.currentSecCallback != null) {
          //         widget.currentSecCallback!(
          //             double.parse(params.first.toString()));
          //       }
          //       controller.updateValue(controller.value.copyWith(
          //           videoPosition: double.parse(params.first.toString())));
          //     })
          //   ..addJavaScriptHandler(
          //       handlerName: 'VideoData',
          //       callback: (params) {
          //         //print('VideoData: ' + json.decode(params.first));
          //         controller.updateValue(controller.value.copyWith(
          //           videoTitle: params.first['title'].toString(),
          //           videoDuration:
          //               double.parse(params.first['duration'].toString()),
          //           videoWidth: double.parse(params.first['width'].toString()),
          //           videoHeight:
          //               double.parse(params.first['height'].toString()),
          //         ));
          //       })
          //   ..addJavaScriptHandler(
          //       handlerName: 'StateChange',
          //       callback: (params) async {
          //         switch (params.first) {
          //           case -2:
          //             controller.updateValue(
          //                 controller.value.copyWith(isBuffering: true));
          //             break;
          //           case -1:
          // controller.updateValue(controller.value
          //     .copyWith(isPlaying: false, hasEnded: true));
          //             print("HEARTBEAT FULLSCREEN END : $_isFullscreen");
          //             widget.onEnded(VimeoMetaData(
          //               videoDuration: Duration(
          //                 seconds: controller.value.videoDuration?.round() ?? 0,
          //               ),
          //               videoId: controller.initialVideoId,
          //               videoTitle: controller.value.videoTitle ?? "NON",
          //               isFullscreen: _isFullscreen,
          //             ));
          //             break;
          //           case 0:
          //             controller.updateValue(controller.value
          //                 .copyWith(isReady: true, isBuffering: false));
          //             break;
          //           case 1:
          //             controller.updateValue(
          //                 controller.value.copyWith(isPlaying: false));
          //             break;
          //           case 2:
          //             controller.updateValue(
          //                 controller.value.copyWith(isPlaying: true));
          //             break;
          //           case 3:
          //             // final bool isFullscreen = controller.value.isFullscreen;
          //             setState(() {
          //               fullscreenIndex += 1;
          //               if (fullscreenIndex % 2 == 0) {
          //                 if (widget.isFullscreenCallback != null) {
          //                   widget.isFullscreenCallback!(
          //                       controller.value.isFullscreen);
          //                 }
          //                 _isFullscreen = !_isFullscreen;
          //                 controller.updateValue(
          //                   controller.value.copyWith(
          //                     isFullscreen: !controller.value.isFullscreen,
          //                   ),
          //                 );
          //               }
          //             });
          //             break;
          //           default:
          //             print('default player state');
          //         }
          //         if (widget.dataCallback != null) {
          //           await Future.delayed(const Duration(milliseconds: 100));
          //           widget.dataCallback!(VimeoPlayerDataCallback(
          //             isFullscreen: controller.value.isFullscreen,
          //             isPlaying: controller.value.isPlaying,
          //           ));
          //         }
          //       });
        },
        // onLoadStop: (_controller, url) {
        //   if (_isPlayerReady) {
        //     controller.updateValue(
        //       controller.value.copyWith(isReady: true),
        //     );
        //   }
        //   String _js = '''
        //     if (!window.flutter_inappwebview.callHandler) {
        //         window.flutter_inappwebview.callHandler = function () {
        //             var _callHandlerID = setTimeout(function () { });
        //             window.flutter_inappwebview._callHandler(arguments[0], _callHandlerID, JSON.stringify(Array.prototype.slice.call(arguments, 1)));
        //             return new Promise(function (resolve, reject) {
        //                 window.flutter_inappwebview[_callHandlerID] = resolve;
        //             });
        //         };
        //     }
        //   ''';
        //   _controller.evaluateJavascript(source: _js);
        // },
      ),
    );
  }

  String boolean({required bool value}) => value ? "'1'" : "'0'";
}
