import 'package:easy_location/core/errors/application_error.dart';
import 'package:easy_location/core/services/geolocator/geolocator_service_error.dart';
import 'package:easy_location/core/services/geolocator/geolocator_service_interface.dart';
import 'package:easy_location/core/services/geolocator/lat_lng_dto.dart';
import 'package:easy_location/core/utils/either.dart';
import 'package:easy_location/modules/location/infra/external_interfaces/get_location_datasource_interface.dart';
import 'package:easy_location/modules/location/infra/repositories/location_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class GetLocationDatasourceMock extends Mock implements GetLocationDatasourceInterface {}

class GeolocatorServiceMock extends Mock implements GeolocatorServiceInterface {}

void main() {
  late final GetLocationDatasourceMock datasource;
  late final GeolocatorServiceMock geolocatorService;
  late final LocationRepository repository;

  setUpAll(() {
    datasource = GetLocationDatasourceMock();
    geolocatorService = GeolocatorServiceMock();
    repository = LocationRepository(
      datasource,
      geolocatorService,
    );
  });

  test(
    '[GeolocatorService] =>  Should RETURN LatLngDto WHEN call getLocation',
    () async {
      const response = LatLngDto(
        0.0,
        0.0,
      );

      localExeculte() {
        return geolocatorService.getCurrentLocation();
      }

      externalExeculte() {
        return datasource();
      }

      when(localExeculte).thenAnswer(
        (_) async => response,
      );

      final result = await repository.getLocation();

      expect(result.fold(id, id), response);
      expect(result.isSuccess, true);
      verify(localExeculte).called(1);
      verifyNever(externalExeculte);
    },
  );

  test(
    '[GeolocatorService] =>  Should RETURN UnauthorizedGeolocatorServiceError WHEN call getLocation',
    () async {
      const response = LatLngDto(
        0.0,
        0.0,
      );

      localExeculte() {
        return geolocatorService.getCurrentLocation();
      }

      externalExeculte() {
        return datasource();
      }

      when(localExeculte).thenThrow(
        UnauthorizedGeolocatorServiceError(
          message: 'UnauthorizedGeolocatorServiceError',
          stackTrace: StackTrace.current,
        ),
      );

      when(externalExeculte).thenAnswer(
        (_) async => response,
      );

      final result = await repository.getLocation();

      expect(result.fold(id, id), response);
      expect(result.isSuccess, true);
      verify(localExeculte).called(1);
      verify(externalExeculte).called(1);
    },
  );

  test(
    '[GeolocatorService] =>  Should RETURN ApplicationError WHEN call getLocation',
    () async {
      localExeculte() {
        return geolocatorService.getCurrentLocation();
      }

      externalExeculte() {
        return datasource();
      }

      when(localExeculte).thenThrow(
        ApplicationError(
          message: 'ApplicationError',
          stackTrace: StackTrace.current,
        ),
      );

      final result = await repository.getLocation();

      expect(result.fold(id, id), isA<ApplicationError>());
      expect(result.isFailure, true);
      verify(localExeculte).called(1);
      verifyNever(externalExeculte);
    },
  );

  test(
    '[GeolocatorService] =>  Should RETURN localExeculte(UnauthorizedGeolocatorServiceError) and externalExeculte(ApplicationError) WHEN call getLocation and datasource',
    () async {
      localExeculte() {
        return geolocatorService.getCurrentLocation();
      }

      externalExeculte() {
        return datasource();
      }

      when(localExeculte).thenThrow(
        UnauthorizedGeolocatorServiceError(
          message: 'UnauthorizedGeolocatorServiceError',
          stackTrace: StackTrace.current,
        ),
      );

      when(externalExeculte).thenThrow(
        ApplicationError(
          message: 'ApplicationError',
          stackTrace: StackTrace.current,
        ),
      );

      final result = await repository.getLocation();

      expect(result.fold(id, id), isA<ApplicationError>());
      expect(result.isFailure, true);
      verify(localExeculte).called(1);
      verify(externalExeculte).called(1);
    },
  );

  test(
    '[GeolocatorService] =>  Should RETURN localExeculte(UnauthorizedGeolocatorServiceError) and externalExeculte(Exception) WHEN call getLocation and datasource',
    () async {
      localExeculte() {
        return geolocatorService.getCurrentLocation();
      }

      externalExeculte() {
        return datasource();
      }

      when(localExeculte).thenThrow(
        UnauthorizedGeolocatorServiceError(
          message: 'UnauthorizedGeolocatorServiceError',
          stackTrace: StackTrace.current,
        ),
      );

      when(externalExeculte).thenThrow(
        Exception(),
      );

      final result = await repository.getLocation();

      expect(result.fold(id, id), isA<UnknowApplicationError>());
      expect(result.isFailure, true);
      verify(localExeculte).called(1);
      verify(externalExeculte).called(1);
    },
  );

  test(
    '[GeolocatorService] =>  Should RETURN UnknowApplicationError WHEN call getLocation',
    () async {
      localExeculte() {
        return geolocatorService.getCurrentLocation();
      }

      externalExeculte() {
        return datasource();
      }

      when(localExeculte).thenThrow(
        Exception(),
      );

      when(externalExeculte).thenThrow(
        Exception(),
      );

      final result = await repository.getLocation();

      expect(result.fold(id, id), isA<UnknowApplicationError>());
      expect(result.isFailure, true);
      verify(localExeculte).called(1);
      verifyNever(externalExeculte);
    },
  );
}
