import 'package:easy_location/core/errors/application_error.dart';

sealed class AppState<T> {
  const AppState();

  R when<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(ApplicationError error) error,
  }) {
    if (this is IdleAppState<T>) {
      return idle();
    } else if (this is LoadingAppState<T>) {
      return loading();
    } else if (this is SuccessAppState<T>) {
      return success((this as SuccessAppState<T>).data);
    } else if (this is ErrorAppState<T>) {
      return error((this as ErrorAppState<T>).error);
    } else {
      throw AssertionError();
    }
  }

  SuccessAppState<T>? foldSuccess() {
    if (this is SuccessAppState<T>) {
      return this as SuccessAppState<T>;
    } else {
      return null;
    }
  }

  void whenSuccess(void Function(T data) success) {
    if (this is SuccessAppState<T>) {
      success((this as SuccessAppState<T>).data);
    }
  }

  void whenNonSuccess(void Function() nonSuccess) {
    if (this is! SuccessAppState<T>) {
      nonSuccess();
    }
  }

  void whenError(void Function(ApplicationError error) error) {
    if (this is ErrorAppState<T>) {
      error((this as ErrorAppState<T>).error);
    }
  }
}

final class IdleAppState<T> extends AppState<T> {
  const IdleAppState();
}

final class LoadingAppState<T> extends AppState<T> {
  const LoadingAppState();
}

final class SuccessAppState<T> extends AppState<T> {
  const SuccessAppState(this.data);
  final T data;
}

final class LoadingMoreAppState<T> extends SuccessAppState<T> {
  const LoadingMoreAppState(super.data);
}

final class ErrorAppState<T> extends AppState<T> {
  const ErrorAppState(this.error);
  final ApplicationError error;
}
