import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ZVimeoPlayer extends StatefulWidget {
  const ZVimeoPlayer({
    super.key,
    required this.onComplete,
    required this.baseUrl,
    required this.isFullscreenCallback,
    required this.mute,
    required this.playedTimeCallback,
    required this.securityId,
    required this.videoId,
    this.autoPlay = true,
    this.playerReady,
  });
  final ValueChanged<bool> isFullscreenCallback;
  final ValueChanged<double>? playedTimeCallback; // in seconds
  final VoidCallback? playerReady;
  final String baseUrl;
  final String securityId;
  final String videoId;
  final ValueChanged<Map<String, dynamic>> onComplete;
  final bool mute;
  final bool autoPlay;

  @override
  State<ZVimeoPlayer> createState() => _ZVimeoPlayerState();
}

class _ZVimeoPlayerState extends State<ZVimeoPlayer> {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
          ios: IOSInAppWebViewOptions(
            allowsInlineMediaPlayback: true,
            disallowOverScroll: true,
            // allowingReadAccessTo: Uri.parse(widget.baseUrl),
          ),
          android: AndroidInAppWebViewOptions(),
          crossPlatform: InAppWebViewOptions(
            userAgent: userAgent,
            mediaPlaybackRequiresUserGesture: false,
            transparentBackground: true,
            clearCache: true,
          ),
        ),
        onCloseWindow: (InAppWebViewController controller) {},
        onEnterFullscreen: (InAppWebViewController controller) {
          widget.isFullscreenCallback(false);
        },
        onExitFullscreen: (InAppWebViewController controller) {
          widget.isFullscreenCallback(false);
        },
        onLoadStop: (controller, url) {
          String _js = '''
            if (!window.flutter_inappwebview.callHandler) {
                window.flutter_inappwebview.callHandler = function () {
                    var _callHandlerID = setTimeout(function () { });
                    window.flutter_inappwebview._callHandler(arguments[0], _callHandlerID, JSON.stringify(Array.prototype.slice.call(arguments, 1)));
                    return new Promise(function (resolve, reject) {
                        window.flutter_inappwebview[_callHandlerID] = resolve;
                    });
                };
            }
          ''';
          controller.evaluateJavascript(source: _js);
        },
        onWebViewCreated: (InAppWebViewController controller) async {
          _setupJSChannel(controller);
        },
        initialData: InAppWebViewInitialData(
          data: player,
          baseUrl: Uri.parse(widget.baseUrl),
          encoding: 'utf-8',
          mimeType: 'text/html',
        ),
      ),
    );
  }

  void _setupJSChannel(InAppWebViewController controller) {
    try {
      // controller.addJavaScriptHandler(
      //   handlerName: 'StateChange',
      //   callback: (args) {
      //     // Handle 'StateChange' message from JavaScript
      //     final int state = int.parse(args.first);
      //     if (state == 1) {
      //       // Player starts
      //       // Perform desired action
      //     }
      //   },
      // );
      controller.addJavaScriptHandler(
        handlerName: "EndState",
        callback: (args) {
          final Map<String, dynamic> data = args.first as Map<String, dynamic>;
          print("ENDING STATE : $data");
          widget.onComplete(data);
        },
      );
      controller.addJavaScriptHandler(
        handlerName: 'Ready',
        callback: (_) {
          if (widget.playerReady != null) {
            widget.playerReady!();
          }
          // Handle 'Ready' message from JavaScript
          // Player is ready
          // Perform desired action
        },
      );

      controller.addJavaScriptHandler(
        handlerName: 'TimeUpdate',
        callback: (args) {
          // Handle 'TimeUpdate' message from JavaScript
          final Map<String, dynamic> data = args.first as Map<String, dynamic>;
          if (widget.playedTimeCallback != null) {
            print("SECONDS PLAYED");
            widget.playedTimeCallback!(data['seconds']);
          }
          // Perform desired action with the time update
        },
      );

      print("LISTENER SETUP: DONE!");
    } catch (e) {
      print("LISTENER SETUP: FAILED!");
    }
  }

  String get player => """
  <html>
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
      <iframe src="https://player.vimeo.com/video/${widget.videoId}?h=${widget.securityId}"  width="100%" height="100%" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
      <script src="https://player.vimeo.com/api/player.js"></script>
    <script>
      let iframe = document.querySelector('iframe');
      var options = {
        id: ${widget.videoId},
        responsive: true,
        speed: true,
        title: false,
        transparent: true,
        autoplay: ${widget.autoPlay},
        controls: true,
        width: "100%",
        quality: auto,
        pip: true
      };

      var videoPlayer = new Vimeo.Player(iframe, options);
      window.addEventListener("flutterInAppWebViewPlatformReady", function(data){
        videoPlayer.on('ended', function(data) {
          window.flutter_inappwebview.callHandler('EndState', data);
        });

        videoPlayer.on('loaded', function(id) {
          self.location.reload();
          window.flutter_inappwebview.callHandler('Ready');
        });
        videoPlayer.on('timeupdate', function(data) {
          window.flutter_inappwebview.callHandler('TimeUpdate', data);
        });
      });
      if(!window.flutter_inappwebview.callHandler){
        window.flutter_inappwebview.callHandler = function() {
          var _callHandlerID = setTimeout(function (){});

        }
      }
    </script>
      </body>
  """;

  String get userAgent {
    if (Platform.isIOS) {
      // final bool isPhone = controller.type == PlayerDeviceType.IPHONE;
      // final bool isPhone = SizerUtil.deviceType == DeviceType.mobile;
      return "Mozilla/5.0 (iPhone; CPU iPhone OS 16_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/107.0.5304.66 Mobile/15E148 Safari/604.1";
      // if (!isPhone) {
      //   return "Mozilla/5.0 (iPad; CPU OS 16_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/107.0.5304.66 Mobile/15E148 Safari/604.1";
      // }
    } else {
      return "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36";
    }
  }
}
