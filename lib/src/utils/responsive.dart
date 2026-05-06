import 'package:flutter/material.dart';

/// Utility class for responsive sizing using MediaQuery
class ResponsiveUtils {
  /// Get responsive width as a percentage of screen width
  ///
  /// Example:
  /// - getResponsiveWidth(context, 0.5) returns 50% of screen width
  /// - getResponsiveWidth(context, 0.3) returns 30% of screen width
  static double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  /// Get responsive height as a percentage of screen height
  static double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  /// Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  /// Get responsive font size based on screen width
  /// This helps keep text proportional across different devices
  static double getFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    // Use 400.0 as a baseline width for standard phones
    // On tablet or desktop, we don't want it to grow indefinitely
    double scaleFactor = screenWidth / 400.0;
    
    // Clamp the scale factor to reasonable bounds
    if (scaleFactor > 1.4) scaleFactor = 1.4;
    if (scaleFactor < 0.85) scaleFactor = 0.85;
    
    return baseSize * scaleFactor;
  }

  /// Shorthand for getFontSize
  static double sp(BuildContext context, double size) => getFontSize(context, size);
}
