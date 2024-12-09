import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

String prompt1 = """What is the name of the recipe? Respond only with one of the following labels: 
    ['macarons', 'french_toast', 'lobster_bisque', 'prime_rib', 'pork_chop', 'guacamole', 
    'baby_back_ribs', 'mussels', 'beef_carpaccio', 'poutine', 'hot_and_sour_soup', 
    'seaweed_salad', 'foie_gras', 'dumplings', 'peking_duck', 'takoyaki', 'bibimbap', 
    'falafel', 'pulled_pork_sandwich', 'lobster_roll_sandwich', 'carrot_cake', 'beet_salad', 
    'panna_cotta', 'donuts', 'red_velvet_cake', 'grilled_cheese_sandwich', 'cannoli', 
    'spring_rolls', 'shrimp_and_grits', 'clam_chowder', 'omelette', 'fried_calamari', 
    'caprese_salad', 'oysters', 'scallops', 'ramen', 'grilled_salmon', 'croque_madame', 
    'filet_mignon', 'hamburger', 'spaghetti_carbonara', 'miso_soup', 'bread_pudding', 
    'lasagna', 'crab_cakes', 'cheesecake', 'spaghetti_bolognese', 'cup_cakes', 'creme_brulee', 
    'waffles', 'fish_and_chips', 'paella', 'macaroni_and_cheese', 'chocolate_mousse', 
    'ravioli', 'chicken_curry', 'caesar_salad', 'nachos', 'tiramisu', 'frozen_yogurt', 
    'ice_cream', 'risotto', 'club_sandwich', 'strawberry_shortcake', 'steak', 'churros', 
    'garlic_bread', 'baklava', 'bruschetta', 'hummus', 'chicken_wings', 'greek_salad', 
    'tuna_tartare', 'chocolate_cake', 'gyoza', 'eggs_benedict', 'deviled_eggs', 'samosa', 
    'sushi', 'breakfast_burrito', 'ceviche', 'beef_tartare', 'apple_pie', 'huevos_rancheros', 
    'beignets', 'pizza', 'edamame', 'french_onion_soup', 'hot_dog', 'tacos', 
    'chicken_quesadilla', 'pho', 'gnocchi', 'pancakes', 'fried_rice', 'cheese_plate', 
    'onion_rings', 'escargots', 'sashimi', 'pad_thai', 'french_fries']""";

// Replace this with your Flask server's IP address or hostname
const String flaskServerUrl = 'http://192.168.1.37:5000/predict-image'; // Use your local network IP address

class ProcessingPage extends StatefulWidget {
  const ProcessingPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  _ProcessingPageState createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  String? _responseMessage;
  bool _loading = false;
  String _selectedModel = 'SwinTiny (Accuracy: 85.91)'; // Default model selection

