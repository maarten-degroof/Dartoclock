import 'package:dartoclock/BackgroundColorEnum.dart';
import 'package:flutter/material.dart';

class BackgroundColorLoader {
  static Map<BackgroundColor, List<Color>> colorMap = {
    BackgroundColor.Peach: [
      Color.fromRGBO(245, 68, 113, 1.0),
      Color.fromRGBO(245, 161, 81, 1.0),
    ],
    BackgroundColor.Turquoise: [
      Color.fromRGBO(67, 206, 162, 1.0),
      Color.fromRGBO(24, 90, 157, 1.0),
    ],
    BackgroundColor.Emerald: [
      Color.fromRGBO(15, 155, 15, 1.0),
      Color.fromRGBO(50, 50, 50, 1.0),
    ],
    BackgroundColor.Blue: [
      Color.fromRGBO(77, 85, 225, 1.0),
      Color.fromRGBO(93, 167, 231, 1.0),
    ],
    BackgroundColor.Dawn: [
      Color.fromRGBO(204, 149, 192, 1.0),
      Color.fromRGBO(219, 212, 180, 1.0),
      Color.fromRGBO(122, 161, 210, 1.0),
    ],
    BackgroundColor.Maroon: [
      Color.fromRGBO(147, 41, 30, 1.0),
      Color.fromRGBO(51, 51, 51, 1.0),
    ],
    BackgroundColor.Lagoon: [
      Color.fromRGBO(15, 32, 39, 1.0),
      Color.fromRGBO(32, 58, 67, 1.0),
      Color.fromRGBO(44, 83, 100, 1.0),
    ]
  };

  /// Returns the colors connected to the [BackgroundColor] color.
  ///
  /// Given a [color] which is the String representation of a [BackgroundColor],
  /// returns the list of colors from that color.
  static List<Color> getColor(String color) {
    color = color.replaceAll(' ', '_');
    BackgroundColor key = BackgroundColor.values.firstWhere(
        (e) => e.toString() == 'BackgroundColor.' + color,
        orElse: () => BackgroundColor.Peach);

    return colorMap[key];
  }

  /// Returns a list of the [BackgroundColor] items in String format.
  static List<String> getColorNamesList() {
    List<String> list = [];

    BackgroundColor.values.forEach((element) {
      list.add(element.toString().split('.').last.replaceAll('_', ' '));
    });

    return list;
  }

}
