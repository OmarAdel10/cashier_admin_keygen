sealed class Either<L, R> {
  const Either();

  T fold<T>(T Function(L) left, T Function(R) right) {
    return switch (this) {
      Left(l: final l) => left(l),
      Right(r: final r) => right(r),
    };
  }

  bool get isLeft => this is Left;
  bool get isRight => this is Right;
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}

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
