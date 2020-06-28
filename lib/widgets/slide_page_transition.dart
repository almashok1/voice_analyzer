import 'package:flutter/material.dart';

PageRouteBuilder slidePageTransition(Widget child, [fromRight = false]) => PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => child,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    var begin = fromRight ? Offset(1.0, 0.0) : Offset(0.0, 1.0);
    var end = Offset.zero;
    var curve = Curves.ease;
    var tween = Tween(begin: begin, end: end,).chain(CurveTween(curve: curve),);
    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  },
);
