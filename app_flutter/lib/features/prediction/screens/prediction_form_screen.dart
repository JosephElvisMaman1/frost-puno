import 'package:flutter/material.dart';

import '../../../core/api/frost_api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/primary_action_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/frost_risk_request.dart';
import 'result_screen.dart';

class PredictionFormScreen extends StatefulWidget {
  const PredictionFormScreen({required this.apiService, super.key});

  final FrostApiService apiService;

  @override
  State<PredictionFormScreen> createState() => _PredictionFormScreenState();
}

class _PredictionFormScreenState extends State<PredictionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _demo = FrostRiskRequest.demo();
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _seedControllers();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          children: [
            const SectionHeader(
              title: 'Consulta de riesgo de helada',
              subtitle:
                  'Ingrese los parametros territoriales y climaticos para ejecutar el modelo predictivo.',
            ),
            const SizedBox(height: 32),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardTitle(
                    icon: Icons.my_location,
                    label: 'Parametros Territoriales',
                  ),
                  const SizedBox(height: 18),
                  _textInput('district', 'Distrito'),
                  _textInput('province', 'Provincia'),
                  _textInput('populatedCenter', 'Centro poblado'),
                  Row(
                    children: [
                      Expanded(child: _numberInput('latitude', 'Latitud')),
                      const SizedBox(width: 16),
                      Expanded(child: _numberInput('longitude', 'Longitud')),
                    ],
                  ),
                  _numberInput('altitude', 'Altitud msnm'),
                  _numberInput('ruralPopulation', 'Poblacion rural'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardTitle(
                    icon: Icons.device_thermostat,
                    label: 'Variables Climaticas',
                  ),
                  const SizedBox(height: 18),
                  _twoColumns([
                    _numberInput('temperatureMin', 'T. minima C'),
                    _numberInput('temperatureMax', 'T. maxima C'),
                    _numberInput('feelsLike', 'Sensacion C'),
                    _numberInput('humidity', 'Humedad %'),
                    _numberInput('windSpeed', 'Viento km/h'),
                    _numberInput('cloudCover', 'Nubosidad %'),
                    _numberInput('dewPoint', 'Pt. rocio C'),
                    _numberInput('precipitation', 'Precipitacion mm'),
                    _numberInput('hoursBelowZero', 'Hrs < 0 C'),
                    _numberInput('month', 'Mes'),
                    _numberInput('hour', 'Hora'),
                  ]),
                  const SizedBox(height: 12),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusChip(
                        icon: Icons.info_outline,
                        label: 'Datos del modelo GFS',
                      ),
                      StatusChip(icon: Icons.refresh, label: 'Act. demo local'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            PrimaryActionButton(
              label: _isLoading ? 'Prediciendo...' : 'Predecir riesgo',
              icon: Icons.analytics_outlined,
              onPressed: _isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  void _seedControllers() {
    final values = <String, String>{
      'district': _demo.district,
      'province': _demo.province,
      'populatedCenter': _demo.populatedCenter,
      'latitude': _demo.latitude.toString(),
      'longitude': _demo.longitude.toString(),
      'altitude': _demo.altitude.toString(),
      'ruralPopulation': _demo.ruralPopulation.toString(),
      'temperatureMin': _demo.temperatureMin.toString(),
      'temperatureMax': _demo.temperatureMax.toString(),
      'feelsLike': _demo.feelsLike.toString(),
      'humidity': _demo.humidity.toString(),
      'windSpeed': _demo.windSpeed.toString(),
      'cloudCover': _demo.cloudCover.toString(),
      'dewPoint': _demo.dewPoint.toString(),
      'precipitation': _demo.precipitation.toString(),
      'hoursBelowZero': _demo.hoursBelowZero.toString(),
      'month': _demo.month.toString(),
      'hour': _demo.hour.toString(),
    };
    values.forEach(
      (key, value) => _controllers[key] = TextEditingController(text: value),
    );
  }

  Widget _twoColumns(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 460) {
          return Column(children: children);
        }
        final rows = <Widget>[];
        for (var index = 0; index < children.length; index += 2) {
          rows.add(
            Row(
              children: [
                Expanded(child: children[index]),
                const SizedBox(width: 18),
                if (index + 1 < children.length)
                  Expanded(child: children[index + 1])
                else
                  const Spacer(),
              ],
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }

  Widget _textInput(String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _controllers[key],
        textInputAction: TextInputAction.next,
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Requerido' : null,
        decoration: InputDecoration(labelText: label.toUpperCase()),
      ),
    );
  }

  Widget _numberInput(String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        textInputAction: TextInputAction.next,
        validator: (value) =>
            double.tryParse(value ?? '') == null ? 'Numero requerido' : null,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(labelText: label.toUpperCase()),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final request = _buildRequest();
      final response = await widget.apiService.predict(request);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(request: request, response: response),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo conectar con FastAPI: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  FrostRiskRequest _buildRequest() {
    double n(String key) => double.parse(_controllers[key]!.text);
    int i(String key) => double.parse(_controllers[key]!.text).round();
    return FrostRiskRequest(
      district: _controllers['district']!.text.trim(),
      province: _controllers['province']!.text.trim(),
      populatedCenter: _controllers['populatedCenter']!.text.trim(),
      latitude: n('latitude'),
      longitude: n('longitude'),
      altitude: n('altitude'),
      ruralPopulation: i('ruralPopulation'),
      totalPopulation: 5000,
      ruralPercentage: 24,
      agriculturalActivity: true,
      mainCrop: 'papa',
      temperatureMin: n('temperatureMin'),
      temperatureMax: n('temperatureMax'),
      feelsLike: n('feelsLike'),
      humidity: n('humidity'),
      windSpeed: n('windSpeed'),
      cloudCover: n('cloudCover'),
      dewPoint: n('dewPoint'),
      precipitation: n('precipitation'),
      month: i('month'),
      hour: i('hour'),
      hoursBelowZero: i('hoursBelowZero'),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.mutedTeal),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
