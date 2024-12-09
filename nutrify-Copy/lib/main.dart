import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:nutrify/Pages/home.dart';
import 'package:nutrify/Pages/login.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDNSYZAVeCKFPRs9N2zIrygJ1UjzlPLkHY',
        appId: '95d5ae2965489176fca25d',
        messagingSenderId: '1:538370776040:android:95d5ae2965489176fca25d',
        projectId: 'nutrify-abea7',
        storageBucket: 'nutrify-abea7.appspot.com',
      )
  );
  Gemini.init(apiKey: 'AIzaSyAxqba8vgvihZsqxTyYSpbRb926fm_qguI');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark
      ),
      // home: const HomeScreen(),
      home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
    );
  }
}