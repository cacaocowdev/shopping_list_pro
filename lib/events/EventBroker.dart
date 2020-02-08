import 'package:uuid/uuid.dart';
import 'package:synchronized/synchronized.dart';

typedef void EventHandler(dynamic);

class EventBroker {
  final Map<String, Map<String, EventHandler>> _handlers = new Map();
  final Uuid _uuid = new Uuid();
  final Lock _lock = new Lock(reentrant: true);

  String registerHandler(String event, EventHandler handler) {
    var id = _uuid.v4();

    _handlers.putIfAbsent(event, () => new Map());
    _handlers[event][id] = handler;

    return id;
  }

  bool removeHandler(String id) {
    var deleted = false;

    _handlers.forEach((k, v) => deleted = deleted || v.remove(id) != null);

    return deleted;
  }

  void triggerEvent(String event, dynamic obj) async {
    await _lock.synchronized(() =>
        _handlers[event]?.forEach((k, handler) =>
        handler != null ? handler(obj): null));
  }
}