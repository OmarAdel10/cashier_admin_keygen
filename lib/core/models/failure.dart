class Failure {
  final String message;
  final String? code;
  final Object? exception;

  const Failure({
    required this.message,
    this.code,
    this.exception,
  });
}
