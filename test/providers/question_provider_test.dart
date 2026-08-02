import 'dart:async';

import 'package:flutter_quiz_manager/data/repositories/question_repository.dart';
import 'package:flutter_quiz_manager/models/question.dart';
import 'package:flutter_quiz_manager/providers/question_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeQuestionRepository implements QuestionRepository {
  final List<Question> storedQuestions = [];

  Object? loadError;
  Object? insertError;
  Object? deleteError;
  Completer<void>? loadCompleter;
  int _nextId = 1;

  @override
  Future<List<Question>> getAllQuestions() async {
    final completer = loadCompleter;
    if (completer != null) {
      await completer.future;
    }
    if (loadError case final error?) {
      throw error;
    }
    return List.of(storedQuestions);
  }

  @override
  Future<Question> insertQuestion(Question question) async {
    if (insertError case final error?) {
      throw error;
    }
    final insertedQuestion = question.copyWith(id: _nextId++);
    storedQuestions.add(insertedQuestion);
    return insertedQuestion;
  }

  @override
  Future<void> deleteQuestion(int id) async {
    if (deleteError case final error?) {
      throw error;
    }
    storedQuestions.removeWhere((question) => question.id == id);
  }
}

void main() {
  late FakeQuestionRepository repository;
  late QuestionProvider provider;

  Question question(String text, {int? id}) {
    return Question(
      id: id,
      questionText: text,
      choices: ['Choice 1', 'Choice 2', 'Choice 3', 'Choice 4'],
    );
  }

  setUp(() {
    repository = FakeQuestionRepository();
    provider = QuestionProvider(repository);
  });

  tearDown(() {
    provider.dispose();
  });

  test('has the expected initial state', () {
    expect(provider.questions, isEmpty);
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
  });

  test('loadQuestions stores repository questions', () async {
    repository.storedQuestions.addAll([
      question('First', id: 1),
      question('Second', id: 2),
    ]);

    await provider.loadQuestions();

    expect(provider.questions.map((question) => question.id), [1, 2]);
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
  });

  test('loadQuestions reports loading changes to listeners', () async {
    repository.loadCompleter = Completer<void>();
    var notificationCount = 0;
    provider.addListener(() => notificationCount++);

    final loadFuture = provider.loadQuestions();

    expect(provider.isLoading, isTrue);
    expect(notificationCount, 1);

    repository.loadCompleter!.complete();
    await loadFuture;

    expect(provider.isLoading, isFalse);
    expect(notificationCount, 2);
  });

  test('loadQuestions stores an error without throwing', () async {
    repository.loadError = StateError('Unable to load questions');

    await provider.loadQuestions();

    expect(provider.errorMessage, contains('Unable to load questions'));
    expect(provider.isLoading, isFalse);
  });

  test('addQuestion adds the inserted question with its id', () async {
    final inserted = await provider.addQuestion(question('New question'));

    expect(inserted.id, 1);
    expect(provider.questions.single.id, 1);
    expect(provider.questions.single.questionText, 'New question');
  });

  test('deleteQuestion removes only the selected id', () async {
    repository.storedQuestions.addAll([
      question('First', id: 1),
      question('Second', id: 2),
      question('Third', id: 3),
    ]);
    await provider.loadQuestions();

    await provider.deleteQuestion(2);

    expect(provider.questions.map((question) => question.id), [1, 3]);
  });

  test('deleteQuestion keeps memory unchanged when deletion fails', () async {
    repository.storedQuestions.add(question('First', id: 1));
    await provider.loadQuestions();
    repository.deleteError = StateError('Unable to delete question');

    await expectLater(provider.deleteQuestion(1), throwsStateError);

    expect(provider.questions.single.id, 1);
    expect(provider.errorMessage, contains('Unable to delete question'));
  });

  test('questions cannot be modified externally', () async {
    repository.storedQuestions.add(question('First', id: 1));
    await provider.loadQuestions();

    expect(
      () => provider.questions.add(question('Second', id: 2)),
      throwsUnsupportedError,
    );
    expect(provider.questions.single.id, 1);
  });

  test('clearError notifies only when an error exists', () async {
    repository.loadError = StateError('Unable to load questions');
    await provider.loadQuestions();
    var notificationCount = 0;
    provider.addListener(() => notificationCount++);

    provider.clearError();

    expect(provider.errorMessage, isNull);
    expect(notificationCount, 1);

    provider.clearError();
    expect(notificationCount, 1);
  });
}
