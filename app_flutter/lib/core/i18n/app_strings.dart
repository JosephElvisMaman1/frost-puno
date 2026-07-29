import '../settings/user_settings.dart';
import 'app_language.dart';

/// Textos de la interfaz en español/inglés. Español por defecto; el modo inglés
/// se usa en la exposición (rúbrica: "Funcionamiento de la aplicación en inglés").
///
/// Uso: `AppStrings.current.<clave>`. Como `MaterialApp` se reconstruye al cambiar
/// `UserSettings.language`, las pantallas leen siempre el idioma vigente.
class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  static AppStrings get current => AppStrings(UserSettings.instance.language);

  bool get _en => language.isEn;
  String _t(String es, String en) => _en ? en : es;

  // --- Navegación (shell) ---
  String get tabHome => _t('Inicio', 'Home');
  String get tabZones => _t('Zonas', 'Zones');
  String get tabChuno => _t('Chuño', 'Chuño');
  String get tabWeather => _t('Clima', 'Weather');
  String get tabHistory => _t('Historial', 'History');

  // --- Home ---
  String get systemActive => _t('Sistema activo', 'System active');
  String get demoMode => _t('Modo demo', 'Demo mode');
  String get changeTheme => _t('Cambiar tema', 'Change theme');
  String get settings => _t('Ajustes', 'Settings');
  String get appTagline => _t(
    'Prediccion inteligente de heladas para comunidades altoandinas.',
    'Smart frost prediction for high-Andean communities.',
  );
  String get checkRisk => _t('Consultar riesgo', 'Check risk');
  String get viewHistory => _t('Ver historial', 'View history');
  String get dataSources => _t('Fuentes de datos', 'Data sources');
  String get modelInfo => _t('Informacion del modelo', 'Model information');
  String get currentFrostRisk =>
      _t('Riesgo actual de helada', 'Current frost risk');
  String humShort(String v) => _t('Hum $v', 'Hum $v');
  String get maintenanceTitle =>
      _t('Mantenimiento del modelo', 'Model maintenance');
  String get maintenanceBody => _t(
    'El modelo se reentrena de forma programada, registra métricas y solo se promueve si supera el quality gate de silhouette.',
    'The model is retrained on a schedule, logs metrics, and is promoted only if it clears the silhouette quality gate.',
  );

  // --- Tarjetas de alerta (generadas desde campos, localizadas) ---
  String frostTitle(String severity) => switch (severity) {
    'fuerte' => _t('Riesgo de helada fuerte', 'Strong frost risk'),
    'moderada' => _t('Riesgo de helada moderada', 'Moderate frost risk'),
    _ => _t('Sin alerta de helada', 'No frost alert'),
  };
  String frostMessage(String severity) => switch (severity) {
    'fuerte' => _t(
      'Hoy hay riesgo de helada fuerte. Resguarde el ganado y proteja los cultivos.',
      'Strong frost risk today. Shelter livestock and protect crops.',
    ),
    'moderada' => _t(
      'Hoy hay riesgo de helada moderada. Monitoree la temperatura nocturna.',
      'Moderate frost risk today. Monitor the overnight temperature.',
    ),
    _ => _t(
      'No se prevé helada significativa para hoy.',
      'No significant frost expected today.',
    ),
  };
  String livestockTitle(String level) =>
      _t('Ganado · riesgo $level', '${_livestockLevelEn(level)} livestock risk');
  String _livestockLevelEn(String level) => switch (level) {
    'alto' => 'High',
    'medio' => 'Medium',
    _ => 'Low',
  };
  String livestockMessage(String level) => switch (level) {
    'alto' => _t(
      'Riesgo alto para el ganado: proteja crías de alpaca y ovino esta noche.',
      'High livestock risk: protect alpaca and sheep newborns tonight.',
    ),
    'medio' => _t(
      'Riesgo medio: abrigue a las crías y revise cobertizos antes del anochecer.',
      'Medium risk: shelter the young and check pens before nightfall.',
    ),
    _ => _t(
      'Sin riesgo relevante para el ganado esta noche.',
      'No relevant livestock risk tonight.',
    ),
  };
  String get anomalyTitle => _t('Riesgo inusual', 'Unusual risk');
  String anomalyMessage(double? delta) {
    if (delta == null) {
      return _t('Temperatura dentro de lo normal.', 'Temperature within normal range.');
    }
    final d = delta.abs().toStringAsFixed(1);
    return _t(
      'Helada inusual: $d °C por debajo de lo normal para estas fechas.',
      'Unusual frost: $d °C below normal for this time of year.',
    );
  }

  // --- Zonas / clusters ---
  String get zonesTitle => _t('Zonas de riesgo', 'Risk zones');
  String get zonesSubtitle => _t(
    'Distritos de Puno agrupados por K-Means segun su regimen termico.',
    'Puno districts grouped by K-Means according to their thermal regime.',
  );
  String get clusters => _t('Clusters', 'Clusters');
  String get silhouette => _t('Silhouette', 'Silhouette');
  String get model => _t('Modelo', 'Model');
  String get districtsByLevel => _t('Distritos por nivel', 'Districts by level');
  String coldShare(String v) => _t('frio $v', 'cold $v');
  String get zonesError =>
      _t('No se pudieron cargar las zonas.', 'Could not load the zones.');

  // --- Chuño ---
  String get chunoTitle => _t('Modulo chuño', 'Chuño module');
  String get chunoSubtitle => _t(
    'Ventanas de congelamiento nocturno y secado diurno para elaborar chuño.',
    'Overnight freezing and daytime drying windows to make chuño.',
  );
  String get dailyForecast => _t('Pronostico diario', 'Daily forecast');
  String get optimalWindow => _t('Ventana optima', 'Optimal window');
  String get inSeason => _t('En temporada', 'In season');
  String get offSeason => _t('Fuera de temporada', 'Off season');
  String streak(int d) => _t('Racha ${d}d', 'Streak ${d}d');
  String chunoDayMetrics(String min, String clouds, String hum) => _t(
    'min $min °C · nubes $clouds% · hum $hum%',
    'min $min °C · clouds $clouds% · hum $hum%',
  );
  String get chunoError =>
      _t('No se pudo cargar el modulo de chuño.', 'Could not load the chuño module.');

  // --- Clima histórico ---
  String get weatherTitle => _t('Clima historico', 'Weather history');
  String get weatherSubtitle => _t(
    'Temperaturas minimas/maximas y humedad de los ultimos 30 dias (Open-Meteo Archive).',
    'Min/max temperature and humidity for the last 30 days (Open-Meteo Archive).',
  );
  String get temperatureC => _t('Temperatura (°C)', 'Temperature (°C)');
  String get minLabel => _t('Minima', 'Min');
  String get maxLabel => _t('Maxima', 'Max');
  String get relativeHumidity =>
      _t('Humedad relativa (%)', 'Relative humidity (%)');
  String get weatherError =>
      _t('No se pudo cargar el clima historico.', 'Could not load weather history.');

  // --- Historial ---
  String get historyTitle => _t('Historial', 'History');
  String get historySubtitle => _t(
    'Consultas guardadas con distrito, riesgo y confianza.',
    'Saved queries with district, risk and confidence.',
  );
  String riskChip(String level) =>
      _t('Riesgo ${_cap(level)}', '${riskWord(level)} risk');
  String get confidence => _t('CONFIANZA', 'CONFIDENCE');
  String get date => _t('FECHA', 'DATE');
  String get historyError => _t(
    'No se pudo cargar el historial desde FastAPI.',
    'Could not load history from FastAPI.',
  );
  String get historyEmpty => _t(
    'Aun no hay predicciones guardadas. Con Supabase apagado, FastAPI devuelve una lista vacia.',
    'No saved predictions yet. With Supabase off, FastAPI returns an empty list.',
  );

  // --- Fuentes de datos ---
  String get sourcesTitle => _t('Fuentes de datos', 'Data sources');
  String get sourcesSubtitle => _t(
    'Referencias y origenes de la informacion analizada por el sistema.',
    'References and origins of the data analyzed by the system.',
  );
  String get sourceOpenMeteo => _t(
    'Fuente climatica global usada como respaldo operativo cuando SENAMHI no entrega datos disponibles para el MVP.',
    'Global weather source used as an operational fallback when SENAMHI has no data available for the MVP.',
  );
  String get sourceInei => _t(
    'Fuente territorial, censal y agropecuaria para ubigeos, distritos, ruralidad y contexto local.',
    'Territorial, census and agricultural source for districts, rurality and local context.',
  );
  String get sourceSenamhi => _t(
    'Fuente oficial peruana prioritaria para estaciones, avisos, validacion y futura calibracion climatica.',
    'Prioritized official Peruvian source for stations, advisories, validation and future calibration.',
  );
  String get sourceMidagri => _t(
    'Fuente agricola complementaria para produccion, cultivos relevantes e impacto productivo.',
    'Complementary agricultural source for production, relevant crops and productive impact.',
  );
  String get sourcesFooter => _t(
    'SENAMHI se prioriza como fuente oficial; si no hay datos operativos disponibles, FrostPuno usa Open-Meteo como fallback.',
    'SENAMHI is prioritized as the official source; when no operational data is available, FrostPuno falls back to Open-Meteo.',
  );
  String get improvementCycle =>
      _t('Ciclo de mejora del modelo', 'Model improvement cycle');
  List<(String, String, String)> get pipelineSteps => _en
      ? const [
          ('1', 'Current weather', 'Open-Meteo feeds the app in real time.'),
          ('2', 'SENAMHI', 'Official observations validate real events.'),
          ('3', 'Feedback', 'Supabase stores corrections and field evidence.'),
          ('4', 'New model', 'ML compares versions before promoting.'),
        ]
      : const [
          ('1', 'Clima actual', 'Open-Meteo alimenta la app en tiempo real.'),
          ('2', 'SENAMHI', 'Observaciones oficiales validan eventos reales.'),
          ('3', 'Feedback', 'Supabase guarda correcciones y evidencia de campo.'),
          ('4', 'Nuevo modelo', 'ML compara versiones antes de promover.'),
        ];
  String get pipelineFooter => _t(
    'Este flujo evita entrenar automaticamente con datos dudosos y mantiene trazabilidad academica.',
    'This flow avoids auto-training on doubtful data and keeps academic traceability.',
  );

  // --- Ajustes ---
  String get settingsSubtitle => _t(
    'Configura tus alarmas de helada y el perfil con el que usas la app.',
    'Set your frost alarms and the profile you use the app with.',
  );
  String get enableAlerts =>
      _t('Activar alertas de helada', 'Enable frost alerts');
  String get enableAlertsSub => _t(
    'Muestra el aviso en Inicio y envía notificación en el celular.',
    'Shows the banner on Home and sends a phone notification.',
  );
  String alertThresholdLabel(String c) => _t(
    'Avisarme si la mínima baja de $c °C',
    'Alert me if the low drops below $c °C',
  );
  String get profile => _t('Perfil', 'Profile');
  String get profileHint =>
      _t('Prioriza qué alertas ves en Inicio.', 'Prioritizes which alerts you see on Home.');
  String get languageLabel => _t('Idioma', 'Language');
  String profileName(String key) => switch (key) {
    'general' => _t('General', 'General'),
    'agricultor' => _t('Agricultor', 'Farmer'),
    'ganadero' => _t('Ganadero', 'Herder'),
    _ => _t('Chuñero', 'Chuño maker'),
  };

  // --- Model info ---
  String get modelInfoTitle => _t('Informacion del modelo', 'Model information');
  String get modelInfoSubtitle => _t(
    'Especificaciones tecnicas y metricas del modelo no supervisado (clustering) en produccion.',
    'Technical specs and metrics of the unsupervised (clustering) model in production.',
  );
  String get baseArchitecture => _t('ARQUITECTURA BASE', 'BASE ARCHITECTURE');
  String get chipClustering => _t('Clustering', 'Clustering');
  String get chipUnsupervised => _t('No supervisado', 'Unsupervised');
  String get mainMetric => _t('METRICA PRINCIPAL', 'MAIN METRIC');
  String get silhouetteDesc => _t(
    'Cohesion y separacion de los grupos climaticos (0 a 1, mas alto es mejor).',
    'Cohesion and separation of the climate groups (0 to 1, higher is better).',
  );
  String get riskGroups => _t('GRUPOS DE RIESGO', 'RISK GROUPS');
  String get clustersUnit => _t('clusters', 'clusters');
  String get clustersDesc => _t(
    'Regimenes climaticos agrupados por K-Means y mapeados a alto/medio/bajo.',
    'Climate regimes grouped by K-Means and mapped to high/medium/low.',
  );
  String get datasetSize => _t('DATASET SIZE', 'DATASET SIZE');
  String get samples => _t('muestras', 'samples');
  String get datasetDesc => _t(
    'Registros generados desde Open-Meteo y contexto territorial inicial.',
    'Records generated from Open-Meteo and initial territorial context.',
  );
  String get versionStatus => _t('VERSION Y ESTADO', 'VERSION & STATUS');
  String get qualityGateApproved =>
      _t('Quality Gate: Aprobado', 'Quality Gate: Passed');
  String get modelInfoError => _t(
    'No se pudo cargar informacion del modelo.',
    'Could not load model information.',
  );

  // --- Predicción (form) ---
  String get frostRiskTitle => _t('Riesgo de helada', 'Frost risk');
  String get frostRiskSubtitle => _t(
    'Ubicacion y clima se obtienen automaticamente para enviar una prediccion lista para campo.',
    'Location and weather are fetched automatically to send a field-ready prediction.',
  );
  String get location => _t('Ubicacion', 'Location');
  String get detectedLocation => _t('Ubicacion detectada', 'Detected location');
  String get punoDemo => _t('Puno demo', 'Puno demo');
  String get locationHint => _t(
    'Usa GPS para detectar tu ubicacion. Si falla, FrostPuno conserva Puno como fallback manual.',
    'Use GPS to detect your location. If it fails, FrostPuno keeps Puno as a manual fallback.',
  );
  String get useMyLocation => _t('Usar mi ubicacion', 'Use my location');
  String get detectingLocation =>
      _t('Detectando ubicacion...', 'Detecting location...');
  String get currentWeather => _t('Clima actual', 'Current weather');
  String get humidity => _t('Humedad', 'Humidity');
  String get wind => _t('Viento', 'Wind');
  String get clouds => _t('Nubes', 'Clouds');
  String get weatherHint => _t(
    'El clima se llenara automaticamente desde FastAPI cuando obtengas tu ubicacion o pulses Obtener clima.',
    'Weather auto-fills from FastAPI once you get your location or tap Get weather.',
  );
  String get getWeather => _t('Obtener clima', 'Get weather');
  String get gettingWeather => _t('Obteniendo clima...', 'Getting weather...');
  String get readyToPredict => _t('Listo para predecir', 'Ready to predict');
  String get readyToPredictBody => _t(
    'FrostPuno enviara ubicacion, clima actual y contexto agricola interno al modelo.',
    'FrostPuno will send location, current weather and internal agricultural context to the model.',
  );
  String get predict => _t('Predecir', 'Predict');
  String get predicting => _t('Prediciendo...', 'Predicting...');
  String get internalDemoValue => _t('Valor demo interno', 'Internal demo value');
  String feelsLike(String c) => _t('Sensacion $c C', 'Feels like $c C');
  String connectError(Object e) =>
      _t('No se pudo conectar con FastAPI: $e', 'Could not reach FastAPI: $e');
  String get requestingGps =>
      _t('Solicitando permiso y leyendo GPS...', 'Requesting permission and reading GPS...');
  String get waitingLocation => _t(
    'Esperando ubicacion para consultar clima actual.',
    'Waiting for location to fetch current weather.',
  );
  String gpsAccuracy(bool lastKnown, String meters) => _t(
    '${lastKnown ? 'Ultima ubicacion conocida' : 'GPS detectado'} con precision aprox. $meters m.',
    '${lastKnown ? 'Last known location' : 'GPS detected'} with approx. $meters m accuracy.',
  );
  String locationFailed(String detail) => _t(
    '$detail Fallback manual activo: Puno demo.',
    '$detail Manual fallback active: Puno demo.',
  );
  String get locationFailedGeneric => _t(
    'No se pudo obtener ubicacion. Fallback manual activo: Puno demo.',
    'Could not get location. Manual fallback active: Puno demo.',
  );
  String get tapGetWeatherDemo => _t(
    'Puedes pulsar Obtener clima para usar el punto demo de Puno.',
    'Tap Get weather to use the Puno demo point.',
  );
  String get queryingWeather =>
      _t('Consultando GET /weather/current...', 'Calling GET /weather/current...');
  String weatherUpdated(String provider, bool fallback) => _t(
    'Clima actualizado via $provider${fallback ? ' con fallback' : ''}.',
    'Weather updated via $provider${fallback ? ' with fallback' : ''}.',
  );
  String weatherFailed(Object e) => _t(
    'No se pudo obtener clima actual. Se conservan valores demo internos. Detalle: $e',
    'Could not get current weather. Internal demo values kept. Detail: $e',
  );
  String detail(Object e) => _t('Detalle: $e', 'Detail: $e');

  // --- Resultado ---
  String get resultTitle => _t('Resultado', 'Result');
  String get resultSubtitle => _t(
    'Lectura clara para decidir acciones en campo.',
    'Clear read to decide field actions.',
  );
  String get riskLabel => _t('RIESGO', 'RISK');
  String get recommendationFallback => _t(
    'Revisar condiciones locales y monitorear cambios de temperatura.',
    'Review local conditions and monitor temperature changes.',
  );
  String get chunoConditionLabel =>
      _t('CONDICION PARA CHUNO', 'CHUÑO CONDITION');

  /// La API responde en español; en modo inglés se rotula por nivel de riesgo.
  String recommendation(String riskLevel, String backendText) {
    if (!_en) {
      return backendText.trim().isEmpty ? recommendationFallback : backendText;
    }
    return switch (riskLevel.toLowerCase()) {
      'alto' =>
        'High frost risk: shelter livestock and cover crops before nightfall.',
      'medio' || 'moderado' =>
        'Moderate risk: monitor the overnight temperature and prepare protection.',
      _ => 'Low risk: keep routine monitoring for sudden changes.',
    };
  }
  String get summary => _t('RESUMEN', 'SUMMARY');
  String get district => _t('Distrito', 'District');
  String get newQuery => _t('Nueva consulta', 'New query');
  String chunoCondition(String value) => switch (value) {
    'favorables' => _t('Favorable', 'Favorable'),
    'posibles' => _t('Posible', 'Possible'),
    _ => _t('No favorable', 'Unfavorable'),
  };

  // --- Palabras de riesgo (para chips en mayúscula) ---
  String riskWord(String level) => switch (level.toLowerCase()) {
    'alto' => _t('Alto', 'High'),
    'medio' || 'moderado' => _t('Medio', 'Medium'),
    _ => _t('Bajo', 'Low'),
  };
  String tierWord(String tier) => switch (tier.toLowerCase()) {
    'alto' => _t('ALTO', 'HIGH'),
    'medio' => _t('MEDIO', 'MEDIUM'),
    'excelente' => _t('EXCELENTE', 'EXCELLENT'),
    'bueno' => _t('BUENO', 'GOOD'),
    'marginal' => _t('MARGINAL', 'MARGINAL'),
    _ => _t('BAJO', 'LOW'),
  };

  static String _cap(String v) =>
      v.isEmpty ? v : '${v[0].toUpperCase()}${v.substring(1)}';
}
