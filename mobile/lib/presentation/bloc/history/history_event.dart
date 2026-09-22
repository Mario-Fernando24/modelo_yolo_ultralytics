import 'package:equatable/equatable.dart';

/// Eventos de la pantalla Historial.
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Primera carga al entrar a la pantalla.
class HistoryStarted extends HistoryEvent {
  const HistoryStarted();
}

/// Pull/botón refresh: vuelve a GET /captures.
class HistoryRefreshed extends HistoryEvent {
  const HistoryRefreshed();
}
