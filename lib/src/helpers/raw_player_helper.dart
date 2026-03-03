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
          bool isPortrait = false,
          bool showMuteButton = false}) =>
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

        .mute-button {
            position: absolute;
            bottom: 16px;
            right: 16px;
            width: 40px;
            height: 40px;
            background: rgba(0, 0, 0, 0.6);
            border-radius: 50%;
            border: none;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            transition: background 0.3s ease;
        }

        .mute-button:hover {
            background: rgba(0, 0, 0, 0.8);
        }

        .mute-button svg {
            width: 20px;
            height: 20px;
            fill: white;
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
            <!-- Mute button -->
            ${showMuteButton ? '''
            <button class="mute-button" id="muteButton" onclick="toggleMute()">
              <svg id="volumeIcon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                <path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77z"/>
              </svg>
            </button>
            ''' : ''}
          </div>
      <script src="https://player.vimeo.com/api/player.js"></script>
      <script>
        var player = new Vimeo.Player(document.querySelector('iframe'));
        var isMuted = ${isMuted ? 'true' : 'false'};
        
        function togglePlayPause() {
            player.getPaused().then(function(paused) {
                if (paused) {
                    player.play();
                } else {
                    player.pause();
                }
            });
        }

        function toggleMute() {
            if (isMuted) {
                player.setVolume(1);
                isMuted = false;
                updateMuteIcon(false);
            } else {
                player.setVolume(0);
                isMuted = true;
                updateMuteIcon(true);
            }
        }

        function updateMuteIcon(muted) {
            var volumeIcon = document.getElementById('volumeIcon');
            if (volumeIcon) {
                if (muted) {
                    volumeIcon.innerHTML = '<path d="M16.5 12c0-1.77-1.02-3.29-2.5-4.03v2.21l2.45 2.45c.03-.2.05-.41.05-.63zm2.5 0c0 .94-.2 1.82-.54 2.64l1.51 1.51C20.63 14.91 21 13.5 21 12c0-4.28-2.99-7.86-7-8.77v2.06c2.89.86 5 3.54 5 6.71zM4.27 3L3 4.27 7.73 9H3v6h4l5 5v-6.73l4.25 4.25c-.67.52-1.42.93-2.25 1.18v2.06c1.38-.31 2.63-.95 3.69-1.81L19.73 21 21 19.73l-9-9L4.27 3zM12 4L9.91 6.09 12 8.18V4z"/>';
                } else {
                    volumeIcon.innerHTML = '<path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77z"/>';
                }
            }
        }

        // Initialize mute icon on load
        if (${showMuteButton ? 'true' : 'false'}) {
            player.ready().then(function() {
                updateMuteIcon(isMuted);
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
        player.on('play', function(){
          window.flutter_inappwebview.callHandler('onPlay', []);
        });
        function mute(){
          player.setVolume(0);
        }
        function unmute(){
          player.setVolume(1);
        }
        player.ready().then(function() {
          window.flutter_inappwebview.callHandler('onReady', []);
        });

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
