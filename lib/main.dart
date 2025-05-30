import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'core/di/injection_container.dart';
import 'presentation/pages/drawing_board_page.dart';
import 'presentation/bloc/drawing/drawing_bloc.dart';
import 'presentation/bloc/socket/socket_bloc.dart';
import 'presentation/bloc/socket/socket_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collaborative Drawing Board',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => GetIt.instance<DrawingBloc>()),
          BlocProvider(
            create:
                (context) =>
                    GetIt.instance<SocketBloc>()..add(const ConnectEvent()),
          ),
        ],
        child: const DrawingBoardPage(),
      ),
    );
  }
}
