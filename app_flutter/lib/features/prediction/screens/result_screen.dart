import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/primary_action_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/frost_risk_request.dart';
import '../models/frost_risk_response.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    required this.request,
    required this.response,
    super.key,
  });

  final FrostRiskRequest request;
  final FrostRiskResponse response;

  @override
  Widget build(BuildContext context) {
    final riskColor = response.riskLevel == 'alto'
        ? AppColors.warmAmber
        : AppColors.mutedTeal;
    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        children: [
          const SectionHeader(
            title: 'Resultado de prediccion',
            subtitle:
                'Lectura del modelo para la ubicacion y condiciones enviadas.',
          ),
          const SizedBox(height: 30),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Label('RIESGO'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: riskColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _title(response.riskLevel),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: riskColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 78,
                      height: 78,
                      child: CircularProgressIndicator(
                        value: response.confidence,
                        color: riskColor,
                        backgroundColor: AppColors.surfaceHigh,
                        strokeWidth: 7,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _MetricBlock(
                        label: 'CONFIANZA',
                        value: '${(response.confidence * 100).round()}%',
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Label('CONDICION PARA CHUNO'),
                          const SizedBox(height: 8),
                          StatusChip(
                            icon: Icons.ac_unit,
                            label: _chuno(response.chunoConditions),
                            color: AppColors.deepNavy,
                            background: AppColors.surfaceHigh,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.warmAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.warmAmber.withValues(alpha: 0.22),
              ),
            ),
            child: Text(
              response.recommendation,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 24),
          GlassCard(
            color: AppColors.softWhite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Label('INFORMACION DEL MODELO'),
                const SizedBox(height: 18),
                _InfoRow(label: 'Modelo', value: 'Random Forest'),
                const Divider(),
                _InfoRow(label: 'Version', value: response.modelVersion),
                const Divider(),
                _InfoRow(label: 'Distrito', value: request.district),
              ],
            ),
          ),
          const SizedBox(height: 32),
          PrimaryActionButton(
            label: 'Nueva consulta',
            icon: Icons.add,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  static String _title(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

  static String _chuno(String value) {
    if (value == 'favorables') return 'Favorable';
    if (value == 'posibles') return 'Posible';
    return 'No favorable';
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.textSecondary,
        fontFamily: 'monospace',
        letterSpacing: 1.4,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
