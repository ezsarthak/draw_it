import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';

import '../../domain/repositories/socket_repository.dart';
import '../bloc/drawing/drawing_bloc.dart';
import '../bloc/socket/socket_bloc.dart';
import '../bloc/socket/socket_event.dart';
import '../bloc/socket/socket_state.dart';
import 'drawing_board_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _dotsController;
  late Animation<double> _logoAnimation;
  late Animation<double> _dotsAnimation;

  Timer? _connectionTimer;
  bool _isConnecting = true;
  String _statusMessage = 'Connecting to server...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkServerConnection();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _dotsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dotsController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    _dotsController.repeat();
  }

  void _checkServerConnection() async {
    try {
      final socketRepository = GetIt.instance<SocketRepository>();

      // Start connection attempt
      await socketRepository.connect();

      // Set up a timer to check connection status
      _connectionTimer = Timer.periodic(const Duration(milliseconds: 500), (
        timer,
      ) {
        if (socketRepository.isConnected) {
          timer.cancel();
          setState(() {
            _isConnecting = false;
            _statusMessage = 'Connected! Loading app...';
          });

          // Navigate to main app after a short delay
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder:
                      (context) => MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (context) => GetIt.instance<DrawingBloc>(),
                          ),
                          BlocProvider(
                            create:
                                (context) =>
                                    GetIt.instance<SocketBloc>()
                                      ..add(const ConnectEvent()),
                          ),
                        ],
                        child: const DrawingBoardPage(),
                      ),
                ),
              );
            }
          });
        }
      });

      // Timeout after 15 seconds
      Future.delayed(const Duration(seconds: 15), () {
        if (_isConnecting && mounted) {
          _connectionTimer?.cancel();
          setState(() {
            _isConnecting = false;
            _statusMessage = 'Server is starting up...\nThis may take a moment';
          });

          // Retry connection
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              _checkServerConnection();
            }
          });
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Connection failed. Retrying...';
      });

      // Retry after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _checkServerConnection();
        }
      });
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _dotsController.dispose();
    _connectionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600 || screenSize.height < 400;
    final isVerySmallScreen = screenSize.width < 400 || screenSize.height < 300;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            ),
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    screenSize.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isVerySmallScreen ? 16 : 24,
                  vertical: isVerySmallScreen ? 16 : 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Animation
                    AnimatedBuilder(
                      animation: _logoAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoAnimation.value,
                          child: Container(
                            width:
                                isVerySmallScreen
                                    ? 80
                                    : (isSmallScreen ? 100 : 120),
                            height:
                                isVerySmallScreen
                                    ? 80
                                    : (isSmallScreen ? 100 : 120),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withOpacity(0.8),
                                  Colors.purple.withOpacity(0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: isVerySmallScreen ? 15 : 20,
                                  spreadRadius: isVerySmallScreen ? 3 : 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.brush,
                              color: Colors.white,
                              size:
                                  isVerySmallScreen
                                      ? 40
                                      : (isSmallScreen ? 50 : 60),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(
                      height:
                          isVerySmallScreen ? 24 : (isSmallScreen ? 32 : 40),
                    ),

                    // App Title
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Collaborative Drawing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              isVerySmallScreen
                                  ? 20
                                  : (isSmallScreen ? 24 : 28),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: isVerySmallScreen ? 4 : 8),

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Real-time drawing board',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize:
                              isVerySmallScreen
                                  ? 12
                                  : (isSmallScreen ? 14 : 16),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(
                      height:
                          isVerySmallScreen ? 40 : (isSmallScreen ? 50 : 60),
                    ),

                    // Status Message
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize:
                              isVerySmallScreen
                                  ? 12
                                  : (isSmallScreen ? 14 : 16),
                          height: 1.4,
                        ),
                      ),
                    ),

                    SizedBox(height: isVerySmallScreen ? 16 : 20),

                    // Loading Dots or Success Icon
                    SizedBox(
                      height: isVerySmallScreen ? 20 : 24,
                      child:
                          _isConnecting
                              ? AnimatedBuilder(
                                animation: _dotsAnimation,
                                builder: (context, child) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(3, (index) {
                                      final delay = index * 0.3;
                                      final animationValue =
                                          (_dotsAnimation.value - delay).clamp(
                                            0.0,
                                            1.0,
                                          );
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Transform.translate(
                                          offset: Offset(
                                            0,
                                            -10 * animationValue,
                                          ),
                                          child: Container(
                                            width: isVerySmallScreen ? 6 : 8,
                                            height: isVerySmallScreen ? 6 : 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              )
                              : Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: isVerySmallScreen ? 20 : 24,
                              ),
                    ),

                    SizedBox(
                      height:
                          isVerySmallScreen ? 24 : (isSmallScreen ? 32 : 40),
                    ),

                    // Server Info
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.symmetric(
                        horizontal: isVerySmallScreen ? 16 : 20,
                        vertical: isVerySmallScreen ? 8 : 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        'Serverless backend may take a moment to start',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: isVerySmallScreen ? 10 : 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
