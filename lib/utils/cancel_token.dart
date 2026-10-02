
class CancelToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
  void throwIfCancelled() {
    if (_cancelled) throw CancelledException();
  }
}

class CancelledException implements Exception {
  @override
  String toString() => 'Operation was cancelled';
}