import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quiz_manager/app.dart';
import 'package:flutter_quiz_manager/data/repositories/question_repository.dart';
import 'package:flutter_quiz_manager/models/question.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeQuestionRepository implements QuestionRepository {
  FakeQuestionRepository({List<Question>? questions})
    : questions = List.of(questions ?? []);

  final List<Question> questions;
  Completer<void>? loadCompleter;
  Object? loadError;
  Object? insertError;
  Object? deleteError;
  int insertCallCount = 0;

  @override
  Future<List<Question>> getAllQuestions() async {
    final completer = loadCompleter;
    if (completer != null) {
      await completer.future;
    }
    if (loadError case final error?) {
      throw error;
    }
    questions.sort((first, second) => first.id!.compareTo(second.id!));
    return List.of(questions);
  }

  @override
  Future<Question> insertQuestion(Question question) async {
    insertCallCount++;
    if (insertError case final error?) {
      throw error;
    }
    final largestId = questions.fold<int>(
      0,
      (largest, question) => question.id! > largest ? question.id! : largest,
    );
    final inserted = question.copyWith(id: largestId + 1);
    questions.add(inserted);
    return inserted;
  }

  @override
  Future<void> deleteQuestion(int id) async {
    if (deleteError case final error?) {
      throw error;
    }
    questions.removeWhere((question) => question.id == id);
  }
}

Question question(int id, String text) {
  return Question(
    id: id,
    questionText: text,
    choices: ['$text A', '$text B', '$text C', '$text D'],
  );
}

Future<void> pumpQuizApp(
  WidgetTester tester,
  FakeQuestionRepository repository, {
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(600, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(QuizManagerApp(questionRepository: repository));
  if (settle) {
    await tester.pumpAndSettle();
  }
}

Future<void> openQuestionForm(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('addQuestionButton')));
  await tester.pumpAndSettle();
}

Future<void> fillQuestionForm(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('questionTextField')),
    '  คำถามใหม่  ',
  );
  for (var index = 1; index <= 4; index++) {
    await tester.enterText(
      find.byKey(Key('choiceField$index')),
      '  ตัวเลือก $index  ',
    );
  }
}

