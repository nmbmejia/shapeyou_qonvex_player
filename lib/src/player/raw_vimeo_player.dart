import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:qonvex_player/src/controllers/vimeo_player_controller.dart';
import 'package:qonvex_player/src/models/vimeo_meta_data.dart';
import 'package:qonvex_player/src/models/vimeo_player_data_callback.dart';

// class CompletedCallback {
//   final bool isFullscreen;

// }

class RawVimeoPlayer extends StatefulWidget {
  final Key? key;
  final String baseUrl;
  VimeoPlayerController controller;
  final ValueChanged<VimeoPlayerDataCallback>? dataCallback;
  final ValueChanged<double>? currentSecCallback;
  final ValueChanged<bool>? isFullscreenCallback;

  final void Function(VimeoMetaData metaData) onEnded;
  final bool allowFullscreen;
  final bool mute;
  RawVimeoPlayer({
    this.key,
    required this.baseUrl,
    required this.isFullscreenCallback,
    required this.onEnded,
    this.mute = false,
    required this.controller,
    this.currentSecCallback,
    this.allowFullscreen = true,
    this.dataCallback,
  }) : super(key: key);

  @override
  _RawVimeoPlayerState createState() => _RawVimeoPlayerState();
}

class _RawVimeoPlayerState extends State<RawVimeoPlayer>
    with WidgetsBindingObserver {
  late VimeoPlayerController controller = widget.controller;
  // ignore: prefer_final_fields
  bool _isPlayerReady = false;
  bool _isFullscreen = false;
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
  @override
  Widget build(BuildContext context) {
    // double pxHeight = MediaQuery.of(context).size.height;
    // double pxWidth = MediaQuery.of(context).size.width;

    return IgnorePointer(
      ignoring: false,
      child: InAppWebView(
        // key: _key,
        initialData: InAppWebViewInitialData(
            data: player(_width),
            baseUrl: Uri.parse(widget.baseUrl),
            encoding: 'utf-8',
            mimeType: 'text/html'),
        initialOptions: InAppWebViewGroupOptions(
            ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: false),
            crossPlatform: InAppWebViewOptions(
                userAgent: userAgent,
                mediaPlaybackRequiresUserGesture: false,
                transparentBackground: true)),
        onWebViewCreated: (webController) {
          controller.updateValue(
            controller.value.copyWith(webViewController: webController),
          );
          /* add js handlers */
          webController
            ..addJavaScriptHandler(
                handlerName: 'Ready',
                callback: (_) {
                  print('player ready xxx');
                  if (!controller.value.isReady) {
                    controller
                        .updateValue(controller.value.copyWith(isReady: true));
                  }
                })
            ..addJavaScriptHandler(
                handlerName: 'VideoPosition',
                callback: (params) {
                  // print(
                  //     "CURRENT TIME: ${double.parse(params.first.toString())}");
                  if (widget.currentSecCallback != null) {
                    widget.currentSecCallback!(
                        double.parse(params.first.toString()));
                  }
                  controller.updateValue(controller.value.copyWith(
                      videoPosition: double.parse(params.first.toString())));
                })
            ..addJavaScriptHandler(
                handlerName: 'VideoData',
                callback: (params) {
                  //print('VideoData: ' + json.decode(params.first));
                  controller.updateValue(controller.value.copyWith(
                    videoTitle: params.first['title'].toString(),
                    videoDuration:
                        double.parse(params.first['duration'].toString()),
                    videoWidth: double.parse(params.first['width'].toString()),
                    videoHeight:
                        double.parse(params.first['height'].toString()),
                  ));
                })
            ..addJavaScriptHandler(
                handlerName: 'StateChange',
                callback: (params) async {
                  switch (params.first) {
                    case -2:
                      controller.updateValue(
                          controller.value.copyWith(isBuffering: true));
                      break;
                    case -1:
                      controller.updateValue(controller.value
                          .copyWith(isPlaying: false, hasEnded: true));
                      print("HEARTBEAT FULLSCREEN END : $_isFullscreen");
                      widget.onEnded(VimeoMetaData(
                        videoDuration: Duration(
                          seconds: controller.value.videoDuration?.round() ?? 0,
                        ),
                        videoId: controller.initialVideoId,
                        videoTitle: controller.value.videoTitle ?? "NON",
                        isFullscreen: _isFullscreen,
                      ));
                      break;
                    case 0:
                      controller.updateValue(controller.value
                          .copyWith(isReady: true, isBuffering: false));
                      break;
                    case 1:
                      controller.updateValue(
                          controller.value.copyWith(isPlaying: false));
                      break;
                    case 2:
                      controller.updateValue(
                          controller.value.copyWith(isPlaying: true));
                      break;
                    case 3:
                      // final bool isFullscreen = controller.value.isFullscreen;
                      setState(() {
                        fullscreenIndex += 1;
                        if (fullscreenIndex % 2 == 0) {
                          // if (widget.isFullscreenCallback != null) {
                          //   widget.isFullscreenCallback!(
                          //       controller.value.isFullscreen);
                          // }
                          _isFullscreen = !_isFullscreen;
                          controller.updateValue(
                            controller.value.copyWith(
                              isFullscreen: !controller.value.isFullscreen,
                            ),
                          );
                        } else {
                          if (widget.isFullscreenCallback != null) {
                            widget.isFullscreenCallback!(
                                controller.value.isFullscreen);
                          }
                          print("FFAF");
                        }
                      });
                      print("FULLSCREEN INDEX: $fullscreenIndex");
                      print(
                          "HEARTBEAT FULLSCREENss : ${controller.value.isFullscreen}");

                      // setState(() {
                      //   controller.updateValue(
                      //     controller.value.copyWith(
                      //       isFullscreen: !controller.value.isFullscreen,
                      //     ),
                      //   );
                      // });
                      break;
                    default:
                      print('default player state');
                  }
                  if (widget.dataCallback != null) {
                    await Future.delayed(const Duration(milliseconds: 100));
                    widget.dataCallback!(VimeoPlayerDataCallback(
                      isFullscreen: controller.value.isFullscreen,
                      isPlaying: controller.value.isPlaying,
                    ));
                  }
                });
        },
        onLoadStop: (_, __) {
          if (_isPlayerReady) {
            controller.updateValue(
              controller.value.copyWith(isReady: true),
            );
          }
        },
      ),
    );
  }

  String player(double width) {
    var _player = '''<html>
      <head>
      <style>
        html,
        body {
            margin: 0;
        }
        
      </style>
      <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'>
      </head>
      <body>
        <iframe src="https://player.vimeo.com/video/${controller.initialVideoId}?h=${controller.securityId}&muted=${widget.mute ? 1 : 0}&dnt=0&playsinline=1&app_id=${controller.appId}&autoplay=${controller.flags.autoPlay}&quality=auto" width="100%" height="100%"frameborder="0" allowfullscreen allow=autoplay;fullscreen controls="1"></iframe>
        <script src="https://player.vimeo.com/api/player.js"></script>
        <script>
        let iframe = document.querySelector('iframe');
        var options = {
          id: ${controller.initialVideoId},
          title: false,
          transparent: true,
          autoplay: ${controller.flags.autoPlay},
          speed: true,
          controls: true,
          dnt: false,
        };
        
        var videoData = {};
        var vimPlayer = new Vimeo.Player(iframe, options);
        
        vimPlayer.getVideoTitle().then(function(title) {
          videoData['title'] = title;
        });
        
        vimPlayer.getVideoId().then(function(id) {
          videoData['id'] = id;
        });
        
        vimPlayer.getDuration().then(function(duration) {
          videoData['duration'] = duration;
        });
        vimPlayer.on('play', function(data) {
          sendPlayerStateChange(2);
        });
        vimPlayer.on('pause', function(data) {
          sendPlayerStateChange(1);
        });
        vimPlayer.on('bufferstart', function() {
          window.flutter_inappwebview.callHandler('StateChange', -2);
        });
        vimPlayer.on('bufferend', function() {
          window.flutter_inappwebview.callHandler('StateChange', 0);
        });
        vimPlayer.on('fullscreenchange', function() {
          window.flutter_inappwebview.callHandler('StateChange', 3);
        });
        vimPlayer.on('loaded', function(id) {
          window.flutter_inappwebview.callHandler('Ready');
          Promise.all([vimPlayer.getVideoTitle(), vimPlayer.getDuration()]).then(function(values) {
            videoData['title'] = values[0];
            videoData['duration'] = values[1];
          });
          Promise.all([vimPlayer.getVideoWidth(), vimPlayer.getVideoHeight()]).then(function(values) {
            videoData['width'] = values[0];
            videoData['height'] = values[1];
            window.flutter_inappwebview.callHandler('VideoData', videoData);
            console.log('vidData: ' + JSON.stringify(videoData));
          });
        });
        vimPlayer.on('ended', function(data) {
          window.flutter_inappwebview.callHandler('StateChange', -1);
        });
        vimPlayer.on('timeupdate', function(seconds) {
          window.flutter_inappwebview.callHandler('VideoPosition', seconds['seconds']);
        });
        
        function sendPlayerStateChange(playerState) {
          window.flutter_inappwebview.callHandler('StateChange', playerState);
        }
        
        function sendVideoData(videoData) {
          window.flutter_inappwebview.callHandler('VideoData', videoData);
        }
        function play() {
          vimPlayer.play();
        }
        function pause() {
          vimPlayer.pause();
        }
        function seekTo(delta) {
          vimPlayer.getCurrentTime().then(function(seconds) {
            console.log('delta: ' + (delta));
            console.log('duration: ' + videoData['duration']);
            if (videoData['duration'] > delta) {
              vimPlayer.setCurrentTime(delta).then(function(t) {
                console.log('seekedto: ' + (t));
              });
            }
          });
        }
        function reset() {
          vimPlayer.unload().then(function(value) {
            vimPlayer.loadVideo(${controller.initialVideoId})
          });
        }
        </script>
      </body>
    </html>''';

    return _player;
  }

  String boolean({required bool value}) => value ? "'1'" : "'0'";

  String get userAgent =>
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36';
}
