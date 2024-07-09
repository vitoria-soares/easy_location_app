import 'package:easy_location/core/services/geolocator/lat_lng_dto.dart';
import 'package:easy_location/core/utils/app_state.dart';
import 'package:easy_location/modules/location/domain/usecases/usecase_interface/get_location_usecase_interface.dart';
import 'package:easy_location/modules/location/presenter/events/location_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class GetLocationStore extends Bloc<LocationEvents, AppState<LatLngDto>> {
  GetLocationStore(
    super.initialState,
    this._getLocationUsecase,
  ) {
    on<GetLocationEvent>(_onGetLocation);
  }

  final GetLocationUsecaseInterface _getLocationUsecase;

  Future<void> _onGetLocation(event, emitter) async {
    emitter(const LoadingAppState<LatLngDto>());

    final result = await _getLocationUsecase();

    result.fold(
      (error) {
        return emitter(ErrorAppState<LatLngDto>(error));
      },
      (data) {
        return emitter(SuccessAppState<LatLngDto>(data));
      },
    );
  }
}
