import 'package:easy_location/core/errors/application_error.dart';

base class GeolocatorServiceError extends ApplicationError {
  const GeolocatorServiceError({
    required super.message,
    required super.stackTrace,
    super.error,
  });
}

final class UnauthorizedGeolocatorServiceError extends GeolocatorServiceError {
  const UnauthorizedGeolocatorServiceError({
    required super.message,
    required super.stackTrace,
    super.error,
  });
}
