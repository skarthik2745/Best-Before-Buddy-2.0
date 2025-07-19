import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class CameraScannerScreen extends StatefulWidget {
  final CameraDescription camera;
  final Function(String, Uint8List) onFoodDetected;

  const CameraScannerScreen({
    Key? key,
    required this.camera,
    required this.onFoodDetected,
  }) : super(key: key);

  @override
  State<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String _detectedFood = '';
  bool _isProcessing = false;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _detectFoodFromImage() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final image = await _controller.takePicture();
      final imageBytes = await image.readAsBytes();

      // Use Gemini API to detect food
      final foodName = await _callGeminiAPI(imageBytes);

      if (foodName != null && foodName.isNotEmpty) {
        setState(() {
          _detectedFood = foodName;
          _isDetecting = true;
        });

        // Call the callback with detected food and image
        widget.onFoodDetected(foodName, imageBytes);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not detect food. Please try again.')),
        );
      }
    } catch (e) {
      print('Error detecting food: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error detecting food: $e')));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<String?> _callGeminiAPI(Uint8List imageBytes) async {
    final apiKey = "AIzaSyDa4RWPw66dkX3sXqpQdFoIrGLWx825X9U";
    final model = "gemini-2.5-flash";
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey",
    );

    final prompt = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  "What food item is shown in this image? Respond with only the food name, nothing else. If you cannot identify a food item, respond with 'Unknown'.",
            },
            {
              "inlineData": {
                "mimeType": "image/jpeg",
                "data": base64Encode(imageBytes),
              },
            },
          ],
        },
      ],
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(prompt),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final text =
            decoded['candidates'][0]['content']['parts'][0]['text'] as String;
        return text.trim();
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Food Scanner'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // Camera preview
                CameraPreview(_controller),
                // Mask overlay with clear center
                Positioned.fill(
                  child: CustomPaint(painter: _ScannerOverlayPainter()),
                ),
                // Overlay UI
                Positioned.fill(
                  child: Column(
                    children: [
                      SizedBox(height: 40),
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'Align food item in the box',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      if (_isProcessing)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Processing...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close),
                            label: Text('Cancel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : _detectFoodFromImage,
                            icon: Icon(Icons.camera_alt),
                            label: Text('Scan Food'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final clearRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.height * 0.35,
    );
    // Draw the dark overlay
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    // Clear the center rectangle
    paint.blendMode = BlendMode.clear;
    canvas.drawRRect(
      RRect.fromRectAndRadius(clearRect, Radius.circular(24)),
      paint,
    );
    // Draw border
    paint.blendMode = BlendMode.srcOver;
    paint.color = Colors.green;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(clearRect, Radius.circular(24)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
