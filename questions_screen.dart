import 'package:flutter/material.dart';

import '../models/question.dart';
import '../state/app_state.dart';
import '../widgets/option_tile.dart';
import 'add_question_screen.dart';
import 'today_screen.dart';

class QuestionsScreen extends StatefulWidget {
  final AppState state;
  const QuestionsScreen({super.key, required this.state});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  String _category = 'Tümü';

  Future<void> _confirmDelete(Question q) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Soru silinsin mi?'),
        content: Text(q.text),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.state.deleteQuestion(q.id);
    }
  }

  void _showDetail(Question q) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(label: Text(q.category)),
              const SizedBox(height: 8),
              Text(q.text, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              for (int i = 0; i < q.options.length; i++)
                OptionTile(
                  letter: kLetters[i],
                  text: q.options[i],
                  revealed: true,
                  isCorrect: i == q.correctIndex,
                ),
              if (q.explanation.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(q.explanation),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final cats = widget.state.categories;
        if (!cats.contains(_category)) _category = 'Tümü';
        final list = widget.state.allQuestions
            .where((q) => _category == 'Tümü' || q.category == _category)
            .toList();

        return Scaffold(
          appBar: AppBar(title: Text('Soru Bankası (${list.length})')),
          body: Column(
            children: [
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: cats.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final c = cats[i];
                    return ChoiceChip(
                      label: Text(c),
                      selected: c == _category,
                      onSelected: (_) => setState(() => _category = c),
                    );
                  },
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text('Bu kategoride soru yok.'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final q = list[i];
                          return Card(
                            child: ListTile(
                              title: Text(
                                q.text,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                q.isCustom
                                    ? '${q.category} • Benim sorum'
                                    : q.category,
                              ),
                              trailing: q.isCustom
                                  ? IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _confirmDelete(q),
                                    )
                                  : const Icon(Icons.chevron_right),
                              onTap: () => _showDetail(q),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AddQuestionScreen(state: widget.state),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Soru Ekle'),
          ),
        );
      },
    );
  }
}
