import '../models/service_provider.dart';
import '../network/services/network_helper.dart';
import 'repository_helpers.dart';

class ServiceProviderRepository {
  ServiceProviderRepository({NetworkHelper? networkHelper})
    : _networkHelper = networkHelper ?? NetworkHelper();

  final NetworkHelper _networkHelper;

  Future<List<ServiceProvider>> fetchServiceProviders() async {
    final json = await _networkHelper.get('ServiceProvider');
    return ServiceProvider.fromJsonList(asJsonList(json['items']));
  }

  Future<List<ActiveServiceProvider>> fetchActiveServiceProviders() async {
    final items = await _networkHelper.getList('ServiceProvider/active');
    return ActiveServiceProvider.fromJsonList(items);
  }

  Future<ServiceProvider> fetchServiceProviderById(String id) async {
    final json = await _networkHelper.get(
      'ServiceProvider/serviceProvider/$id',
    );
    return ServiceProvider.fromJson(json);
  }
}
