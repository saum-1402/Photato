import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home.dart';
// import 'package:firebase_auth/firebase_auth.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;

  final TextEditingController logidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                child: Text("S"),
                radius: 40,
              ),
              const SizedBox(
                height: 35,
              ),
              SizedBox(
                height: 50,
                width: 300,
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  controller: logidController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Login ID",
                    alignLabelWithHint: false,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 300,
                height: 50,
                child: TextField(
                  textAlign: TextAlign.center,
                  // onChanged: (value){
                  //   password=value         //extracing the strings can also be done using this
                  // },
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Password",
                  ),
                ),
              ),
              ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.green),
                ),
                onPressed: () async {
                  print(logidController.text);
                  print(passwordController.text);
                  try {
                    final newSignin = await _auth.createUserWithEmailAndPassword(
                        email: logidController.text,
                        password: passwordController.text);

                    if(newSignin!=null){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> const HomeScreen()),);
                    }
                  } catch (e) {
                    print(e.toString());
                  }
                },
                child: const Text(
                  "Sign in",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}