import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF035079);
  static const Color accentColor = Color(0xCC035079);
  static const Color textColor = Colors.black;
  static const Color buttonTextColor = Colors.white;

  static const Gradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF87CDF2),
      Color.fromARGB(255, 139, 197, 228),
      Color(0xCC49A3D1),
      Color(0xE587C0DD),
      Color(0xFFDCE9F0),
      Color(0xFFD0E1EB),
      Color(0xFFDFF4FF),
      Colors.white,
    ],
  );

  static Widget customButton({
    required String text,
    required VoidCallback onTap,
    Color backgroundColor = accentColor,
    Color textColor = buttonTextColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: 300,
        height: 70,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 30,
              fontWeight: FontWeight.w400,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }
}
