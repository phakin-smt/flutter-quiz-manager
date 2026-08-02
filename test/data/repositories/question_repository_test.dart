import 'package:flutter_quiz_manager/data/database/app_database.dart';
import 'package:flutter_quiz_manager/data/repositories/question_repository.dart';
import 'package:flutter_quiz_manager/models/question.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase appDatabase;
  late QuestionRepository repository;

  setUpAll(sqfliteFfiInit);

  setUp(() {
    appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    repository = QuestionRepository(appDatabase);
  });

  tearDown(() async {
    await appDatabase.close();
  });

  Question question(String text) {
    return Question(
      questionText: text,
      choices: ['Choice 1', 'Choice 2', 'Choice 3', 'Choice 4'],
    );
  }

  test('insert returns the SQLite-generated id', () async {
    final inserted = await repository.insertQuestion(question('First'));

    expect(inserted.id, isNotNull);
    expect(inserted.questionText, 'First');
    expect(inserted.choices, hasLength(4));
  });

  test('getAllQuestions returns questions ordered by id', () async {
    final first = await repository.insertQuestion(question('First'));
    final second = await repository.insertQuestion(question('Second'));
    final third = await repository.insertQuestion(question('Third'));

    final questions = await repository.getAllQuestions();

    expect(questions.map((question) => question.id), [
      first.id,
      second.id,
      third.id,
    ]);
  });

  test('delete removes only the selected id without renumbering', () async {
    final first = await repository.insertQuestion(question('First'));
    final second = await repository.insertQuestion(question('Second'));
    final third = await repository.insertQuestion(question('Third'));

    await repository.deleteQuestion(second.id!);
    final questions = await repository.getAllQuestions();

    expect(questions.map((question) => question.id), [first.id, third.id]);
    expect(questions.map((question) => question.questionText), [
      'First',
      'Third',
    ]);
  });
}
