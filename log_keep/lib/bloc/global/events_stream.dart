import 'dart:async';

import 'package:rxdart/rxdart.dart';

abstract class EventsStream {
  Stream<Object> events();
  void add(Object event);
}

class CommonEventsStream extends EventsStream {
  StreamController<Object> _streamController = BehaviorSubject<Object>();

  @override
  void add(Object event) {
    _streamController.add(event);
  }

  @override
  Stream<Object> events() {
    return _streamController.stream;
  }
}