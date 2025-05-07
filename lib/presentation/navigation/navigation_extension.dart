import 'package:flutter/material.dart';

extension NavigationExtension on BuildContext {
  // انتقال مع استبدال الصفحة
  void navigateTo(Widget page) {
    Navigator.of(this).pushReplacement(
      _createRoute(page),
    );
  }

  // انتقال عادي مع إمكانية الرجوع
  void pushTo(Widget page) {
    Navigator.of(this).push(
      _createRoute(page),
    );
  }

  // العودة للصفحة السابقة
  void pop() {
    Navigator.of(this).pop();
  }

  // إنشاء تأثير الانتقال
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }
}