// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:collection';

import 'package:easy_location/core/utils/serializer.dart';

import '../../errors/application_error.dart';

enum RestClientMethod {
  GET,
  POST,
  PUT,
  PATCH,
  DELETE,
}

abstract interface class RestClientInterface {
  Future<RestClientResponse<T>> call<T>({
    required RestClientRequest request,
  });
}

abstract base class RestClient implements RestClientInterface {
  const RestClient({
    required this.baseUrl,
    this.headers = const <String, dynamic>{},
    this.interceptors = const [],
  });

  final String baseUrl;
  final Map<String, dynamic> headers;
  final List<RestClientInterceptor> interceptors;

  RestClientQueueInterceptor get interceptorQueue => RestClientQueueInterceptor(
        interceptors: interceptors,
      );
}

final class RestClientResponse<T> {
  const RestClientResponse({
    required this.data,
    required this.request,
    required this.statusCode,
    required this.duration,
    this.headers = const {},
  });

  final T? data;
  final RestClientRequest request;
  final int statusCode;
  final Duration duration;
  final Map<String, dynamic> headers;

  RestClientResponse<T> copyWith({
    T? data,
    RestClientRequest? request,
    int? statusCode,
    Duration? duration,
    Map<String, dynamic>? headers,
  }) {
    return RestClientResponse<T>(
      data: data ?? this.data,
      request: request ?? this.request,
      statusCode: statusCode ?? this.statusCode,
      duration: duration ?? this.duration,
      headers: headers ?? this.headers,
    );
  }

  @override
  String toString() {
    return 'RestClientResponse(data: $data, request: $request, statusCode: $statusCode, duration: $duration)';
  }
}

final class RestResponse<T> {
  const RestResponse(
    this.response, [
    this.serializer,
  ]);

  final RestClientResponse response;
  final SerializerInterface<T>? serializer;

  T get data => serializer != null ? serializer!.fromMap(response.data as Map<String, dynamic>) : response.data as T;
}

final class RestClientRequest {
  const RestClientRequest({
    required this.method,
    required this.path,
    this.data,
    this.query,
    this.headers,
  })  : baseUrl = '',
        assert(
          method != RestClientMethod.GET || data == null,
          'GET method does not support data',
        );

  const RestClientRequest._({
    required this.method,
    required this.path,
    required this.baseUrl,
    this.data,
    this.query,
    this.headers,
  });

  factory RestClientRequest.fromRestParams({
    required RestClientMethod method,
    required String path,
    RestParamsDTO? params,
  }) {
    return RestClientRequest(
      method: method,
      path: path,
      data: params?.getBody,
      query: params?.getQuery,
      headers: params?.getHeaders,
    );
  }

  final RestClientMethod method;
  final String path;
  final String baseUrl;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? query;
  final Map<String, dynamic>? headers;

  Uri get url {
    return Uri.parse(
      baseUrl,
    );
  }

  RestClientRequest updateUrl({
    required String baseUrl,
  }) {
    return RestClientRequest._(
      method: method,
      path: path,
      baseUrl: baseUrl,
      data: data,
      query: query,
      headers: headers,
    );
  }

  RestClientRequest copyWith({
    RestClientMethod? method,
    String? path,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    String? baseUrl,
  }) {
    return RestClientRequest._(
      method: method ?? this.method,
      path: path ?? this.path,
      data: data ?? this.data,
      query: query ?? this.query,
      headers: headers ?? this.headers,
      baseUrl: baseUrl ?? this.baseUrl,
    );
  }

  @override
  String toString() {
    return 'RestClientRequest(method: $method, path: $path, data: $data, query: $query, headers: $headers)';
  }
}

