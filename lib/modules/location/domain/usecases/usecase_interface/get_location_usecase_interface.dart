import 'package:easy_location/modules/location/domain/types/location_types.dart';

abstract class GetLocationUsecaseInterface {
  Future<GetLocationResponse> call();
}
