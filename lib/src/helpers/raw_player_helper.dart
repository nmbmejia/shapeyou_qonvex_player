import 'dart:io';

mixin class RawPlayerHelper {
  String userAgent(bool isIphone) {
    if (Platform.isIOS) {
      // final bool isPhone = controller.type == PlayerDeviceType.IPHONE;
      // final bool isPhone = SizerUtil.deviceType == DeviceType.mobile;
      if (!isIphone) {
        return "Mozilla/5.0 (iPad; CPU OS 16_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/107.0.5304.66 Mobile/15E148 Safari/604.1";
      }
      return "Mozilla/5.0 (iPhone; CPU iPhone OS 16_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/107.0.5304.66 Mobile/15E148 Safari/604.1";
    } else {
      return "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36";
    }
  }

  String player(
          {required bool loop,
          required bool showControl,
          required bool autoPlay,
          required String vimeoId,
          required String hash,
          required bool isMuted,
          bool isBackground = false,
          bool autopause = true,
          bool isPortrait = false}) =>
      """
 <html>
<style>
    html,
    body {
        margin: 0;
        overflow:hidden;
    }

    .video-container {
            position: relative;
            width: 100%;
            height: 100%;
        }

        .video-container iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
        }

        .play-pause-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: transparent;
        }
</style>
<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'>
</head>

<body style="margin:0;">
          <div class ="video-container">
            <iframe src="https://player.vimeo.com/video/$vimeoId?h=$hash&responsive=1&muted=${isMuted ? 1 : 0}&autoplay=${autoPlay ? 1 : 0}&controls=${showControl ? 1 : 0}&loop=${loop ? 1 : 0}&speed=1&autopause=${autopause ? 1 : 0}&background=${isBackground ? 1 : 0}" 
                width="100%" 
                height="100%" 
                frameborder="0"
                webkitallowfullscreen mozallowfullscreen allowfullscreen allow=autoplay;fullscreen>
            </iframe>
            <!-- Play/pause overlay -->
            ${showControl ? "" : '<div class="play-pause-overlay" onclick="togglePlayPause()"></div>'}
          </div>
      <script src="https://player.vimeo.com/api/player.js"></script>
      <script>
        var player = new Vimeo.Player(document.querySelector('iframe'));
        function togglePlayPause() {
            player.getPaused().then(function(paused) {
                if (paused) {
                    player.play();
                } else {
                    player.pause();
                }
            });
        }
        player.on('ended', function(data) {
              // Handle video end event here
              window.flutter_inappwebview.callHandler('onVideoEnd', data);
            });
        player.on('loaded', function(id) {
          window.flutter_inappwebview.callHandler('onLoad', '');
        });
        player.on('timeupdate', function(data) {
          window.flutter_inappwebview.callHandler('videoPosition', data);
        });
        function mute(){
          player.setVolume(0);
        }
        function unmute(){
          player.setVolume(1);
        }

        function play() {
          player.play();
           player.setVolume(1);
        }
        function initialize(){
          //JUST TO INITIALIZE THE [_callMethod] function
          player.getVideoId();
        }
        function pause() {
          player.pause();
        }
      </script>
</body>
</html>
""";
}
