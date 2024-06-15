extension CustomStringExtensions on String {
  String get customCapitalizeFirst {
    if (this.isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}
