import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../utils/date_utils.dart';
import '../widgets/option_tile.dart';

const List<String> kLetters = ['A', 'B', 'C', 'D', 'E', 'F'];

class TodayScreen extends StatelessWidget {
  final AppState state;
  const TodayScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final q = state.todayQuestion;
        final answered = state.todayAnswer;
        final scheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          appBar: AppBar(title: const Text('Günün Sorusu')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      turkishDate(DateTime.now()),
                      style: textTheme.titleMedium,
                    ),
                  ),
                  Chip(
                    avatar: const Icon(Icons.local_fire_department, size: 18),
                    label: Text('${state.currentStreak} gün'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                color: scheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(label: Text(q.category)),
                      const SizedBox(height: 8),
                      Text(
                        q.text,
                        style: textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (int i = 0; i < q.options.length; i++)
                OptionTile(
                  letter: kLetters[i],
                  text: q.options[i],
                  revealed: answered != null,
                  isCorrect: i == q.correctIndex,
                  isSelected: answered == i,
                  onTap: answered == null ? () => state.answerToday(i) : null,
                ),
              if (answered != null) ...[
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          answered == q.correctIndex
                              ? 'Doğru! 🎉'
                              : 'Yanlış. Doğru cevap: ${kLetters[q.correctIndex]}) ${q.options[q.correctIndex]}',
                          style: textTheme.titleMedium,
                        ),
                        if (q.explanation.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(q.explanation),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          'Yeni soru yarın seni bekliyor.',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
