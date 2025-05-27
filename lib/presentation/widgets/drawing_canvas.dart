import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/drawn_line.dart';
import '../bloc/drawing/drawing_bloc.dart';
import '../bloc/drawing/drawing_state.dart';
import 'drawing_painter.dart';

class DrawingCanvas extends StatefulWidget {
  final Color selectedColor;
  final double selectedWidth;
  final bool isEraser;
  final Function(DrawnLine) onLineCompleted;
  final Function(DrawnLine?) onCurrentLineUpdated;

  const DrawingCanvas({
    super.key,
    required this.selectedColor,
    required this.selectedWidth,
    required this.isEraser,
    required this.onLineCompleted,
    required this.onCurrentLineUpdated,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  DrawnLine? currentLine;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTapDown: _onTapDown,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: BlocBuilder<DrawingBloc, DrawingState>(
          builder: (context, state) {
            return CustomPaint(
              painter: DrawingPainter(
                lines: state.lines,
                currentLine: state.currentLine,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final localPosition = details.localPosition;
    final newLine = DrawnLine(
      points: [localPosition],
      color: widget.isEraser ? Colors.white : widget.selectedColor,
      width: widget.isEraser ? widget.selectedWidth * 2 : widget.selectedWidth,
    );
    
    setState(() {
      currentLine = newLine;
    });
    widget.onCurrentLineUpdated(newLine);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (currentLine == null) return;

    final localPosition = details.localPosition;
    final updatedLine = currentLine!.copyWith(
      points: [...currentLine!.points, localPosition],
    );
    
    setState(() {
      currentLine = updatedLine;
    });
    widget.onCurrentLineUpdated(updatedLine);
  }

  void _onPanEnd(DragEndDetails details) {
    if (currentLine != null) {
      widget.onLineCompleted(currentLine!);
      setState(() {
        currentLine = null;
      });
      widget.onCurrentLineUpdated(null);
    }
  }

  void _onTapDown(TapDownDetails details) {
    final localPosition = details.localPosition;
    final newLine = DrawnLine(
      points: [localPosition],
      color: widget.isEraser ? Colors.white : widget.selectedColor,
      width: widget.isEraser ? widget.selectedWidth * 2 : widget.selectedWidth,
    );
    widget.onLineCompleted(newLine);
  }
}
