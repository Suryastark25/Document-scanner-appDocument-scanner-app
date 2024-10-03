import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img; // Import the image package

void main() {
  runApp(DocumentScannerApp());
}

class DocumentScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Scanner',
      home: DocumentScanner(),
    );
  }
}

class DocumentScanner extends StatefulWidget {
  @override
  _DocumentScannerState createState() => _DocumentScannerState();
}

class _DocumentScannerState extends State<DocumentScanner> {
  String? _imagePath;

  Future<void> _takePicture() async {
    // Simulate image upload for web
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*'; // Accept all image formats
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      final files = uploadInput.files!;
      if (files.isEmpty) return;

      final reader = html.FileReader();
      reader.readAsDataUrl(files[0]); // Read the file as Data URL (Base64)
      reader.onLoadEnd.listen((e) async {
        final base64Image = reader.result as String;
        // Store the original image path
        setState(() {
          _imagePath = base64Image;
        });
      });
    });
  }

  // Apply a simple grayscale filter
  String _applyFilter(String base64Image) {
    // Decode the base64 image
    final bytes = base64Decode(base64Image.split(',')[1]);
    final image = img.decodeImage(Uint8List.fromList(bytes))!;

    // Convert to grayscale
    final grayscaleImage = img.grayscale(image);
    
    // Encode the image back to PNG
    final pngBytes = img.encodePng(grayscaleImage);
    return 'data:image/png;base64,' + base64Encode(pngBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document Scanner'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              _imagePath == null
                  ? Text('No image captured.')
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          child: Image.memory(
                            base64Decode(_imagePath!.split(',')[1]),
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text('Stored Image Path: $_imagePath'),
                      ],
                    ),
              Positioned(
                right: 16,
                top: MediaQuery.of(context).size.height * 0.35, // Adjust this for vertical position
                child: FloatingActionButton(
                  onPressed: () {
                    if (_imagePath != null) {
                      setState(() {
                        _imagePath = _applyFilter(_imagePath!); // Apply the filter
                      });
                    }
                  },
                  child: Icon(Icons.filter_alt),
                  tooltip: 'Apply Filter',
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: Icon(Icons.camera_alt),
        tooltip: 'Upload Image',
        backgroundColor: Colors.blue,
      ),
    );
  }
}
