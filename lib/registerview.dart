import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:idletamergame/habitatview.dart';
import 'package:idletamergame/loginsingleton.dart';
import 'package:idletamergame/models/login.dart';

class RegisterView extends StatefulWidget {
  const new({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final TextEditingController _nameController = TextEditingController();

class _RegisterViewState extends State<RegisterView> {
  buildTextField(controller, isObscure, labelText) => 
  SizedBox(
    width:350,
    height: 75,
    child: TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
  )
  );

  buildButton(onPressed, labelText) =>
  Padding(padding: const EdgeInsets.all(8),
  child:
  ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      fixedSize: const Size(350, 50),
    ),
    child: Text(labelText),
  )
  );

  var registerText = Column(
    mainAxisAlignment: .center,
    children: [
      Text(
        'Register ',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      Text(
        'Complete Fields to Continue',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ],
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register")
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFF4CFF2D),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(18),
                child: registerText,
              ),
              buildTextField(_nameController, false, "Name"),
              buildTextField(_emailController, false, "Email"),
              buildTextField(_passwordController, true, "Password"),
              buildButton(_signUp, "Register")
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text;
    final login = Login(email: email, password: password, name: name);

    try {
      await LoginSingleton().createUser(login);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Habitat(login: LoginSingleton().getLogin()),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.code == 'already-exists'
                ? 'This email is already registered.'
                : error.message ?? 'Database registration failed.',
          ),
        ),
      );
    }
  }
}