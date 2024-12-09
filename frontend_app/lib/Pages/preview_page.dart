import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nutrify/Pages/processing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  void _confirmAndNavigateToProcessing(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Proceed to Processing'),
        content: Text('Do you want to proceed to the processing page?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Proceed'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProcessingPage(picture: picture), // Ensure ProcessingPage accepts picture
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Page'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _confirmAndNavigateToProcessing(context); // Show confirmation dialog
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(picture.path), fit: BoxFit.cover, width: 250),
            const SizedBox(height: 24),
            Text(picture.name),
          ],
        ),
      ),
    );
  }
}
