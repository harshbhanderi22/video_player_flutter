import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final File videoFile;

  VideoPlayerWidget(this.videoFile);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.videoFile.path.split('/').last),
        ),
        body: AspectRatio(
          aspectRatio: 1/1,
          child: VideoPlayer(_controller),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
          child: Icon(
            _controller.value.position!=_controller.value.duration ? (_controller.value.isPlaying ? Icons.pause : Icons.play_arrow) : Icons.play_arrow,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
