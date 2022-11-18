import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scannerapp/blocs/tabinfo_event.dart';

class TabInfoBloc extends Bloc<TabInfoEvent, int> {
  TabInfoBloc() : super(1) {
    on<GoUno>(_goUno);
    on<GoDos>(_goDos);
  }

  ///se define que se va a ordenar por fecha (botón 1)
  void _goUno(TabInfoEvent event, Emitter<int> emit) async {
    emit(1);
  }

  ///se define que se va a ordenar alfabeticametne (botón 2)
  void _goDos(TabInfoEvent event, Emitter<int> emit) async {
    emit(2);
  }
}
