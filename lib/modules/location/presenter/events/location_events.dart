import 'package:easy_location/modules/location/domain/params/get_location_params.dart';

base class LocationEvents {
  const LocationEvents();
}

final class GetLocationEvent extends LocationEvents {
  const GetLocationEvent(
    this.params,
  );

  final GetLocationParams params;
}
