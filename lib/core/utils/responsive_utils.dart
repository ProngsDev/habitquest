import 'package:flutter/cupertino.dart';

/// Responsive breakpoints for different screen sizes
class Breakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
}

/// Device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Screen size enumeration
enum ScreenSize {
  small,   // < 480px
  medium,  // 480px - 768px
  large,   // 768px - 1024px
  xlarge,  // > 1024px
}

/// Responsive utility class for handling different screen sizes
class ResponsiveUtils {
  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < Breakpoints.tablet) {
      return DeviceType.mobile;
    } else if (width < Breakpoints.desktop) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < Breakpoints.mobile) {
      return ScreenSize.small;
    } else if (width < Breakpoints.tablet) {
      return ScreenSize.medium;
    } else if (width < Breakpoints.desktop) {
      return ScreenSize.large;
    } else {
      return ScreenSize.xlarge;
    }
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) => 
      getDeviceType(context) == DeviceType.mobile;

  /// Check if device is tablet
  static bool isTablet(BuildContext context) => 
      getDeviceType(context) == DeviceType.tablet;

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) => 
      getDeviceType(context) == DeviceType.desktop;

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
        return const EdgeInsets.all(12);
      case ScreenSize.medium:
        return const EdgeInsets.all(16);
      case ScreenSize.large:
        return const EdgeInsets.all(20);
      case ScreenSize.xlarge:
        return const EdgeInsets.all(24);
    }
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
        return const EdgeInsets.all(8);
      case ScreenSize.medium:
        return const EdgeInsets.all(12);
      case ScreenSize.large:
        return const EdgeInsets.all(16);
      case ScreenSize.xlarge:
        return const EdgeInsets.all(20);
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double baseFontSize,
  }) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
        return baseFontSize * 0.9;
      case ScreenSize.medium:
        return baseFontSize;
      case ScreenSize.large:
        return baseFontSize * 1.1;
      case ScreenSize.xlarge:
        return baseFontSize * 1.2;
    }
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(
    BuildContext context, {
    required double baseIconSize,
  }) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
        return baseIconSize * 0.9;
      case ScreenSize.medium:
        return baseIconSize;
      case ScreenSize.large:
        return baseIconSize * 1.1;
      case ScreenSize.xlarge:
        return baseIconSize * 1.2;
    }
  }

  /// Get number of columns for grid layouts
  static int getGridColumns(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
        return 1;
      case ScreenSize.medium:
        return 2;
      case ScreenSize.large:
        return 3;
      case ScreenSize.xlarge:
        return 4;
    }
  }

  /// Get maximum content width for centering on large screens
  static double getMaxContentWidth(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
      case ScreenSize.medium:
        return double.infinity;
      case ScreenSize.large:
        return 800;
      case ScreenSize.xlarge:
        return 1200;
    }
  }

  /// Get responsive card width
  static double getCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
        return width - 32; // Full width with padding
      case ScreenSize.medium:
        return (width - 48) / 2; // Two columns
      case ScreenSize.large:
        return (width - 64) / 3; // Three columns
      case ScreenSize.xlarge:
        return (width - 80) / 4; // Four columns
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
        return 8;
      case ScreenSize.medium:
        return 12;
      case ScreenSize.large:
        return 16;
      case ScreenSize.xlarge:
        return 20;
    }
  }
}

/// Responsive widget that builds different layouts based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    return builder(context, deviceType);
  }
}

/// Responsive layout widget that provides different layouts for different screen sizes
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// Responsive container that centers content on large screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: responsivePadding,
        child: child,
      ),
    );
  }
}