abstract base class RestParamsDTO {
  const RestParamsDTO();

  List<RestParams> get query => [];
  List<RestParams> get body => [];
  List<RestParams> get headers => [];
  List<RestParams> get path => [];

  Map<String, dynamic> get getQuery {
    if (query.isEmpty) {
      return {};
    }

    final data = <String, dynamic>{};

    for (final param in query) {
      data[param.key] = param.value;
    }

    return data;
  }

  Map<String, dynamic> get getBody {
    if (body.isEmpty) {
      return {};
    }

    final data = <String, dynamic>{};

    for (final param in body) {
      data[param.key] = param.value;
    }

    return data;
  }

  Map<String, dynamic> get getHeaders {
    if (headers.isEmpty) {
      return {};
    }

    final data = <String, dynamic>{};

    for (final param in headers) {
      data[param.key] = param.value;
    }

    return data;
  }

  String getPath(String currentPath) {
    if (path.isEmpty) {
      return currentPath;
    }

    var newPath = currentPath;

    for (final param in path) {
      newPath = newPath.replaceAll(
        ':${param.key}',
        param.value.toString(),
      );
    }

    return newPath;
  }
}

final class RestParams {
  const RestParams({
    required this.key,
    required this.value,
  });

  final String key;
  final dynamic value;
}

enum InterceptorResultType {
  next,
  resolve,
  resolveCallFollowing,
  reject,
  rejectCallFollowing,
}

final class InterceptorState<T> {
  const InterceptorState(
    this.data, [
    this.type = InterceptorResultType.next,
  ]);

  final T data;
  final InterceptorResultType type;
}

sealed class _RestClientHandler {
  final _completer = Completer<InterceptorState>();
  void Function()? _processNextInQueue;

  Future<InterceptorState> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;
}

final class RestClientHandlerRequest extends _RestClientHandler {
  void next(
    RestClientRequest request,
  ) {
    _completer.complete(InterceptorState<RestClientRequest>(request));
    _processNextInQueue?.call();
  }

  void resolve<T>(
    RestClientResponse<T> response, {
    bool callFollowingResponseInterceptor = false,
  }) {
    _completer.complete(
      InterceptorState<RestClientResponse<T>>(
        response,
        callFollowingResponseInterceptor ? InterceptorResultType.resolveCallFollowing : InterceptorResultType.resolve,
      ),
    );
    _processNextInQueue?.call();
  }

  void reject(
    RestClientError error, {
    bool callFollowingErrorInterceptor = false,
  }) {
    _completer.completeError(
      InterceptorState<RestClientError>(
        error,
        callFollowingErrorInterceptor ? InterceptorResultType.rejectCallFollowing : InterceptorResultType.reject,
      ),
      error.stackTrace,
    );
    _processNextInQueue?.call();
  }
}

final class RestClientHandlerResponse extends _RestClientHandler {
  void next<T>(
    RestClientResponse<T> request,
  ) {
    _completer.complete(InterceptorState<RestClientResponse<T>>(request));
    _processNextInQueue?.call();
  }

  void resolve<T>(
    RestClientResponse<T> response, {
    bool callFollowingResponseInterceptor = false,
  }) {
    _completer.complete(
      InterceptorState<RestClientResponse<T>>(
        response,
        callFollowingResponseInterceptor ? InterceptorResultType.resolveCallFollowing : InterceptorResultType.resolve,
      ),
    );
    _processNextInQueue?.call();
  }

  void reject(
    RestClientError error, {
    bool callFollowingErrorInterceptor = false,
  }) {
    _completer.completeError(
      InterceptorState<RestClientError>(
        error,
        callFollowingErrorInterceptor ? InterceptorResultType.rejectCallFollowing : InterceptorResultType.reject,
      ),
      error.stackTrace,
    );
    _processNextInQueue?.call();
  }
}

final class RestClientHandlerError extends _RestClientHandler {
  void next(
    RestClientError request,
  ) {
    _completer.complete(InterceptorState<RestClientError>(request));
    _processNextInQueue?.call();
  }

  void resolve<T>(
    RestClientResponse<T> response, {
    bool callFollowingResponseInterceptor = false,
  }) {
    _completer.complete(
      InterceptorState<RestClientResponse<T>>(
        response,
        callFollowingResponseInterceptor ? InterceptorResultType.resolveCallFollowing : InterceptorResultType.resolve,
      ),
    );
    _processNextInQueue?.call();
  }

