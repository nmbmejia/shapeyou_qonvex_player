import 'package:flutter/cupertino.dart';
import 'package:qonvex_player/qonvex_player.dart';

class VimeoPlayerController extends ValueNotifier<VimeoPlayerValue> {
  final String initialVideoId;
  final VimeoPlayerFlags flags;
  final String securityId;
  final String appId;

  VimeoPlayerController({
    required this.initialVideoId,
    this.flags = const VimeoPlayerFlags(),
    required this.securityId,
    required this.appId,
  }) : super(VimeoPlayerValue(webViewController: null));

  factory VimeoPlayerController.of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedVimeoPlayer>()!
      .controller;

  void updateValue(VimeoPlayerValue newValue) => value = newValue;

  void toggleFullscreenMode() =>
      updateValue(value.copyWith(isFullscreen: true));

  void reload() => value.webViewController?.reload();

  void play() => _callMethod('play()');
  void pause() => _callMethod('pause()');
  void seekTo(double delta) => _callMethod('seekTo($delta)');
  void reset() => _callMethod('reset()');

  _callMethod(String methodString) {
    if (value.isReady) {
      value.webViewController?.evaluateJavascript(source: methodString);
    } else {
      print('The controller is not ready for method calls.');
    }
  }
}

class InheritedVimeoPlayer extends InheritedWidget {
  final VimeoPlayerController controller;
  const InheritedVimeoPlayer({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return oldWidget.hashCode != controller.hashCode;
  }
}
