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
            bottom: 45px;
            right: 10px;
            width: 50px;
            height: 50px;
            background: rgba(0, 0, 0, 0.1);
            border-radius: 50%;
            border: none;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            transition: background 0.2s ease;
            padding: 10px;
        }

        .mute-button:active {
            background: rgba(0, 0, 0, 0.2);
        }

        .mute-button svg {
            width: 25px;
            height: 25px;
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
                <path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77z" fill="none" stroke="currentColor" stroke-width="0"/>
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
                    volumeIcon.innerHTML = '<path d="M3.63 3.63c-.39.39-.39 1.02 0 1.41L7.29 8.7 7 9H4c-.55 0-1 .45-1 1v4c0 .55.45 1 1 1h3l3.29 3.29c.63.63 1.71.18 1.71-.71v-4.17l4.18 4.18c-.49.37-1.02.68-1.6.91-.36.15-.58.53-.58.92 0 .72.73 1.18 1.39.91.8-.33 1.55-.77 2.22-1.31l1.34 1.34c.39.39 1.02.39 1.41 0 .39-.39.39-1.02 0-1.41L5.05 3.63c-.39-.39-1.02-.39-1.42 0zM19 12c0 .82-.15 1.61-.41 2.34l1.53 1.53c.56-1.17.88-2.48.88-3.87 0-3.83-2.4-7.11-5.78-8.4-.59-.23-1.22.23-1.22.86v.19c0 .38.25.71.61.85C17.18 6.54 19 9.06 19 12zm-8.71-6.29l-.17.17L12 7.76V6.41c0-.89-1.08-1.33-1.71-.7zM16.5 12c0-1.77-1.02-3.29-2.5-4.03v1.79l2.48 2.48c.01-.08.02-.16.02-.24z"/>';
                } else {
                    volumeIcon.innerHTML = '<path d="M3 10v4c0 .55.45 1 1 1h3l3.29 3.29c.63.63 1.71.18 1.71-.71V6.41c0-.89-1.08-1.34-1.71-.71L7 9H4c-.55 0-1 .45-1 1zm13.5 2c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 4.45v.2c0 .38.25.71.6.85C17.18 6.53 19 9.06 19 12s-1.82 5.47-4.4 6.5c-.36.14-.6.47-.6.85v.2c0 .63.63 1.07 1.21.85C18.6 19.11 21 15.84 21 12s-2.4-7.11-5.79-8.4c-.58-.23-1.21.22-1.21.85z"/>';
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
