import 'package:easy_location/modules/location/domain/infra_interface/location_repository_interface.dart';
import 'package:easy_location/modules/location/domain/types/location_types.dart';
import 'package:easy_location/modules/location/domain/usecases/usecase_interface/get_location_usecase_interface.dart';

class GetLocationUsecase implements GetLocationUsecaseInterface {
  const GetLocationUsecase(
    this._repository,
  );

  final LocationRepositoryInterface _repository;

  @override
  Future<GetLocationResponse> call() async {
    final result = await _repository.getLocation();

    return result;
  }
}
