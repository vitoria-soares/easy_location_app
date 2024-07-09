import 'package:easy_location/core/services/geolocator/lat_lng_dto.dart';
import 'package:easy_location/core/utils/serializer.dart';

final class LocationMapper implements SerializerInterface<LatLngDto> {
  @override
  LatLngDto fromMap(
    Map<String, dynamic> map,
  ) {
    return LatLngDto(
      map['lat'] as double,
      map['lon'] as double,
    );
  }

  @override
  Map<String, dynamic> toMap(
    LatLngDto object,
  ) {
    return <String, dynamic>{
      'lat': object.lat,
      'lon': object.lng,
    };
  }
}
