import 'dart:async';
import 'dart:ui';

extension DebounceFunction on Function {
  Function debounce(Duration duration) {
    Timer? timer;
    return () {
      if (timer?.isActive ?? false) timer!.cancel();
      timer = Timer(duration, () => this());
    };
  }
}

class Debounce {
  Duration delay;
  Timer? _timer;

  Debounce(
    this.delay,
  );

  call(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  dispose() {
    _timer?.cancel();
  }
}