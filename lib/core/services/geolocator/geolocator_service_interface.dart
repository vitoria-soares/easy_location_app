import 'package:easy_location/core/services/geolocator/lat_lng_dto.dart';

abstract class GeolocatorServiceInterface {
  Future<LatLngDto> getCurrentLocation();
}
