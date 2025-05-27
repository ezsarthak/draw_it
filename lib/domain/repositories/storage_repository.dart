import 'package:flutter/material.dart';

abstract class StorageRepository {
  Future<bool> saveDrawing(GlobalKey canvasKey);
  Future<bool> requestPermissions();
}
