import 'package:flutter/material.dart';
import 'package:flutter_quiz_manager/core/theme/app_theme.dart';
import 'package:flutter_quiz_manager/pages/question_list_page.dart';

class QuizManagerApp extends StatelessWidget {
  const QuizManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const QuestionListPage(),
    );
  }
}
