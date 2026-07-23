import '../../features/alerts/models/daily_alert.dart';
import '../../features/charts/models/history_day.dart';
import '../../features/chuno/models/chuno_window.dart';
import '../../features/clusters/models/cluster_info.dart';
import '../../features/history/models/prediction_history_item.dart';
import '../../features/model_info/models/model_info.dart';
import '../../features/prediction/models/frost_risk_request.dart';
import '../../features/prediction/models/frost_risk_response.dart';
import '../models/current_weather.dart';
import '../models/health_status.dart';
import 'api_client.dart';

class FrostApiService {
  FrostApiService(this._client);

  final ApiClient _client;

  Future<HealthStatus> getHealth() async {
    final json = await _client.getJson('/health');
    return HealthStatus.fromJson(json);
  }

  Future<ModelInfo> getModelInfo() async {
    final json = await _client.getJson('/ml/model-info');
    return ModelInfo.fromJson(json);
  }

  Future<FrostRiskResponse> predict(FrostRiskRequest request) async {
    final json = await _client.postJson(
      '/predict/frost-risk',
      request.toJson(),
    );
    return FrostRiskResponse.fromJson(json);
  }

  Future<List<PredictionHistoryItem>> getPredictionHistory() async {
    final rows = await _client.getList('/predictions/history');
    return rows
        .whereType<Map<String, dynamic>>()
        .map(PredictionHistoryItem.fromJson)
        .toList();
  }

  Future<CurrentWeather> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final json = await _client.getJson(
      '/weather/current?latitude=$latitude&longitude=$longitude',
    );
    return CurrentWeather.fromJson(json);
  }

  Future<ClustersResult> getClusters() async {
    final json = await _client.getJson('/ml/clusters');
    return ClustersResult.fromJson(json);
  }

  Future<ChunoWindow> getChunoWindow({
    required double latitude,
    required double longitude,
  }) async {
    final json = await _client.getJson(
      '/chuno/window?latitude=$latitude&longitude=$longitude',
    );
    return ChunoWindow.fromJson(json);
  }

  Future<WeatherHistory> getWeatherHistory({
    required double latitude,
    required double longitude,
    required String start,
    required String end,
  }) async {
    final json = await _client.getJson(
      '/weather/history?latitude=$latitude&longitude=$longitude&start=$start&end=$end',
    );
    return WeatherHistory.fromJson(json);
  }

  Future<DailyAlert> getDailyAlert({
    required double latitude,
    required double longitude,
  }) async {
    final json = await _client.getJson(
      '/alerts/today?latitude=$latitude&longitude=$longitude',
    );
    return DailyAlert.fromJson(json);
  }
}
