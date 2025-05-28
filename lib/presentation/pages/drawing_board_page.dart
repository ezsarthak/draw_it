import 'package:draw_new/core/utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';

import '../../domain/entities/drawn_line.dart';
import '../../domain/usecases/storage_usecases.dart';
import '../../domain/repositories/socket_repository.dart';
import '../bloc/drawing/drawing_bloc.dart';
import '../bloc/drawing/drawing_event.dart';
import '../bloc/drawing/drawing_state.dart';
import '../bloc/socket/socket_bloc.dart';
import '../bloc/socket/socket_event.dart';
import '../bloc/socket/socket_state.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/drawing_controls.dart';
import '../widgets/user_list.dart';

class DrawingBoardPage extends StatefulWidget {
  const DrawingBoardPage({super.key});

  @override
  State<DrawingBoardPage> createState() => _DrawingBoardPageState();
}

class _DrawingBoardPageState extends State<DrawingBoardPage> {
  final GlobalKey _canvasKey = GlobalKey();
  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;
  bool isEraser = false;

  StreamSubscription? _drawLineSubscription;
  StreamSubscription? _undoSubscription;
  StreamSubscription? _redoSubscription;
  StreamSubscription? _clearCanvasSubscription;

  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    final socketRepository = GetIt.instance<SocketRepository>();

    // Listen to remote drawing events
    _drawLineSubscription = socketRepository.drawLineStream.listen((line) {
      print('Received remote line');
      context.read<DrawingBloc>().add(AddRemoteLineEvent(line));
    });

    _undoSubscription = socketRepository.undoStream.listen((_) {
      print('Received remote undo');
      context.read<DrawingBloc>().add(const RemoteUndoEvent());
    });

    _redoSubscription = socketRepository.redoStream.listen((_) {
      print('Received remote redo');
      context.read<DrawingBloc>().add(const RemoteRedoEvent());
    });

    _clearCanvasSubscription = socketRepository.clearCanvasStream.listen((_) {
      print('Received remote clear');
      context.read<DrawingBloc>().add(const RemoteClearLinesEvent());
    });
  }

  @override
  void dispose() {
    _drawLineSubscription?.cancel();
    _undoSubscription?.cancel();
    _redoSubscription?.cancel();
    _clearCanvasSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Dimensions appDimension = Dimensions(context);

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          child: Text(
            'Draw it',
            style: TextStyle(
              fontFamily: Dimensions.font,
              fontSize: appDimension.h3,
              fontWeight: Dimensions.fontBold,
            ),
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _showNameDialog),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveDrawing),
          BlocBuilder<DrawingBloc, DrawingState>(
            builder: (context, state) {
              final canUndo = state.lines.isNotEmpty;
              return IconButton(
                icon: Icon(
                  Icons.undo,
                  color: canUndo ? Colors.white : Colors.white54,
                ),
                onPressed:
                    canUndo
                        ? () {
                          print('Local undo triggered');
                          context.read<DrawingBloc>().add(const UndoEvent());
                          context.read<SocketBloc>().add(const EmitUndoEvent());
                        }
                        : null,
              );
            },
          ),
          BlocBuilder<DrawingBloc, DrawingState>(
            builder: (context, state) {
              final canRedo = state.undoStack.isNotEmpty;
              return IconButton(
                icon: Icon(
                  Icons.redo,
                  color: canRedo ? Colors.white : Colors.white54,
                ),
                onPressed:
                    canRedo
                        ? () {
                          print('Local redo triggered');
                          // Get the line that will be redone
                          final lineToRedo = state.undoStack.last;
                          context.read<DrawingBloc>().add(const RedoEvent());
                          // Emit the line to other users
                          context.read<SocketBloc>().add(
                            EmitDrawLineEvent(lineToRedo),
                          );
                        }
                        : null,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status
          BlocBuilder<SocketBloc, SocketState>(
            builder: (context, state) {
              final socketRepository = GetIt.instance<SocketRepository>();
              bool isActualConnected = socketRepository.isConnected;
              return Container(
                padding: const EdgeInsets.all(8.0),
                color:
                    isActualConnected
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                child: Row(
                  children: [
                    Icon(
                      isActualConnected ? Icons.check_circle : Icons.error,
                      color: isActualConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isActualConnected
                          ? 'Connected as ${state.userName.isNotEmpty ? state.userName : "User"}'
                          : 'Disconnected. Trying to reconnect...',
                      style: TextStyle(
                        fontFamily: Dimensions.font,
                        fontSize: appDimension.h6,
                        fontWeight: Dimensions.fontRegular,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Drawing canvas
          Expanded(
            child: RepaintBoundary(
              key: _canvasKey,
              child: DrawingCanvas(
                selectedColor: selectedColor,
                selectedWidth: selectedWidth,
                isEraser: isEraser,
                onLineCompleted: (line) {
                  print('Line completed locally');
                  context.read<DrawingBloc>().add(AddLineEvent(line));
                  context.read<SocketBloc>().add(EmitDrawLineEvent(line));
                },
                onCurrentLineUpdated: (line) {
                  context.read<DrawingBloc>().add(UpdateCurrentLineEvent(line));
                },
              ),
            ),
          ),

          // Drawing controls
          DrawingControls(
            selectedColor: selectedColor,
            selectedWidth: selectedWidth,
            isEraser: isEraser,
            onColorChanged: (color) => setState(() => selectedColor = color),
            onWidthChanged: (width) => setState(() => selectedWidth = width),
            onEraserToggled: (eraser) => setState(() => isEraser = eraser),
          ),

          // Active users
          BlocBuilder<SocketBloc, SocketState>(
            builder: (context, state) {
              return UserList(
                users: state.activeUsers,
                currentUserId: state.userId,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Clear canvas triggered');
          context.read<DrawingBloc>().add(const ClearLinesEvent());
          context.read<SocketBloc>().add(const EmitClearCanvasEvent());
        },
        tooltip: 'Clear Canvas',
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
    );
  }

  void _showNameDialog() {
    final currentName = context.read<SocketBloc>().state.userName;
    final controller = TextEditingController(text: currentName);
    final Dimensions appDimension = Dimensions(context);

    showDialog(
      context: context,
      builder:
          (newContext) => AlertDialog(
            title: Text(
              'Change Your Name',
              style: TextStyle(
                fontFamily: Dimensions.font,
                fontSize: appDimension.h4,
                fontWeight: Dimensions.fontBold,
              ),
            ),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Your Name'),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(newContext),
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    fontFamily: Dimensions.font,
                    fontSize: appDimension.h6,
                    fontWeight: Dimensions.fontRegular,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    context.read<SocketBloc>().add(
                      UpdateNameEvent(controller.text.trim()),
                    );
                  }
                  Navigator.pop(newContext);
                },
                child: Text(
                  'SAVE',
                  style: TextStyle(
                    fontFamily: Dimensions.font,
                    fontSize: appDimension.h6,
                    fontWeight: Dimensions.fontRegular,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _saveDrawing() async {
    try {
      final saveUseCase = GetIt.instance<SaveDrawingUseCase>();
      final success = await saveUseCase(_canvasKey);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Drawing saved successfully!'
                  : 'Failed to save drawing',
              style: TextStyle(
                fontFamily: Dimensions.font,
                fontSize: Dimensions(context).h6,
                fontWeight: Dimensions.fontRegular,
              ),
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error saving drawing: $e',
              style: TextStyle(
                fontFamily: Dimensions.font,
                fontSize: Dimensions(context).h6,
                fontWeight: Dimensions.fontRegular,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
