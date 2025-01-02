import 'package:demo_app/Screens/Components/custom_newbutton.dart';
import 'package:demo_app/Screens/Components/custom_text_field.dart';
import 'package:demo_app/Screens/ui/bottom_nav/bottom_nav.dart';
import 'package:demo_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onPress;
  const LoginPage({super.key, this.onPress});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  void signIn() {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      authService
          .signInWithEmailAndPassword(
              emailCtrl.text.trim(), passwordCtrl.text.trim())
          .then((res) {
        if (res != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                print('Navigating to BottomNav');
                return BottomNav(user: res,);
              },
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
              Image.asset('assets/images/illustration.png', width: 162, height: 171,),

              const SizedBox(height: 50),
              //Welcome
              const Text('Welcome back you\'ve been missed',
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
              //sign btn
              CustomNewbutton(
                  text: 'Login',
                  onPressed: () {
                    signIn();
                  }),
              //register btn
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Not a member?',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    onTap: widget.onPress,
                    child: const Text(
                      'Register now',
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
