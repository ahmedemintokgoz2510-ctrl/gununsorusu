import 'package:flutter/material.dart';

import '../state/app_state.dart';

class StatsScreen extends StatelessWidget {
  final AppState state;
  const StatsScreen({super.key, required this.state});

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('İstatistikler sıfırlansın mı?'),
        content: const Text(
          'Tüm istatistikler silinir ve bugünün sorusunu yeniden cevaplayabilirsin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await state.resetStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final accuracy = state.totalAnswered == 0
            ? 0.0
            : state.totalCorrect / state.totalAnswered;
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          appBar: AppBar(title: const Text('İstatistik')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  _StatCard(
                    icon: Icons.local_fire_department,
                    label: 'Güncel seri',
                    value: '${state.currentStreak} gün',
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.emoji_events,
                    label: 'En iyi seri',
                    value: '${state.bestStreak} gün',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(
                    icon: Icons.quiz,
                    label: 'Cevaplanan',
                    value: '${state.totalAnswered}',
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.check_circle,
                    label: 'Doğru',
                    value: '${state.totalCorrect}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Başarı oranı: %${(accuracy * 100).round()}',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: accuracy, minHeight: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Tema', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('Sistem')),
                  ButtonSegment(value: ThemeMode.light, label: Text('Açık')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Koyu')),
                ],
                selected: {state.themeMode},
                onSelectionChanged: (s) => state.setTheme(s.first),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _confirmReset(context),
                icon: const Icon(Icons.restart_alt),
                label: const Text('İstatistikleri sıfırla'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
