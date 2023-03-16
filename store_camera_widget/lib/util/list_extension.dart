
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T e) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension ListNullableExtension<T> on List<T>? {
  T? firstWhereOrNull(bool Function(T e) test) {
    final list = this;
    if(list == null) {
      return null;
    }

    for (var element in list) {
      if (test(element)) return element;
    }
    return null;
  }

  List<T>? get notEmptyList => this?.isNotEmpty == true ? this : null;

  bool get isEmptyOrNull => this?.isEmpty ?? true;

  bool get isNotEmptyAndNotNull => this?.isNotEmpty ?? false;

}