void main() {
  testWidgets('shows the empty state', (tester) async {
    await pumpQuizApp(tester, FakeQuestionRepository());

    expect(find.text('ยังไม่มีข้อสอบ'), findsOneWidget);
    expect(find.text('เพิ่มข้อสอบ'), findsOneWidget);
  });

  testWidgets('shows the loading state', (tester) async {
    final repository = FakeQuestionRepository()
      ..loadCompleter = Completer<void>();

    await pumpQuizApp(tester, repository, settle: false);
    await tester.pump();

    expect(find.byKey(const Key('questionsLoading')), findsOneWidget);

    repository.loadCompleter!.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('shows an error state with a retry button', (tester) async {
    final repository = FakeQuestionRepository()
      ..loadError = StateError('Load failed');

    await pumpQuizApp(tester, repository);

    expect(find.text('โหลดข้อสอบไม่สำเร็จ'), findsOneWidget);
    expect(find.text('ลองใหม่'), findsOneWidget);
  });

  testWidgets('shows questions and all four choices', (tester) async {
    final repository = FakeQuestionRepository(
      questions: [question(10, 'คำถามแรก')],
    );

    await pumpQuizApp(tester, repository);

    expect(find.text('คำถามแรก'), findsOneWidget);
    for (final suffix in ['A', 'B', 'C', 'D']) {
      expect(find.text('คำถามแรก $suffix'), findsOneWidget);
    }
  });

  testWidgets('uses list indexes for running numbers instead of ids', (
    tester,
  ) async {
    final repository = FakeQuestionRepository(
      questions: [question(10, 'First'), question(30, 'Second')],
    );

    await pumpQuizApp(tester, repository);

    expect(find.text('ข้อที่ 1'), findsOneWidget);
    expect(find.text('ข้อที่ 2'), findsOneWidget);
    expect(find.text('ข้อที่ 10'), findsNothing);
    expect(find.text('ข้อที่ 30'), findsNothing);
  });

  testWidgets('opens the question form from the add button', (tester) async {
    await pumpQuizApp(tester, FakeQuestionRepository());

    await openQuestionForm(tester);

    expect(find.widgetWithText(AppBar, 'เพิ่มข้อสอบ'), findsOneWidget);
    expect(find.byKey(const Key('questionTextField')), findsOneWidget);
    expect(find.byKey(const Key('choiceField4')), findsOneWidget);
  });

  testWidgets('validates blank question and choice fields', (tester) async {
    await pumpQuizApp(tester, FakeQuestionRepository());
    await openQuestionForm(tester);

    await tester.ensureVisible(find.byKey(const Key('saveQuestionButton')));
    await tester.tap(find.byKey(const Key('saveQuestionButton')));
    await tester.pump();

    expect(find.text('กรุณากรอกคำถาม'), findsOneWidget);
    expect(find.text('กรุณากรอกตัวเลือก 1'), findsOneWidget);
  });

  testWidgets('saves trimmed values and returns to the list', (tester) async {
    final repository = FakeQuestionRepository();
    await pumpQuizApp(tester, repository);
    await openQuestionForm(tester);
    await fillQuestionForm(tester);

    await tester.ensureVisible(find.byKey(const Key('saveQuestionButton')));
    await tester.tap(find.byKey(const Key('saveQuestionButton')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'จัดการข้อสอบ'), findsOneWidget);
    expect(find.text('คำถามใหม่'), findsOneWidget);
    expect(repository.questions.single.questionText, 'คำถามใหม่');
    expect(repository.questions.single.choices.first, 'ตัวเลือก 1');
  });

  testWidgets('cancels the form without saving', (tester) async {
    final repository = FakeQuestionRepository();
    await pumpQuizApp(tester, repository);
    await openQuestionForm(tester);
    await fillQuestionForm(tester);

    await tester.ensureVisible(find.byKey(const Key('cancelQuestionButton')));
    await tester.tap(find.byKey(const Key('cancelQuestionButton')));
    await tester.pumpAndSettle();

    expect(repository.insertCallCount, 0);
    expect(find.text('ยังไม่มีข้อสอบ'), findsOneWidget);
  });

  testWidgets('asks for confirmation before deleting', (tester) async {
    final repository = FakeQuestionRepository(
      questions: [question(7, 'Delete me')],
    );
    await pumpQuizApp(tester, repository);

    await tester.tap(find.byKey(const Key('deleteQuestion-7')));
    await tester.pumpAndSettle();

    expect(find.text('ยืนยันการลบ'), findsOneWidget);
    expect(find.text('ต้องการลบข้อที่ 1 หรือไม่?'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'ยกเลิก'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'ลบ'), findsOneWidget);
  });

  testWidgets('deleting the middle item recalculates running numbers', (
    tester,
  ) async {
    final repository = FakeQuestionRepository(
      questions: [
        question(10, 'First'),
        question(20, 'Second'),
        question(30, 'Third'),
      ],
    );
    await pumpQuizApp(tester, repository);

    await tester.tap(find.byKey(const Key('deleteQuestion-20')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'ลบ'));
    await tester.pumpAndSettle();

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsNothing);
    expect(find.text('Third'), findsOneWidget);
    expect(find.text('ข้อที่ 1'), findsOneWidget);
    expect(find.text('ข้อที่ 2'), findsOneWidget);
    expect(find.text('ข้อที่ 3'), findsNothing);
    expect(repository.questions.map((question) => question.id), [10, 30]);
  });

  testWidgets('keeps the question visible when deletion fails', (tester) async {
    final repository = FakeQuestionRepository(
      questions: [question(5, 'Keep me')],
    )..deleteError = StateError('Delete failed');
    await pumpQuizApp(tester, repository);

    await tester.tap(find.byKey(const Key('deleteQuestion-5')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'ลบ'));
    await tester.pumpAndSettle();

    expect(find.text('Keep me'), findsOneWidget);
    expect(find.textContaining('Delete failed'), findsOneWidget);
    expect(repository.questions.single.id, 5);
  });
}
