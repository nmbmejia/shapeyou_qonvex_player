// String player(double width) {
  // var _player = '''<html>
  //     <head>
  //     <style>
  //       html,
  //       body {
  //           margin: 0;
  //       }
        
  //     </style>
  //     <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'>
  //     </head>
//       <body>
//         <div id="player"></div>
      
//         <iframe src="https://player.vimeo.com/video/${controller.initialVideoId}?h=${controller.securityId}&app_id=${controller.appId}&muted=${widget.mute ? 1 : 0}&dnt=0&speed=${widget.showControls}&playsinline=1&loop=${widget.loop}&autoplay=${controller.flags.autoPlay}&quality=auto" width="100%" height="100%"frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen allow=autoplay;fullscreen;picture-in-picture; controls="${widget.showControls ? 1 : 0}"></iframe>
//         <script src="https://player.vimeo.com/api/player.js"></script>
//         <script>
        
        // let iframe = document.querySelector('iframe');
        
        // var options = {
        //   id: ${controller.initialVideoId},
        //   title: false,
        //   transparent: true,
        //   autoplay: ${controller.flags.autoPlay},
        //   speed: ${widget.showControls},
        //   controls: ${widget.showControls},
        //   dnt: false,
        //   debug: ${widget.showDebugLogging},
        //   loop: ${widget.loop}
        // };
        
        // var videoData = {};
        // var vimPlayer = new Vimeo.Player(iframe, options);
//         vimPlayer.ready().catch((e){
//           self.location.reload();
//           console.log('VIDEO ERROR ');
//         });
//         vimPlayer.getVideoTitle().then(function(title) {
//           videoData['title'] = title;
//         });
        
//         vimPlayer.getVideoId().then(function(id) {
//           videoData['id'] = id;
//         });
        
//         vimPlayer.getDuration().then(function(duration) {
//           videoData['duration'] = duration;
//         });
//         vimPlayer.on('play', function(data) {
//           sendPlayerStateChange(2);
//         });
//         vimPlayer.on('pause', function(data) {
//           sendPlayerStateChange(1);
//         });
//         vimPlayer.on('bufferstart', function() {
//           window.flutter_inappwebview.callHandler('StateChange', -2);
//         });
//         vimPlayer.on('bufferend', function() {
//           window.flutter_inappwebview.callHandler('StateChange', 0);
//         });
//         vimPlayer.on('fullscreenchange', function() {
//           window.flutter_inappwebview.callHandler('StateChange', 3);
//         });
//         vimPlayer.on('loaded', function(id) {
//           self.location.reload();
//           window.flutter_inappwebview.callHandler('Ready');
//           // Promise.all([vimPlayer.getVideoTitle(), vimPlayer.getDuration()]).then(function(values) {
//           //   videoData['title'] = values[0];
//           //   videoData['duration'] = values[1];
//           // });
//           // Promise.all([vimPlayer.getVideoWidth(), vimPlayer.getVideoHeight()]).then(function(values) {
//           //   videoData['width'] = values[0];
//           //   videoData['height'] = values[1];
//           //   window.flutter_inappwebview.callHandler('VideoData', videoData);
//           //   console.log('vidData: ' + JSON.stringify(videoData));
//           // });
//         });
//         vimPlayer.on('ended', function(data) {
//           window.flutter_inappwebview.callHandler('StateChange', -1);
//         });
        // vimPlayer.on('timeupdate', function(seconds) {
        //   window.flutter_inappwebview.callHandler('VideoPosition', seconds['seconds']);
        // });
        
//         function sendPlayerStateChange(playerState) {
//           window.flutter_inappwebview.callHandler('StateChange', playerState);
//         }
        
//         function sendVideoData(videoData) {
//           window.flutter_inappwebview.callHandler('VideoData', videoData);
//         }
//         function play() {
//           vimPlayer.play();
//         }
//         function pause() {
//           vimPlayer.pause();
//         }
//         function seekTo(delta) {
//           vimPlayer.getCurrentTime().then(function(seconds) {
//             console.log('delta: ' + (delta));
//             console.log('duration: ' + videoData['duration']);
//             if (videoData['duration'] > delta) {
//               vimPlayer.setCurrentTime(delta).then(function(t) {
//                 console.log('seekedto: ' + (t));
//               });
//             }
//           });
//         }
//         function reset() {
//           vimPlayer.unload().then(function(value) {
//             vimPlayer.loadVideo(${controller.initialVideoId})
//           });
//         }
//         </script>
//       </body>
//     </html>''';

//   return _player;
// }
