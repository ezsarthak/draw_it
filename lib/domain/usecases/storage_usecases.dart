import 'package:flutter/material.dart';
import '../repositories/storage_repository.dart';

class SaveDrawingUseCase {
  final StorageRepository repository;

  SaveDrawingUseCase(this.repository);

  Future<bool> call(GlobalKey canvasKey) {
    return repository.saveDrawing(canvasKey);
  }
}
