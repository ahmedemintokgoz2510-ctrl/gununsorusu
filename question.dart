class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String category;
  final bool isCustom;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation = '',
    this.category = 'Genel Kültür',
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
        'category': category,
      };

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      options: (json['options'] as List).map((e) => e.toString()).toList(),
      correctIndex: json['correctIndex'] as int,
      explanation: (json['explanation'] ?? '') as String,
      category: (json['category'] ?? 'Genel Kültür') as String,
      isCustom: true,
    );
  }
}
