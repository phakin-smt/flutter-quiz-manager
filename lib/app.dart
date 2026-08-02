import 'package:flutter/material.dart';
import 'package:flutter_quiz_manager/data/database/app_database.dart';
import 'package:flutter_quiz_manager/data/repositories/question_repository.dart';
import 'package:flutter_quiz_manager/core/theme/app_theme.dart';
import 'package:flutter_quiz_manager/pages/question_list_page.dart';
import 'package:flutter_quiz_manager/providers/question_provider.dart';
import 'package:provider/provider.dart';

class QuizManagerApp extends StatelessWidget {
  QuizManagerApp({super.key, QuestionRepository? questionRepository})
    : questionRepository =
          questionRepository ?? QuestionRepository(AppDatabase());

  final QuestionRepository questionRepository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuestionProvider(questionRepository)..loadQuestions(),
      child: MaterialApp(
        title: 'Quiz Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const QuestionListPage(),
      ),
    );
  }
}
