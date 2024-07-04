import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void logout(BuildContext context) {
  SharedPreferences.getInstance().then(
        (prefs) {
      prefs.clear();
      Navigator.pushReplacementNamed(context, 'login');
    },
  );
}