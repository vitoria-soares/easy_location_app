import 'package:easy_location/core/errors/application_error.dart';
import 'package:easy_location/core/services/ip_verify/external_ip_verify_service_interface.dart';
import 'package:easy_location/core/services/rest/rest_client_interface.dart';

class ExternalIpVerifyService implements ExternalIpVerifyServiceInterface {
  const ExternalIpVerifyService(
    this._restClient,
  );
  final RestClient _restClient;

  @override
  Future<String> getExternalIp() async {
    try {
      final result = await _restClient<Map<String, dynamic>>(
        request: const RestClientRequest(
          method: RestClientMethod.GET,
          path: '',
          query: {
            'format': 'json'
          },
        ),
      );

      final externalIpv4 = result.data?['ip'];
      return externalIpv4;
    } catch (e) {
      throw ApplicationError(
        message: 'Can\'t not request external ip',
        stackTrace: StackTrace.current,
      );
    }
  }
}
