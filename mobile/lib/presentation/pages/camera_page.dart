import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection_container.dart';
import '../bloc/camera/camera_bloc.dart';
import '../bloc/camera/camera_event.dart';
import '../bloc/camera/camera_state.dart';
import '../bloc/history/history_bloc.dart';
import '../bloc/history/history_event.dart';
import '../widgets/detection_overlay.dart';
import '../widgets/object_chips.dart';
import '../widgets/status_banner.dart';
import 'history_page.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocConsumer = listener (efectos: SnackBar) + builder (dibujar el estado).
    // La página no llama a FastAPI: solo add(Evento) y lee CameraState.
    return BlocConsumer<CameraBloc, CameraState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        final message = state.message;
        if (message == null) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        // Avisamos al BLoC que el mensaje ya se mostró.
        context.read<CameraBloc>().add(const CameraMessageConsumed());
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('VisionAI'),
            actions: [
              IconButton(
                tooltip: 'URL del servidor',
                onPressed: () => _editApiUrl(context, state.apiUrl),
                icon: const Icon(Icons.settings),
              ),
              IconButton(
                tooltip: 'Historial',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => sl<HistoryBloc>()..add(const HistoryStarted()),
                        child: const HistoryPage(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(child: _Preview(state: state)),
              StatusBanner(
                text: state.status,
                hasCar: state.detection?.hasCar ?? false,
              ),
              ObjectChips(objects: state.detection?.objects ?? const []),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: state.saving
                              ? null
                              : () => context.read<CameraBloc>().add(
                                    // Evento: el BLoC decide abrir galería y guardar.
                                    const CameraGalleryPressed(),
                                  ),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Galería'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: state.saving
                              ? null
                              : () => context.read<CameraBloc>().add(
                                    const CameraCapturePressed(),
                                  ),
                          icon: state.saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.camera_alt),
                          label: Text(state.saving ? 'Guardando…' : 'Tomar foto y guardar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editApiUrl(BuildContext context, String current) async {
    final field = TextEditingController(text: current);
    final next = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('URL de FastAPI'),
          content: TextField(
            controller: field,
            decoration: const InputDecoration(
              hintText: 'http://192.168.1.10:8001',
            ),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () => Navigator.pop(context, field.text.trim()),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
    field.dispose();
    if (next != null && next.isNotEmpty && context.mounted) {
      context.read<CameraBloc>().add(CameraApiUrlChanged(next));
    }
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.state});

  final CameraState state;

  @override
  Widget build(BuildContext context) {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.error ?? 'Abriendo la cámara…',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.previewSize?.height ?? 1,
              height: controller.value.previewSize?.width ?? 1,
              child: CameraPreview(controller),
            ),
          ),
          if (state.detection != null)
            DetectionOverlay(objects: state.detection!.objects),
        ],
      ),
    );
  }
}
