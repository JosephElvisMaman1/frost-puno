import 'package:flutter/material.dart';

import '../../../core/i18n/app_strings.dart';
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
    final riskColor = _riskColor(response.riskLevel);
    final riskIcon = _riskIcon(response.riskLevel);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final s = AppStrings.current;
    return PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        children: [
          SectionHeader(
            title: s.resultTitle,
            subtitle: s.resultSubtitle,
          ),
          const SizedBox(height: 24),
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label(s.riskLabel),
                          const SizedBox(height: 8),
                          Text(
                            s.riskWord(response.riskLevel).toUpperCase(),
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(color: riskColor, fontSize: 44),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(riskIcon, color: riskColor, size: 42),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: riskColor.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.tips_and_updates_outlined, color: riskColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s.recommendation(
                            response.riskLevel,
                            _shortRecommendation(response.recommendation),
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _MetricBlock(
                        label: s.confidence,
                        value: '${(response.confidence * 100).round()}%',
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label(s.chunoConditionLabel),
                          const SizedBox(height: 8),
                          StatusChip(
                            icon: Icons.ac_unit,
                            label: s.chunoCondition(response.chunoConditions),
                            color: onSurface,
                            background: onSurface.withValues(alpha: 0.08),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label(s.summary),
                const SizedBox(height: 18),
                _InfoRow(label: s.district, value: request.district),
                const Divider(),
                _InfoRow(label: s.model, value: response.modelVersion),
              ],
            ),
          ),
          const SizedBox(height: 28),
          PrimaryActionButton(
            label: s.newQuery,
            icon: Icons.add,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  static Color _riskColor(String value) {
    return switch (value.toLowerCase()) {
      'alto' => AppColors.warmAmber,
      'medio' => AppColors.mediumRisk,
      'moderado' => AppColors.mediumRisk,
      _ => AppColors.lowRisk,
    };
  }

  static IconData _riskIcon(String value) {
    return switch (value.toLowerCase()) {
      'alto' => Icons.warning_amber_rounded,
      'medio' => Icons.report_problem_outlined,
      'moderado' => Icons.report_problem_outlined,
      _ => Icons.check_circle_outline,
    };
  }

  static String _shortRecommendation(String value) {
    final clean = value.trim();
    if (clean.isEmpty) {
      return 'Revisar condiciones locales y monitorear cambios de temperatura.';
    }
    final firstSentence = clean.split('.').first.trim();
    return firstSentence.isEmpty ? clean : '$firstSentence.';
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
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.64),
        fontFamily: 'monospace',
        letterSpacing: 0,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
