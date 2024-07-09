import 'package:easy_location/core/services/geolocator/lat_lng_dto.dart';

abstract interface class GetLocationDatasourceInterface {
  Future<LatLngDto> call();
}
