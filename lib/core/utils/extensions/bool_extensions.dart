extension BoolExtensions on bool {
  int compareTo(bool other) {
    return (this ? 1 : 0) - (other ? 1 : 0);
  }
}
