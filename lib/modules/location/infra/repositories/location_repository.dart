import 'package:easy_location/core/errors/application_error.dart';
import 'package:easy_location/core/services/geolocator/geolocator_service_error.dart';
import 'package:easy_location/core/services/geolocator/geolocator_service_interface.dart';
import 'package:easy_location/core/utils/either.dart';
import 'package:easy_location/modules/location/domain/infra_interface/location_repository_interface.dart';
import 'package:easy_location/modules/location/domain/types/location_types.dart';
import 'package:easy_location/modules/location/infra/external_interfaces/get_location_datasource_interface.dart';

final class LocationRepository implements LocationRepositoryInterface {
  const LocationRepository(
    this._datasource,
    this._geolocatorService,
  );

  final GetLocationDatasourceInterface _datasource;
  final GeolocatorServiceInterface _geolocatorService;

  @override
  Future<GetLocationResponse> getLocation() async {
    try {
      final localGeolocation = await _geolocatorService.getCurrentLocation();
      return Either.success(localGeolocation);
    } on UnauthorizedGeolocatorServiceError catch (_) {
      try {
        final result = await _datasource();
        return Either.success(result);
      } on ApplicationError catch (e) {
        return Either.failure(e);
      } catch (e) {
        return Either.failure(
          UnknowApplicationError(
            message: 'An unexpected error occurred',
            stackTrace: StackTrace.current,
          ),
        );
      }
    } on ApplicationError catch (e) {
      return Either.failure(e);
    } catch (e) {
      return Either.failure(
        UnknowApplicationError(
          message: 'An unexpected error occurred',
          stackTrace: StackTrace.current,
        ),
      );
    }
  }
}
