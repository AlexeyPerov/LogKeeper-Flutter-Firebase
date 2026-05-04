extension MapExtension<K, V> on Map<K, V> {
  V getValueOrDefault(K key, V defaultValue) {
    if (!containsKey(key)) {
      return defaultValue;
    }
    final value = this[key];
    if (value == null) {
      return defaultValue;
    }
    return value;
  }
}
