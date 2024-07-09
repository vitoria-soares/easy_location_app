base class ApplicationError implements Exception {
  const ApplicationError({
    required this.message,
    required this.stackTrace,
    this.error,
    this.code = 0,
  });

  final String message;
  final StackTrace stackTrace;
  final Object? error;
  final int code;

  @override
  String toString() {
    return 'ApplicationError{message: $message, stackTrace: $stackTrace, error: $error, code: $code}';
  }
}

final class UnknowApplicationError extends ApplicationError {
  UnknowApplicationError({
    required super.message,
    required super.stackTrace,
    super.error,
  });
}
