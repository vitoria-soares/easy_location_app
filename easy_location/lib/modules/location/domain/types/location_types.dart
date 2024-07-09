import 'package:easy_location/core/errors/application_error.dart';
import 'package:easy_location/core/services/geolocator/lat_lng_dto.dart';
import 'package:easy_location/core/utils/either.dart';

typedef GetLocationResponse = Either<ApplicationError, LatLngDto>;
