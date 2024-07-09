import 'package:easy_location/core/services/geolocator/geolocator_service_error.dart';
import 'package:easy_location/core/services/geolocator/geolocator_service_interface.dart';
import 'package:easy_location/core/services/geolocator/lat_lng_dto.dart';
import 'package:geolocator/geolocator.dart';

/// A service that provides the current location of the device.
///  The location is provided as a latitude and longitude.

class GeolocatorService implements GeolocatorServiceInterface {
  @override
  Future<LatLngDto> getCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw GeolocatorServiceError(
          message: 'Not have permission for access location',
          stackTrace: StackTrace.current,
        );
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      final currentLocation = LatLngDto(
        position.latitude,
        position.longitude,
      );

      return currentLocation;
    } catch (e) {
      throw GeolocatorServiceError(
        message: 'Can\'t not get current location',
        stackTrace: StackTrace.current,
        error: e,
      );
    }
  }
}
