import 'package:flutter/material.dart';

class Dimensions {
  final BuildContext context;
  Dimensions(this.context);
  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;
  double get unitWidth => MediaQuery.of(context).size.width * 0.01;

  /// Page Padding
  late double topPadding = unitWidth * 10;

  /// Text Size
  late double h1 = MediaQuery.of(context).size.width * (32 / 375);
  late double h3 = MediaQuery.of(context).size.width * (24 / 375);
  late double h4 = MediaQuery.of(context).size.width * (18 / 375);
  late double h5 = MediaQuery.of(context).size.width * (16 / 375);
  late double h6 = MediaQuery.of(context).size.width * (14 / 375);
  late double h7 = MediaQuery.of(context).size.width * (12 / 375);

  /// Text Font Weight
  static FontWeight fontBold = FontWeight.w700;
  static FontWeight fontRegular = FontWeight.w400;

  static String font = 'Sk-Modernist';

  /// Shadows
  static BoxShadow red = BoxShadow(
    offset: Offset(0, 15),
    blurRadius: 15,
    color: Color(0xffE94057).withOpacity(0.2),
  );
  static BoxShadow black = BoxShadow(
    offset: Offset(0, 20),
    blurRadius: 50,
    color: Colors.black.withOpacity(0.07),
  );
  static BoxShadow purple = BoxShadow(
    offset: Offset(0, 15),
    blurRadius: 15,
    color: Color(0xff8A2387).withOpacity(0.2),
  );
}
