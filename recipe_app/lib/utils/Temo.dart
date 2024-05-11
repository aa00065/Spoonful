import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';

class detect extends StatefulWidget {
  final CameraDescription camera;

  detect({Key? key, required this.camera}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<detect> {
  late CameraController _controller;
  String result = '';

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    if (!_controller.value.isInitialized) {
      return;
    }

    try {
      XFile file = await _controller.takePicture();
      List<int> imageBytes = await file.readAsBytes();

      String apiUrl =
          'https://api.clarifai.com/v2/users/clarifai/apps/main/models/food-item-recognition/versions/1d5fd481e0cf4826aa72ec3ff049e044/outputs';

      String apiKey =
          '4a0e1c222bb1498bbc7b230038d90148'; // Replace with your Clarifai API key

      Map<String, String> headers = {
        'Authorization': 'Key $apiKey',
        'Content-Type': 'application/json',
      };

      String base64Image = base64Encode(imageBytes);

      Map<String, dynamic> requestBody = {
        "inputs": [
          {
            "data": {
              "image": {"base64": base64Image}
            }
          }
        ]
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> concepts = data['outputs'][0]['data']['concepts'];
        String conceptsString = '';
        concepts.forEach((concept) {
          conceptsString +=
              "${concept['name']} ${concept['value'].toStringAsFixed(2)}\n";
        });

        setState(() {
          result = conceptsString;
        });
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Camera & Clarifai API Demo'),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: CameraPreview(_controller),
            ),
            Positioned(
              bottom: 16,
              left: MediaQuery.of(context).size.width / 2 - 24,
              child: IconButton(
                icon: Icon(Icons.camera_alt),
                color: Colors.white.withOpacity(0.8), // Adjust opacity here
                onPressed: () {
                  fetchData();
                },
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                title: Text('Camera Viewfinder'),
                backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                elevation: 0,
                centerTitle: true,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 50,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  result,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
