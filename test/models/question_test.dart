import 'package:flutter_quiz_manager/models/question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Question', () {
    test('converts to and from a map', () {
      final question = Question(
        id: 7,
        questionText: 'Which number is even?',
        choices: ['1', '2', '3', '5'],
      );

      final map = question.toMap();
      final restoredQuestion = Question.fromMap(map);

      expect(restoredQuestion.id, 7);
      expect(restoredQuestion.questionText, 'Which number is even?');
      expect(restoredQuestion.choices, ['1', '2', '3', '5']);
      expect(restoredQuestion.toMap(), map);
    });

    test('requires exactly four choices', () {
      expect(
        () => Question(questionText: 'Invalid', choices: ['A', 'B', 'C']),
        throwsArgumentError,
      );

      final question = Question(
        questionText: 'Valid',
        choices: ['A', 'B', 'C', 'D'],
      );
      expect(question.choices, hasLength(4));
    });

    test('does not allow choices to be changed externally', () {
      final sourceChoices = ['A', 'B', 'C', 'D'];
      final question = Question(
        questionText: 'Immutable choices',
        choices: sourceChoices,
      );

      sourceChoices[0] = 'Changed';

      expect(question.choices.first, 'A');
      expect(() => question.choices.add('E'), throwsUnsupportedError);
    });
  });
}
