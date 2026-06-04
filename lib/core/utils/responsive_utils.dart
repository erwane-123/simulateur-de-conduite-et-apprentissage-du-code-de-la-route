import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 480;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 480 && MediaQuery.of(context).size.width < 1024;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1024;

  static double getPadding(BuildContext context) {
    if (isDesktop(context)) return 48;
    if (isTablet(context)) return 32;
    return 24;
  }

  static double getMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    return MediaQuery.of(context).size.width;
  }

  static int getGridCount(BuildContext context, {int mobile = 2, int desktop = 4}) {
    return isDesktop(context) ? desktop : mobile;
  }
}
