import 'package:easy_location/core/errors/application_error.dart';
import 'package:easy_location/core/services/geolocator/lat_lng_dto.dart';
import 'package:easy_location/core/utils/either.dart';
import 'package:easy_location/modules/location/domain/infra_interface/location_repository_interface.dart';
import 'package:easy_location/modules/location/domain/usecases/get_location_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class LocationRepositoryInterfaceMock extends Mock implements LocationRepositoryInterface {}

void main() {
  late LocationRepositoryInterfaceMock repository;
  late GetLocationUsecase usecase;

  setUp(() {
    repository = LocationRepositoryInterfaceMock();
    usecase = GetLocationUsecase(repository);
  });

  test(
    'should return a location',
    () async {
      // Arrange
      const response = LatLngDto(
        0.0,
        0.0,
      );
      when(() => repository.getLocation()).thenAnswer(
        (_) async => Either.success(
          response,
        ),
      );
      // Act
      final result = await usecase();
      // Assert
      expect(result.fold(id, id), response);
      expect(result.isSuccess, true);
      verify(() => repository.getLocation()).called(1);
    },
  );

  test(
    'should return an error',
    () async {
      // Arrange
      final error = ApplicationError(
        message: 'An error occurred',
        code: 404,
        stackTrace: StackTrace.current,
      );
      when(() => repository.getLocation()).thenAnswer(
        (_) async => Either.failure(
          error,
        ),
      );
      // Act
      final result = await usecase();
      // Assert
      expect(result.fold(id, id), error);
      expect(result.isFailure, true);
      verify(() => repository.getLocation()).called(1);
    },
  );
}
