import 'package:easy_location/modules/location/domain/types/location_types.dart';

abstract interface class LocationRepositoryInterface {
  Future<GetLocationResponse> getLocation();
}
