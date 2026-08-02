class Question {
  Question({this.id, required this.questionText, required List<String> choices})
    : choices = List.unmodifiable(_validateChoices(choices));

  final int? id;
  final String questionText;
  final List<String> choices;

  factory Question.fromMap(Map<String, Object?> map) {
    return Question(
      id: map['id'] as int?,
      questionText: map['question_text'] as String,
      choices: [
        map['choice_1'] as String,
        map['choice_2'] as String,
        map['choice_3'] as String,
        map['choice_4'] as String,
      ],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'question_text': questionText,
      'choice_1': choices[0],
      'choice_2': choices[1],
      'choice_3': choices[2],
      'choice_4': choices[3],
    };
  }

  Question copyWith({int? id, String? questionText, List<String>? choices}) {
    return Question(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      choices: choices ?? this.choices,
    );
  }

  static List<String> _validateChoices(List<String> choices) {
    if (choices.length != 4) {
      throw ArgumentError.value(
        choices,
        'choices',
        'Question must have exactly 4 choices.',
      );
    }
    return choices;
  }
}
