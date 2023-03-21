
extension EnumByName<T extends Enum> on Iterable<T> {
  T? tryByName(dynamic name) {
    if(name is String) {
      try {
        return byName(name);
      } catch(_) {}
    }

    return null;
  }
}
