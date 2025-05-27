import 'package:flutter/material.dart';

class DrawingControls extends StatelessWidget {
  final Color selectedColor;
  final double selectedWidth;
  final bool isEraser;
  final Function(Color) onColorChanged;
  final Function(double) onWidthChanged;
  final Function(bool) onEraserToggled;

  const DrawingControls({
    super.key,
    required this.selectedColor,
    required this.selectedWidth,
    required this.isEraser,
    required this.onColorChanged,
    required this.onWidthChanged,
    required this.onEraserToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Color selection
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColorButton(Colors.black),
                _buildColorButton(Colors.red),
                _buildColorButton(Colors.green),
                _buildColorButton(Colors.blue),
                _buildColorButton(Colors.yellow),
                _buildColorButton(Colors.purple),
                _buildColorButton(Colors.orange),
                _buildColorButton(Colors.teal),
              ],
            ),
          ),
          
          // Eraser toggle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                const Text('Eraser:'),
                const SizedBox(width: 8),
                Switch(
                  value: isEraser,
                  onChanged: onEraserToggled,
                  activeColor: Colors.blue,
                ),
                const Spacer(),
                if (isEraser)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Eraser Mode Active',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
              ],
            ),
          ),
          
          // Stroke width slider
          Row(
            children: [
              const Icon(Icons.line_weight),
              Expanded(
                child: Slider(
                  value: selectedWidth,
                  min: 1.0,
                  max: 20.0,
                  onChanged: onWidthChanged,
                ),
              ),
              Text('${selectedWidth.round()}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () => onColorChanged(color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == color ? Colors.blue : Colors.grey,
            width: selectedColor == color ? 3 : 1,
          ),
        ),
      ),
    );
  }
}
