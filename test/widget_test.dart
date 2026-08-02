import 'package:flutter/material.dart';
import 'package:flutter_quiz_manager/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the empty question list state', (tester) async {
    await tester.pumpWidget(const QuizManagerApp());

    expect(find.text('จัดการข้อสอบ'), findsOneWidget);
    expect(find.text('ยังไม่มีข้อสอบ'), findsOneWidget);
    expect(find.text('เพิ่มข้อสอบ'), findsOneWidget);

    final addButton = tester.widget<FloatingActionButton>(
      find.byType(FloatingActionButton),
    );
    expect(addButton.onPressed, isNull);
  });
}
