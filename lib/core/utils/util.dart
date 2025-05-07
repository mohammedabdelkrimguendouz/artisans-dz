
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:artisans_dz/core/constants/spacing.dart';
import 'package:artisans_dz/core/constants/colors.dart';

class Util
{

  static void showSnackBarMessage(BuildContext context, String message,Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
      ),
    );
  }

  static void showLoadingDialog(BuildContext context , String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  static String generateOTP() {
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
  }





  static Future<bool?> showDialogConfirmation(BuildContext context, String title, String message,String primaryTextAction,
      String secondTextAction,Color primaryColorAction) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:  Text(secondTextAction),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: primaryColorAction),
            child:  Text(primaryTextAction),
          ),
        ],
      ),
    );
  }

}