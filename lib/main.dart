import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_screen1.dart';
import 'blepage.dart';
List<CameraDescription> cameras = [];

Future<void> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }
  //runApp(MyApp());
  runApp(MaterialApp(home: MyApp()));
}

/*void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: MyApp()));
}*/
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(//SafeArea(
        child: Container(
          padding: EdgeInsets.all(8.0),
          height: 100,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  child: ElevatedButton(
                    onPressed: () {Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraScreen()),
            );},
                    child: Text("Camera"),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 8.0),
                  height: 100,
                  child: ElevatedButton(
                    onPressed: () {Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage(title: 'BLE')),
            );},
                    child: Text("Bluetooth"),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}