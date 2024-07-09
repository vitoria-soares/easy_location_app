import 'package:easy_location/core/services/geolocator/lat_lng_dto.dart';
import 'package:easy_location/core/services/ip_verify/external_ip_verify_service_interface.dart';
import 'package:easy_location/core/services/rest/rest_client_interface.dart';
import 'package:easy_location/modules/location/external/mappers/location_mapper.dart';
import 'package:easy_location/modules/location/infra/external_interfaces/get_location_datasource_interface.dart';

final class GetLocationDatasource implements GetLocationDatasourceInterface {
  const GetLocationDatasource(
    this._restClient,
    this._externalIpVerifyService,
  );

  final RestClientInterface _restClient;
  final ExternalIpVerifyServiceInterface _externalIpVerifyService;

  @override
  Future<LatLngDto> call() async {
    final ipv4 = await _externalIpVerifyService.getExternalIp();

    final result = await _restClient<Map<String, dynamic>>(
      request: RestClientRequest(
        method: RestClientMethod.GET,
        path: '/json/$ipv4',
      ),
    );

    return LocationMapper().fromMap(
      result.data ?? <String, dynamic>{},
    );
  }
}
