import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:idletamergame/habitatview.dart';
import 'package:idletamergame/loginsingleton.dart';
import 'package:idletamergame/registerview.dart';

class LoginView extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();//hold value

@override
  void dispose(){//dispose values override method
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final login = await LoginSingleton().authenticate(email, password);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Habitat(login: login),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.code == 'user-not-found'
                ? 'No account exists with that email.'
                : error.message ?? 'Login failed.',
          ),
        ),
      );
    }
  }

  @override

  var textStyle = const TextStyle(fontWeight: FontWeight.w900, fontSize: 32);

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


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login")
      ),
      body: Container(
        alignment: Alignment.center,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('TitleGame.png'),width:200,height:200),
            Text("Login",  style: TextStyle(fontSize: 20, fontWeight: .bold),),
            SizedBox(height: 20),
            buildTextField(_emailController, false, "Email"),
            buildTextField(_passwordController, true, "Password"),
            buildButton(submit, "Submit"),
            buildButton((){
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterView()),
    );
            },"Register")
          ],
        ),
      ),
    );
  }
}