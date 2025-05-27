import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class DrawnLine extends Equatable {
  final List<Offset> points;
  final Color color;
  final double width;

  const DrawnLine({
    required this.points,
    required this.color,
    required this.width,
  });

  DrawnLine copyWith({
    List<Offset>? points,
    Color? color,
    double? width,
  }) {
    return DrawnLine(
      points: points ?? this.points,
      color: color ?? this.color,
      width: width ?? this.width,
    );
  }

  @override
  List<Object?> get props => [points, color, width];
}
