abstract class Failure {
  final String message;

  Failure(this.message);
}

class GenericFailure extends Failure {
  GenericFailure(String message) : super(message);
}
