import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qonvex_player/qonvex_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  VimeoPlayerController? _controller;
  @override
  void initState() {
    _controller = VimeoPlayerController(
      initialVideoId: "871762134",
      appId: "122963",
      securityId: "871762134",
      flags: const VimeoPlayerFlags(
        autoPlay: true,
        autoInitialize: true,
        loop: true,
        controls: false,
      ),
      type: Platform.isAndroid
          ? PlayerDeviceType.OTHERS
          : PlayerDeviceType.IPHONE,
    );
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: Center(
          child: _controller == null
              ? const CircularProgressIndicator.adaptive()
              : SizedBox(
                  height: size.height,
                  width: size.width,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const PageScrollPhysics(),
                      child: Column(
                        children: List.generate(
                          20,
                          (index) => SizedBox(
                            height: size.height,
                            width: size.width,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: QonvexVimeoPlayer(
                                height: size.height,
                                width: size.width,
                                showDebugLogging: false,
                                isFullscreenCallback: (b) {},
                                allowFullscreen: true,
                                currentSecCallback: (double s) {},
                                controller: _controller!,
                                url: 'https://back.shapeyou.fr',
                                isCompleted: (b) async {},
                                onReady: () {},
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
    );
  }
}
