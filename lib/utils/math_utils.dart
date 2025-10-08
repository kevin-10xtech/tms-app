import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// figma height 48 => 48/8  =>  getSizeHeight(context, 6)
/// figma width  48 => 48/4  =>  getSizeWidth(context, 12)
/// font size same as figma

double getSizeWidth(BuildContext context, double percentage) {
  return (percentage * ((MediaQuery.of(context).size.width))) / 100;
}

double getSizeHeight(BuildContext context, double percentage) {
  return (percentage * ((MediaQuery.of(context).size.height))) / 100;
}

double getFontSize(BuildContext context, double percentage) {
  return (percentage * ((MediaQuery.of(context).size.width) / 3)) / 100;
}

extension DoubleExtension on double {
  /// Vertical Spaced SizedBox
  Widget toVSB(BuildContext context) {
    return SizedBox(
      height: (this * ((MediaQuery.of(context).size.height))) / 100,
    );
  }

  /// Horizontal Spaced SizedBox
  Widget toHSB(BuildContext context) {
    return SizedBox(width: (this * (MediaQuery.of(context).size.width)) / 100);
  }
}

String getInitials(String fullName) => fullName.isNotEmpty
    ? fullName.trim().split(' ').map((l) => l[0]).take(2).join()
    : '';

String getRoundOff(String value, {int fractionCount = 2}) {
  try {
    var number = double.tryParse(value);
    return (number?.toStringAsFixed(fractionCount)) ??
        0.toStringAsFixed(fractionCount);
  } catch (e) {
    return 0.toStringAsFixed(fractionCount);
  }
}

bool isIpad() {
  // You can adjust the threshold to fit your needs
  final double screenWidth = Get.width;
  return screenWidth >=
      768.0; // iPads generally have a minimum screen width of 768px
}
