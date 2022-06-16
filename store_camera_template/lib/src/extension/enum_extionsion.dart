
extension EnumByName<T extends Enum> on Iterable<T> {
  T? tryByName(String? name) {
    if(name != null) {
      try {
        return byName(name);
      } catch(_) {}
    }

    return null;
  }
}
