import 'package:flutter/material.dart';

class Dialogs {
  static void showsnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(msg),
      ),
    );
  }

  static void showProgressIndicator(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const  Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
