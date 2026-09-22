import 'package:equatable/equatable.dart';

import '../../../domain/entities/capture_summary.dart';

/// Aquí usamos estados *distintos* (unión), no un solo objeto con flags.
/// La UI pregunta: ¿es Loading, Loaded o Error?
abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

/// Lista que viene de PostgreSQL (vía FastAPI).
class HistoryLoaded extends HistoryState {
  const HistoryLoaded(this.items);

  final List<CaptureSummary> items;

  @override
  List<Object?> get props => [items];
}

class HistoryError extends HistoryState {
  const HistoryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