  void reject(
    RestClientError error, {
    bool callFollowingErrorInterceptor = false,
  }) {
    _completer.completeError(
      InterceptorState<RestClientError>(
        error,
        callFollowingErrorInterceptor ? InterceptorResultType.rejectCallFollowing : InterceptorResultType.reject,
      ),
      error.stackTrace,
    );
    _processNextInQueue?.call();
  }
}

abstract class RestClientInterceptor {
  void onRequest(
    RestClientRequest request,
    RestClientHandlerRequest handler,
  ) {
    return handler.next(request);
  }

  void onResponse<T>(
    RestClientResponse<T> response,
    RestClientHandlerResponse handler,
  ) {
    return handler.next(response);
  }

  void onError(
    RestClientError error,
    RestClientHandlerError handler,
  ) {
    return handler.next(error);
  }
}

final class RestClientQueueInterceptor {
  RestClientQueueInterceptor({
    required this.interceptors,
  }) {
    _requestQueue.addAll(interceptors.toList());
    _responseQueue.addAll(interceptors.toList());
    _errorQueue.addAll(interceptors.toList());
  }

  final List<RestClientInterceptor> interceptors;

  final _requestQueue = Queue<RestClientInterceptor>();
  final _responseQueue = Queue<RestClientInterceptor>();
  final _errorQueue = Queue<RestClientInterceptor>();

  Future<RestClientResponse<T>> resolverRequest<T>(
    RestClientRequest request,
    Future<RestClientResponse<T>> Function(RestClientRequest request) restClientRequestCallback,
  ) async {
    if (_requestQueue.isEmpty) {
      final response = await restClientRequestCallback(request);
      return response;
    } else {
      final currentTask = _requestQueue.removeFirst();
      final handler = RestClientHandlerRequest();
      // handler._processNextInQueue = () async {
      //   //
      // };

      currentTask.onRequest(
        request,
        handler,
      );

      final handler1Result = await handler.future;

      if (handler1Result.type == InterceptorResultType.resolve) {
        return handler1Result.data as RestClientResponse<T>;
      } else if (handler1Result.type == InterceptorResultType.next) {
        return resolverRequest<T>(handler1Result.data as RestClientRequest, restClientRequestCallback);
      } else {
        throw handler1Result.data as RestClientError;
      }
    }
  }

  Future<RestClientResponse<T>> resolverResponse<T>(
    RestClientResponse<T> response,
  ) async {
    if (_requestQueue.isEmpty) {
      return response;
    } else {
      final currentTask = _requestQueue.removeFirst();
      final handler = RestClientHandlerResponse();
      // handler._processNextInQueue = () async {
      //   //
      // };

      currentTask.onResponse(
        response,
        handler,
      );

      final handler1Result = await handler.future;

      if (handler1Result.type == InterceptorResultType.resolve) {
        return handler1Result.data as RestClientResponse<T>;
      } else if (handler1Result.type == InterceptorResultType.next) {
        return resolverResponse<T>(handler1Result.data as RestClientResponse<T>);
      } else {
        throw handler1Result.data as RestClientError;
      }
    }
  }

  Future<RestClientResponse<T>> resolverError<T>(
    RestClientError error,
  ) async {
    if (_requestQueue.isEmpty) {
      throw error;
    } else {
      final currentTask = _requestQueue.removeFirst();
      final handler = RestClientHandlerError();
      // handler._processNextInQueue = () async {
      //   //
      // };

      currentTask.onError(
        error,
        handler,
      );

      final handlerResult = await handler.future;

      if (handlerResult.type == InterceptorResultType.resolve) {
        return handlerResult.data as RestClientResponse<T>;
      } else if (handlerResult.type == InterceptorResultType.next) {
        return resolverError<T>(handlerResult.data as RestClientError);
      } else {
        throw handlerResult.data as RestClientError;
      }
    }
  }
}

final class RestClientError extends ApplicationError {
  RestClientError({
    required super.message,
    required super.stackTrace,
    required this.request,
    super.error,
    super.code,
  });

  final RestClientRequest request;
}
