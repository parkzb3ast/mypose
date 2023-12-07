import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimmerView extends StatefulWidget {
  final File file;

  TrimmerView(this.file);

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<void> _openSavedVideo(String outputPath) async {
    final directory = Directory(outputPath);
    if (await directory.exists()) {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        final filePath = '$result/${directory.uri.pathSegments.last}';
        if (await canLaunch(filePath)) {
          await launch(filePath);
          return;
        }
      }
    }

    // Handle the case where the file cannot be opened.
    final snackBar = SnackBar(content: Text('Cannot open the saved video'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<String?> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });


    final appDocDir = await getApplicationDocumentsDirectory();
    final outputPath = '${appDocDir.path}/trimmed_videos';

    final outputDir = Directory(outputPath);
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    final videoFilePath = '$outputPath/$uniqueFileName.mp4';
    print(videoFilePath);

    await _trimmer.
    saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (String? value) {
        setState(() {
          _progressVisibility = false;
          if (value != null) {
            // Pass the edited video file path back to the previous screen
            Navigator.of(context).pop(value);
          }
        });
      },
    );

  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  @override
  void initState() {
    super.initState();

    _loadVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Trimmer"),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                ElevatedButton(
                  onPressed: _progressVisibility
                      ? null
                      : () async {
                          _saveVideo().then((outputPath) {
                            print('OUTPUT PATH: $outputPath');
                            final snackBar = SnackBar(
                                content: Text('Video Saved successfully'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              snackBar,
                            );
                          });
                        },
                  child: ElevatedButton(
                    onPressed: _progressVisibility
                        ? null
                        : () async {
                            final outputPath = await _saveVideo();
                            if (outputPath != null) {
                              print('OUTPUT PATH: $outputPath');
                              final snackBar = SnackBar(
                                  content: Text('Video Saved successfully'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);

                              // Open the saved video
                              _openSavedVideo(outputPath);
                            }
                          },
                    child: Text("SAVE"),
                  ),
                ),
                Expanded(
                  child: VideoViewer(trimmer: _trimmer),
                ),
                Center(
                  child: TrimViewer(
                    trimmer: _trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: const Duration(seconds: 40),
                    onChangeStart: (value) => _startValue = value,
                    onChangeEnd: (value) => _endValue = value,
                    onChangePlaybackState: (value) =>
                        setState(() => _isPlaying = value),
                  ),
                ),
                TextButton(
                  child: _isPlaying
                      ? Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    bool playbackState = await _trimmer.videoPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}