import 'package:bloc/bloc.dart';
import 'package:log_keep/app/app.dart';

class LoggableBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    logger.i(event);
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    logger.i(transition);
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    logger.e(error);
    super.onError(cubit, error, stackTrace);
  }
}
