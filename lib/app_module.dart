import 'package:dio/dio.dart';
import 'package:easy_location/core/services/geolocator/geolocator_service.dart';
import 'package:easy_location/core/services/geolocator/geolocator_service_interface.dart';
import 'package:easy_location/core/services/geolocator/lat_lng_dto.dart';
import 'package:easy_location/core/services/ip_verify/external_ip_verify_service.dart';
import 'package:easy_location/core/services/rest/dio_rest_client.dart';
import 'package:easy_location/core/services/rest/rest_client_interface.dart';
import 'package:easy_location/core/utils/app_state.dart';
import 'package:easy_location/modules/location/domain/infra_interface/location_repository_interface.dart';
import 'package:easy_location/modules/location/domain/usecases/get_location_usecase.dart';
import 'package:easy_location/modules/location/domain/usecases/usecase_interface/get_location_usecase_interface.dart';
import 'package:easy_location/modules/location/external/datasources/get_location_datasource.dart';
import 'package:easy_location/modules/location/infra/external_interfaces/get_location_datasource_interface.dart';
import 'package:easy_location/modules/location/infra/repositories/location_repository.dart';
import 'package:easy_location/modules/location/presenter/pages/location_page.dart';
import 'package:easy_location/modules/location/presenter/store/get_location_store.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppModule implements Module {
  @override
  void binds(Injector i) {
    i.addSingleton<RestClient>(
      () {
        return DioRestClient(
          Dio(),
          baseUrl: 'https://api.ipify.org',
        );
      },
      key: 'ExternalIpVerifyService',
    );
    i.addSingleton<RestClient>(() {
      return DioRestClient(
        Dio(),
        baseUrl: 'http://ip-api.com',
      );
    });
    i.addSingleton<ExternalIpVerifyService>(() {
      return ExternalIpVerifyService(
        i(key: 'ExternalIpVerifyService'),
      );
    });

    i.addSingleton<GeolocatorServiceInterface>(GeolocatorService.new);
    i.addSingleton<GetLocationDatasourceInterface>(GetLocationDatasource.new);
    i.addSingleton<LocationRepositoryInterface>(LocationRepository.new);
    i.addSingleton<GetLocationUsecaseInterface>(GetLocationUsecase.new);
    i.addSingleton<GetLocationStore>(() {
      return GetLocationStore(
        const IdleAppState<LatLngDto>(),
        i<GetLocationUsecaseInterface>(),
      );
    });
  }

  @override
  void exportedBinds(Injector i) {}

  @override
  List<Module> get imports => [];

  @override
  void routes(RouteManager r) {
    r.add(
      ChildRoute(
        '/',
        child: (context) => LatLngToScreenPointPage(
          locationStore: Modular.get<GetLocationStore>(),
        ),
      ),
    );
  }
}
