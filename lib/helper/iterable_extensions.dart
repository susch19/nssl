extension Linq<E> on List<E> {
  bool removeElements(Iterable<E> elements) {
    bool b = true;
    for (var e in elements) {
      if (!b) return b;
      b = this.remove(e);
    }
    return b;
  }

  List<E> copy() {
    List<E> items = [];
    this.forEach((element) {
      items.add(element);
    });
    return items;
  }
}

extension MoreMath on double {
  double clamp(double lower, double maximum) {
    if (this <= lower) return lower;
    if (this >= maximum) return maximum;
    return this;
  }
}

extension Maps<K, E> on Map<K, E> {
  List<T> select<T>(T Function(K, E) keyFunction) {
    var retList = <T>[];
    for (var entry in this.entries) {
      retList.add(keyFunction(entry.key, entry.value));
    }
    return retList;
  }

  MapEntry<K, E>? elementAt(int index, {MapEntry<K, E>? orElse}) {
    int i = 0;
    for (var el in this.entries) {
      if (index == i) return el;
      i++;
    }
    return orElse;
  }
}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));

  Map<K, List<E>> groupManyBy<K>(List<K> Function(E) keyFunction) =>
      fold(<K, List<E>>{}, (Map<K, List<E>> map, E element) {
        for (var r in keyFunction(element)) {
          map..putIfAbsent(r, () => <E>[]).add(element);
        }
        return map;
      });

  E? firstOrNull(bool Function(E element) keyFunction) {
    for (var item in [...this]) {
      if (keyFunction(item)) return item;
    }
    return null;
  }

  Iterable<E> injectForIndex(E? Function(int index) indexFunc) sync* {
    int index = 0;
    for (var item in [...this]) {
      var res = indexFunc(index);
      if (res != null) yield res;
      yield item;
      index++;
    }
  }

  int sum(int Function(E element) keyFunction) {
    int sum = 0;
    for (var item in [...this]) {
      sum += keyFunction(item);
    }
    return sum;
  }

  int bitOr(int Function(E element) keyFunction) {
    int sum = 0;
    for (var item in [...this]) {
      sum |= keyFunction(item);
    }
    return sum;
  }

  int bitAnd(int Function(E element) keyFunction) {
    int sum = 0;
    for (var item in [...this]) {
      sum &= keyFunction(item);
    }
    return sum;
  }

  int bitXor(int Function(E element) keyFunction) {
    int sum = 0;
    for (var item in [...this]) {
      sum ^= keyFunction(item);
    }
    return sum;
  }
}
