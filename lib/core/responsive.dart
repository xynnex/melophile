import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  late final MediaQueryData _mediaQueryData;

  Responsive(this.context) {
    _mediaQueryData = MediaQuery.of(context);
  }

  double get width => _mediaQueryData.size.width;
  double get height => _mediaQueryData.size.height;
  double get textScaleFactor => _mediaQueryData.textScaleFactor;
  EdgeInsets get padding => _mediaQueryData.padding;
  double get viewInsetsBottom => _mediaQueryData.viewInsets.bottom;

  bool get isTablet => width >= 600;
  bool get isDesktop => width >= 900;
  bool get isLandscape => width > height;

  // Width proportional to screen width
  double wp(double percent) => width * percent / 100;
  
  // Height proportional to screen height
  double hp(double percent) => height * percent / 100;

  // Scalable pixel (based on standard 400px width)
  double sp(double size) {
    final scale = width / 400;
    // Clamping to prevent extreme scaling
    return size * scale.clamp(0.8, 1.2) / textScaleFactor;
  }

  double gridCrossAxisCount() {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    return 2;
  }

  double horizontalPadding() {
    if (isDesktop) return wp(10);
    if (isTablet) return wp(8);
    return wp(5);
  }

  // Safe vertical spacing that accounts for view insets (keyboard)
  double safeBlockVertical(double percent) {
    final safeHeight = height - padding.top - padding.bottom;
    return safeHeight * percent / 100;
  }
}
