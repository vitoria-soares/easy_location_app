class Either<Failure, Success> {
  Either._(
    this._failure,
    this._success,
  );

  factory Either.failure(
    Failure failure,
  ) {
    return Either._(failure, null);
  }

  factory Either.success(
    Success success,
  ) {
    return Either._(null, success);
  }

  final Failure? _failure;
  final Success? _success;

  bool get isFailure => _failure != null;
  bool get isSuccess => _success != null;

  T fold<T>(
    T Function(Failure failure) failure,
    T Function(Success success) success,
  ) {
    if (isFailure) {
      return failure(_failure as Failure);
    } else {
      return success(_success as Success);
    }
  }

  Either<Failure, T> successMap<T>(T Function(Success success) function) {
    return fold(Either.failure, (success) => Either.success(function(success)));
  }

  Either<T, Success> failureMap<T>(T Function(Failure failure) function) {
    return fold((failure) => Either.failure(function(failure)), Either.success);
  }
}

const unit = Unit._();

final class Unit {
  const Unit._();
}

T id<T>(T value) => value;
