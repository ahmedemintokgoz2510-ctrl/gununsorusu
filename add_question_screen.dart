import 'package:flutter/material.dart';

import '../state/app_state.dart';
import 'today_screen.dart';

class AddQuestionScreen extends StatefulWidget {
  final AppState state;
  const AddQuestionScreen({super.key, required this.state});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _text = TextEditingController();
  final _options = List<TextEditingController>.generate(
    4,
    (_) => TextEditingController(),
  );
  final _explanation = TextEditingController();
  final _category = TextEditingController(text: 'Genel Kültür');
  int _correct = 0;

  @override
  void dispose() {
    _text.dispose();
    for (final c in _options) {
      c.dispose();
    }
    _explanation.dispose();
    _category.dispose();
    super.dispose();
  }

  String? _required(String? v) {
    if (v == null || v.trim().isEmpty) return 'Boş bırakma';
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final category =
        _category.text.trim().isEmpty ? 'Genel Kültür' : _category.text.trim();

    await widget.state.addQuestion(
      text: _text.text.trim(),
      options: _options.map((c) => c.text.trim()).toList(),
      correctIndex: _correct,
      explanation: _explanation.text.trim(),
      category: category,
    );
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Soru eklendi')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Soru')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _text,
              decoration: const InputDecoration(
                labelText: 'Soru',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
              validator: _required,
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < 4; i++) ...[
              TextFormField(
                controller: _options[i],
                decoration: InputDecoration(
                  labelText: '${kLetters[i]} şıkkı',
                  border: const OutlineInputBorder(),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
            ],
            const Text('Doğru cevap:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (int i = 0; i < 4; i++)
                  ChoiceChip(
                    label: Text(kLetters[i]),
                    selected: _correct == i,
                    onSelected: (_) => setState(() => _correct = i),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _category,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _explanation,
              decoration: const InputDecoration(
                labelText: 'Açıklama (isteğe bağlı)',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
