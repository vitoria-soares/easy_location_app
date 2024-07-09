import 'dart:async';

import 'package:dio/dio.dart';

import 'rest_client_interface.dart';

final class DioRestClient extends RestClient {
  const DioRestClient(
    this._dio, {
    required super.baseUrl,
    super.headers = const {},
    super.interceptors,
  });

  final Dio _dio;

  @override
  Future<RestClientResponse<T>> call<T>({
    required RestClientRequest request,
  }) async {
    final updatedRequest = request.updateUrl(baseUrl: baseUrl);

    try {
      final requestResolver = await interceptorQueue.resolverRequest<T>(updatedRequest, (request) async {
        final timer = Stopwatch()..start();

        final dioResponse = await _dio.request<T>(
          baseUrl + request.path,
          data: request.data,
          queryParameters: request.query,
          options: Options(
            method: request.method.name,
            headers: {
              ...headers,
              ...?request.headers,
            },
          ),
        );

        final response = RestClientResponse<T>(
          data: dioResponse.data,
          statusCode: dioResponse.statusCode ?? 0,
          duration: timer.elapsed,
          request: request,
          headers: dioResponse.headers.map,
        );

        timer.stop();

        if (response.statusCode < 200 || response.statusCode > 299) {
          final error = RestClientError(
            message: 'Código fora da faixa 200',
            code: response.statusCode,
            error: dioResponse,
            stackTrace: StackTrace.current,
            request: request,
          );

          throw error;
        }

        return response;
      });

      final responseResolver = await interceptorQueue.resolverResponse<T>(requestResolver);

      return responseResolver;
    } on RestClientError catch (error) {
      final errorResolver = await interceptorQueue.resolverError<T>(error);
      return errorResolver;
    } on DioException catch (e) {
      final error = RestClientError(
        message: () {
          final data = e.response?.data;
          if (data != null && data is Map<String, dynamic>) {
            final errorType = data['type'] as String? ?? '';
            return _errorTranscript(errorType);
          } else {
            return e.message ?? '';
          }
        }(),
        code: e.response?.statusCode ?? 0,
        error: e,
        stackTrace: e.stackTrace,
        request: updatedRequest,
      );
      final errorResolver = await interceptorQueue.resolverError<T>(error);
      return errorResolver;
    }
  }
}

String _errorTranscript(String errorType) {
  return switch (errorType) {
    'user_invalid_credentials' => 'Usuário ou senha inválidos',
    'general_unauthorized_scope' => 'Usuário não autorizado',
    'database_not_found' => 'Registro não encontrado',
    _ => 'Erro desconhecido',
  };
}
