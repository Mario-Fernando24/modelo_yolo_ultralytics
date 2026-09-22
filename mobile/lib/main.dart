import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injection_container.dart';
import 'presentation/bloc/camera/camera_bloc.dart';
import 'presentation/bloc/camera/camera_event.dart';
import 'presentation/pages/camera_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // get_it: registra BLoCs, casos de uso, repositorio y HTTP.
  await initDependencies();
  runApp(const VisionAIApp());
}

class VisionAIApp extends StatelessWidget {
  const VisionAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocProvider deja el CameraBloc disponible para CameraPage.
    // El `..add` dispara el primer evento: encender la cámara.
    return BlocProvider(
      create: (_) => sl<CameraBloc>()..add(const CameraStarted()),
      child: MaterialApp(
        title: 'VisionAI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0EA5E9),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const CameraPage(),
      ),
    );
  }
}
