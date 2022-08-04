class Tuple<T1> {
  final T1 t1;

  Tuple(this.t1);

  @override
  String toString() => 'Tuple[$t1]';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuple && runtimeType == other.runtimeType && t1 == other.t1;

  @override
  int get hashCode => t1.hashCode;
}

class Tuple2<T1, T2> {
  final T1 t1;
  final T2 t2;

  Tuple2(this.t1, this.t2);

  @override
  String toString() => 'Tuple[$t1, $t2]';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuple2 &&
          runtimeType == other.runtimeType &&
          t1 == other.t1 &&
          t2 == other.t2;

  @override
  int get hashCode => t1.hashCode ^ t2.hashCode;
}

class Tuple3<T1, T2, T3> {
  final T1 t1;
  final T2 t2;
  final T3 t3;

  Tuple3(this.t1, this.t2, this.t3);

  @override
  String toString() => 'Tuple[$t1, $t2, $t3]';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuple3 &&
          runtimeType == other.runtimeType &&
          t1 == other.t1 &&
          t2 == other.t2 &&
          t3 == other.t3;

  @override
  int get hashCode => t1.hashCode ^ t2.hashCode ^ t3.hashCode;
}

class Tuple4<T1, T2, T3, T4> {
  final T1 t1;
  final T2 t2;
  final T3 t3;
  final T4 t4;

  Tuple4(this.t1, this.t2, this.t3, this.t4);

  @override
  String toString() => 'Tuple[$t1, $t2, $t3, $t4]';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuple4 &&
          runtimeType == other.runtimeType &&
          t1 == other.t1 &&
          t2 == other.t2 &&
          t3 == other.t3 &&
          t4 == other.t4;

  @override
  int get hashCode => t1.hashCode ^ t2.hashCode ^ t3.hashCode ^ t4.hashCode;
}

class Tuple5<T1, T2, T3, T4, T5> {
  final T1 t1;
  final T2 t2;
  final T3 t3;
  final T4 t4;
  final T5 t5;

  Tuple5(this.t1, this.t2, this.t3, this.t4, this.t5);

  @override
  String toString() => 'Tuple[$t1, $t2, $t3, $t4, $t5]';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuple5 &&
          runtimeType == other.runtimeType &&
          t1 == other.t1 &&
          t2 == other.t2 &&
          t3 == other.t3 &&
          t4 == other.t4 &&
          t5 == other.t5;

  @override
  int get hashCode =>
      t1.hashCode ^ t2.hashCode ^ t3.hashCode ^ t4.hashCode ^ t5.hashCode;
}