  // List of models to choose from, including the new model
  final List<String> _models = ['SwinTiny (Accuracy: 85.91)', 'Resnet (Accuracy: 76.45)', 'MobileNet v2 (Accuracy: 73.03)', 'EfficientNet b3 (Accuracy: 81.25)', 'Gemini 1.5 Flash'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(widget.picture.path), fit: BoxFit.cover, width: 250),
            const SizedBox(height: 24),
            Text('Selected image: ${widget.picture.name}'),
            const SizedBox(height: 24),
            // Dropdown for selecting the model
            DropdownButton<String>(
              value: _selectedModel,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedModel = newValue!;
                });
              },
              items: _models.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _processAndSendToModel,
                child: const Text('Process Image'),
              ),
            const SizedBox(height: 24),
            if (_responseMessage != null)
              Text(
                _responseMessage!,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _processAndSendToModel() async {
    setState(() {
      _loading = true;
      _responseMessage = null;
    });

    try {
      if (_selectedModel == 'Gemini 1.5 Flash') {
        // Use Gemini model
        const apiKey = 'AIzaSyAxqba8vgvihZsqxTyYSpbRb926fm_qguI'; // Replace with your actual API key
        final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

        // Read the image file
        final imageBytes = await File(widget.picture.path).readAsBytes();

        // Create the prompt and image parts
        final prompt = TextPart(prompt1);
        final imagePart = DataPart('image/jpeg', imageBytes);

        // Generate the response
        final response = await model.generateContent([Content.multi([prompt, imagePart])]);
        setState(() {
          _responseMessage = 'Model: $_selectedModel\nPrediction: ${response.text ?? 'No response from Gemini'}';
          _loading = false;
        });
      }
      if(_selectedModel == 'SwinTiny (Accuracy: 85.91)') {
        // Use the same logic for SwinTiny and NewModel
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(flaskServerUrl), // Use the Flask server URL defined above
        );
        print(request);
        // Add the image as a multipart file
        request.files.add(
          http.MultipartFile.fromBytes(
            'image_swiny', // Field name for the image
            await File(widget.picture.path).readAsBytes(),
            filename: '${widget.picture.name}',
            contentType: MediaType('image', 'jpeg'), // Content type
          ),
        );

        // Add the selected model as a field in the request
        request.fields['model'] = _selectedModel; // The selected model from the dropdown

        // Send the request and wait for the response
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final responseData = jsonDecode(responseBody);
          setState(() {
            _responseMessage = 'Model: $_selectedModel\nPrediction: ${responseData['prediction'] ?? 'No prediction'}';
            _loading = false;
          });
        } else {
          setState(() {
            _responseMessage = 'Failed to process image: ${response.statusCode}';
            _loading = false;
          });
        }
      }
      if(_selectedModel == 'Resnet (Accuracy: 76.45)') {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(flaskServerUrl), // Use the Flask server URL defined above
        );
        print(request);
        // Add the image as a multipart file
        request.files.add(
          http.MultipartFile.fromBytes(
            'image_resnet', // Field name for the image
            await File(widget.picture.path).readAsBytes(),
            filename: '${widget.picture.name}',
            contentType: MediaType('image', 'jpeg'), // Content type
          ),
        );

        // Add the selected model as a field in the request
        request.fields['model'] = _selectedModel; // The selected model from the dropdown

        // Send the request and wait for the response
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final responseData = jsonDecode(responseBody);
          setState(() {
            _responseMessage = 'Model: $_selectedModel\nPrediction: ${responseData['prediction'] ?? 'No prediction'}';
            _loading = false;
          });
        } else {
          setState(() {
            _responseMessage = 'Failed to process image: ${response.statusCode}';
            _loading = false;
          });
        }
      }
      if(_selectedModel == 'MobileNet v2 (Accuracy: 73.03)') {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(flaskServerUrl), // Use the Flask server URL defined above
        );
        print(request);
        // Add the image as a multipart file
        request.files.add(
          http.MultipartFile.fromBytes(
            'image_mobilenet', // Field name for the image
            await File(widget.picture.path).readAsBytes(),
            filename: '${widget.picture.name}',
            contentType: MediaType('image', 'jpeg'), // Content type
          ),
        );

        // Add the selected model as a field in the request
        request.fields['model'] = _selectedModel; // The selected model from the dropdown

        // Send the request and wait for the response
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final responseData = jsonDecode(responseBody);
          setState(() {
            _responseMessage = 'Model: $_selectedModel\nPrediction: ${responseData['prediction'] ?? 'No prediction'}';
            _loading = false;
          });
        } else {
          setState(() {
            _responseMessage = 'Failed to process image: ${response.statusCode}';
            _loading = false;
          });
        }
      }
      if(_selectedModel == 'EfficientNet b3 (Accuracy: 81.25)') {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(flaskServerUrl), // Use the Flask server URL defined above
        );
        print(request);
        // Add the image as a multipart file
        request.files.add(
          http.MultipartFile.fromBytes(
            'image_efficientnet', // Field name for the image
            await File(widget.picture.path).readAsBytes(),
            filename: '${widget.picture.name}',
            contentType: MediaType('image', 'jpeg'), // Content type
          ),
        );

        // Add the selected model as a field in the request
        request.fields['model'] = _selectedModel; // The selected model from the dropdown

        // Send the request and wait for the response
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final responseData = jsonDecode(responseBody);
          setState(() {
            _responseMessage = 'Model: $_selectedModel\nPrediction: ${responseData['prediction'] ?? 'No prediction'}';
            _loading = false;
          });
        } else {
          setState(() {
            _responseMessage = 'Failed to process image: ${response.statusCode}';
            _loading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Error: $e';
        _loading = false;
      });
    }
  }
}
