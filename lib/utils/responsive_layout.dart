import 'package:flutter/material.dart';

class ResponsiveLayout {
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= _mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > _mobileBreakpoint;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= _tabletBreakpoint;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 600;
    } else {
      return 1200;
    }
  }

  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  static double getCardWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 350;
    } else {
      return 400;
    }
  }

  static double getPhotoGalleryHeight(BuildContext context) {
    if (isMobile(context)) {
      return 120;
    } else if (isTablet(context)) {
      return 150;
    } else {
      return 180;
    }
  }

  static double getPhotoThumbnailSize(BuildContext context) {
    if (isMobile(context)) {
      return 120;
    } else if (isTablet(context)) {
      return 150;
    } else {
      return 180;
    }
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isTablet(context) && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}
