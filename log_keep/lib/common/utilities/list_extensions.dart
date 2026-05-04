extension ListExtension<T> on List<T> {
  T? getValueOrNull(int index) {
    if (index < 0 || index >= length) {
      return null;
    }
    return this[index];
  }
}
