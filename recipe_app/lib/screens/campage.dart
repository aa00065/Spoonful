import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';

class Cameradetector extends StatefulWidget {
  final CameraDescription camera;
  final Function(List<String>) onIngredientsDetected;

  Cameradetector(
      {Key? key, required this.camera, required this.onIngredientsDetected})
      : super(key: key);

  @override
  _CameradetectorState createState() => _CameradetectorState();
}

class _CameradetectorState extends State<Cameradetector> {
  late CameraController _controller;
  List<String> ingredients = [];
  bool showResult = false; // Track if result should be shown

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max, // Use high resolution
      enableAudio: false, // Disable audio to prevent conflicts
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _controller.initialize();
    // Enable autofocus
    _controller.setFlashMode(
        FlashMode.off); // Set flash mode to auto for better focusing
    _controller.setFocusMode(FocusMode.locked); // Set focus mode to auto
    if (mounted) {
      setState(() {});
    }
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
      File imageFile = File(file.path); // Retrieve the captured image file

      String apiUrl =
          'https://api.clarifai.com/v2/users/clarifai/apps/main/models/food-item-recognition/versions/1d5fd481e0cf4826aa72ec3ff049e044/outputs';

      String apiKey =
          '4a0e1c222bb1498bbc7b230038d90148'; // Replace with your Clarifai API key

      Map<String, String> headers = {
        'Authorization': 'Key $apiKey',
        'Content-Type': 'application/json',
      };

      List<int> imageBytes = await imageFile.readAsBytes();
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
        if (concepts.isNotEmpty) {
          String firstConceptName = concepts[0]['name'];
          double firstConceptValue = concepts[0]['value'];
          String firstConceptString =
              "$firstConceptName ${firstConceptValue.toStringAsFixed(2)}\n";

          setState(() {
            ingredients.add(firstConceptName);
            showResult = true; // Show the result
          });

          // Set timer to hide the result after 3 seconds
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              showResult = false;
            });
          });

          print(
              "First Detected Ingredient: $firstConceptString"); // Print results in terminal
          print(ingredients);

          // Call the callback function with the detected ingredients
          widget.onIngredientsDetected(ingredients);
        } else {
          setState(() {
            ingredients.add('No ingredients detected');
          });
          print("No ingredients detected");
        }
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
        body: Stack(
          children: [
            Positioned.fill(
              child: CameraPreview(_controller),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    fetchData();
                  },
                  child: Icon(Icons.camera_alt),
                ),
              ),
            ),
            Positioned(
              bottom: 20, // Adjust the bottom margin as needed
              right: 20, // Adjust the right margin as needed
              child: FloatingActionButton(
                onPressed: () {},
                child: Icon(Icons.find_in_page),
                backgroundColor: Colors.white, // Use white color for button
                elevation: 4, // Add elevation for shadow effect
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                title: Text(
                  'Spoonful Cam',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),
            ),
            if (showResult)
              AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: showResult ? 1.0 : 0.0,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: Colors.black54,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: ingredients
                            .map((ingredient) => Text(
                                  ingredient.trimRight(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
