import 'package:demo_app/Screens/Components/custom_newbutton.dart';
import 'package:demo_app/Screens/Components/custom_text_field.dart';
import 'package:demo_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  final void Function()? onPress;
  const SignUpPage({super.key, this.onPress});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  void signUp() {
    final String email = emailCtrl.text;
    final String password = passwordCtrl.text;
    final String confirmPassword = confirmPasswordCtrl.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('All fields are required'),
        backgroundColor: Colors.red,
      ));
    } else if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Passwords do not match'),
        backgroundColor: Colors.red,
      ));
    } else {
      createAcc();
    }
  }

  void createAcc() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.registerWithEmailAndPassword(
          emailCtrl.text.trim(), passwordCtrl.text.trim())
          .then((res) {
            if (res != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account created successfully'),
                ),
              );
            }
          });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Logo
              const Icon(Icons.message, size: 80),

              const SizedBox(height: 50),
              //Welcome
              const Text('Let\'s create an account for you',
                  style: TextStyle(fontSize: 16)),

              const SizedBox(height: 25),

              //Email
              CustomTextField(
                  controller: emailCtrl, hintText: 'Email', isPassword: false),

              const SizedBox(height: 15),

              //Password
              CustomTextField(
                  controller: passwordCtrl,
                  hintText: 'Password',
                  isPassword: true),

              const SizedBox(height: 15),

              //Confirm Password
              CustomTextField(
                  controller: confirmPasswordCtrl,
                  hintText: 'Confirm Password',
                  isPassword: true),

              const SizedBox(height: 15),
              //sign btn
              CustomNewbutton(
                  text: 'Sign Up',
                  onPressed: () {
                    signUp();
                  }),
              //register btn
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already a member?',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    onTap: widget.onPress,
                    child: const Text(
                      'Login now',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
