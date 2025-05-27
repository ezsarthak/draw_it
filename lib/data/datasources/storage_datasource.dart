import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class StorageDataSource {
  Future<bool> saveDrawing(GlobalKey canvasKey);
  Future<bool> requestPermissions();
}

class StorageDataSourceImpl implements StorageDataSource {
  @override
  Future<bool> saveDrawing(GlobalKey canvasKey) async {
    try {
      // Request permissions first
      final hasPermission = await requestPermissions();
      if (!hasPermission) return false;

      // Capture the drawing
      final boundary = canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'drawing_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      
      // Write file
      await file.writeAsBytes(pngBytes);

      // Save to gallery using gal
      await Gal.putImage(file.path);
      
      // Clean up temporary file
      await file.delete();
      
      return true;
    } on PlatformException catch (error) {
      print('Platform error: $error');
      return false;
    } catch (error) {
      print('Error saving image: $error');
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // For Android 13 and above, we need different permissions
      if (Platform.version.contains('33') || Platform.version.contains('34')) {
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        // For older Android versions
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true; // iOS doesn't need explicit permission for saving to gallery
  }
}
