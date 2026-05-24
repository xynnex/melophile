import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;

  Responsive(this.context);

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;

  bool get isTablet => width >= 600;
  bool get isDesktop => width >= 900;
  bool get isLandscape => width > height;

  double wp(double percent) => width * percent / 100;
  double hp(double percent) => height * percent / 100;

  double sp(double size) {
    final scale = width / 400;
    return size * scale.clamp(0.8, 1.4);
  }

  double gridCrossAxisCount() {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    return 2;
  }

  double horizontalPadding() {
    if (isDesktop) return wp(8);
    if (isTablet) return wp(6);
    return 24;
  }
}
