import 'dart:io';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class StorageDataSource {
  Future<bool> saveDrawing(GlobalKey canvasKey);
}

class StorageDataSourceImpl implements StorageDataSource {
  @override
  Future<bool> saveDrawing(GlobalKey canvasKey) async {
    late PermissionStatus status;
    if (Platform.isAndroid) {
      // For Android 11 and above, request MANAGE_EXTERNAL_STORAGE permission
      if (!await Permission.manageExternalStorage.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }

      if (!await Permission.storage.isGranted) {
        status = await Permission.storage.request();
      }
    }
    try {
      // Capture the drawing
      final boundary =
          canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to gallery
      final result = await ImageGallerySaverPlus.saveImage(pngBytes);
      print('Image saved: $result');
      return true;
    } on PlatformException catch (error) {
      print('Platform error: $error');
      return false;
    } catch (error) {
      print('Error saving image: $error');
      return false;
    }
  }
}
