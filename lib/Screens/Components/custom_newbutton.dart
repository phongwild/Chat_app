import 'package:flutter/material.dart';

class CustomNewbutton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  const CustomNewbutton({super.key, this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: Color(0xff002DE3),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500
            ),
          ),
        ),
      ),
    );
  }
}
