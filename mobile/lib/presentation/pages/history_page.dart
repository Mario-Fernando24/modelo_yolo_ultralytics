import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/history/history_bloc.dart';
import '../bloc/history/history_event.dart';
import '../bloc/history/history_state.dart';
import '../widgets/photo_viewer_modal.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de detecciones'),
        actions: [
          IconButton(
            onPressed: () => context.read<HistoryBloc>().add(const HistoryRefreshed()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HistoryError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          final items = state is HistoryLoaded ? state.items : const [];
          if (items.isEmpty) {
            return const Center(child: Text('Todavía no hay fotografías guardadas.'));
          }
          final bloc = context.read<HistoryBloc>();
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final photoUrl = bloc.mediaUrl(item.annotatedUrl ?? item.imageUrl);
              return ListTile(
                onTap: () => PhotoViewerModal.open(
                  context,
                  imageUrl: photoUrl,
                  caption: item.summary,
                ),
                leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photoUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported),
                    ),
                  ),
                title: Text(item.hasCar ? 'Automóvil detectado' : 'Sin automóvil'),
                subtitle: Text(item.summary),
                isThreeLine: true,
                trailing: Text('${item.objectCount} obj.'),
              );
            },
          );
        },
      ),
    );
  }
}
