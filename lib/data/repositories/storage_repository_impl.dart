import 'package:flutter/material.dart';
import '../../domain/repositories/storage_repository.dart';
import '../datasources/storage_datasource.dart';

class StorageRepositoryImpl implements StorageRepository {
  final StorageDataSource _dataSource;

  StorageRepositoryImpl(this._dataSource);

  @override
  Future<bool> saveDrawing(GlobalKey canvasKey) {
    return _dataSource.saveDrawing(canvasKey);
  }
}
