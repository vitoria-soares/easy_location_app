import 'package:easy_location/core/services/geolocator/lat_lng_dto.dart';
import 'package:easy_location/core/services/ip_verify/external_ip_verify_service_interface.dart';
import 'package:easy_location/core/services/rest/rest_client_interface.dart';
import 'package:easy_location/modules/location/external/datasources/get_location_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class RestClientMock extends Mock implements RestClientInterface {}

class ExternalIpVerifyServiceMock extends Mock implements ExternalIpVerifyServiceInterface {}

void main() {
  late final RestClientMock restClient;
  late final ExternalIpVerifyServiceMock externalIpVerifyService;
  late final GetLocationDatasource getLocationDatasource;

  setUpAll(() {
    restClient = RestClientMock();
    externalIpVerifyService = ExternalIpVerifyServiceMock();

    getLocationDatasource = GetLocationDatasource(
      restClient,
      externalIpVerifyService,
    );

    registerFallbackValue(
      const RestClientRequest(
        method: RestClientMethod.GET,
        path: 'path',
      ),
    );
  });

  test(
    '[GetLocationDatasource] => Should RETURN a LatLngDto WHEN call is successful',
    () async {
      ipExeculte() {
        return externalIpVerifyService.getExternalIp();
      }

      restExeculte() {
        return restClient<Map<String, dynamic>>(
          request: any(named: 'request'),
        );
      }

      when(ipExeculte).thenAnswer(
        (_) async => 'ExternalIp',
      );

      when(restExeculte).thenAnswer(
        (_) async => const RestClientResponse(
          data: <String, dynamic>{
            'lat': 0.0,
            'lon': 0.0,
          },
          statusCode: 200,
          request: RestClientRequest(
            method: RestClientMethod.GET,
            path: '',
          ),
          duration: Duration.zero,
        ),
      );

      final result = await getLocationDatasource();

      expect(result, isA<LatLngDto>());
      verify(restExeculte).called(1);
    },
  );
}
