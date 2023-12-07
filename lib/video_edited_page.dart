import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:dio/dio.dart';

class VideoEditedPage extends StatefulWidget {
  final String videoPath;

  VideoEditedPage(this.videoPath);

  @override
  _VideoEditedPageState createState() => _VideoEditedPageState();
}

class _VideoEditedPageState extends State<VideoEditedPage> {
  late VideoPlayerController _controller;
final TextEditingController _textcontroller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        // Ensure the first frame is shown
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              var file = widget.videoPath;
                                                GallerySaver.saveVideo(file);

              String code= _textcontroller.text;

              String fileName = widget.videoPath.split('/').last;
                                                FormData formData = FormData.fromMap({
                                                  "file": await MultipartFile.fromFile(widget.videoPath, filename:fileName),
                                                  "code": code,});
                                                Response response = await Dio().post("http://52.28.151.44:5000/upload", data: formData);
                                                return response.data['id'];},
          ),
        ],
      ),

      bottomNavigationBar: TextField(
        controller: _textcontroller,
        decoration:
        const InputDecoration(hintText: 'Enter Code'),
        ),

      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(), // Show a loading indicator until video is initialized
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
          GallerySaver.saveVideo(widget.videoPath);
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}