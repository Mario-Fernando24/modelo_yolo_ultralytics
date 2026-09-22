import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/usecase/usecase.dart';
import '../../../domain/repositories/detection_repository.dart';
import '../../../domain/usecases/get_history.dart';
import 'history_event.dart';
import 'history_state.dart';

/// BLoC del historial: más simple que el de cámara.
///
/// HistoryStarted / HistoryRefreshed → GET /captures →
///   HistoryLoading → HistoryLoaded(lista)  o  HistoryError(texto)
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({
    required this.getHistory,
    required this.repository,
  }) : super(const HistoryLoading()) {
    // Los dos eventos hacen lo mismo: recargar la lista.
    on<HistoryStarted>(_onLoad);
    on<HistoryRefreshed>(_onLoad);
  }

  final GetHistory getHistory;
  final DetectionRepository repository;

  /// Convierte "/media/uuid.jpg" en "http://IP:8001/media/uuid.jpg".
  String mediaUrl(String path) => repository.resolveMedia(path);

  Future<void> _onLoad(HistoryEvent event, Emitter<HistoryState> emit) async {
    emit(const HistoryLoading());
    final result = await getHistory(const NoParams());
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (items) => emit(HistoryLoaded(items)),
    );
  }
}
