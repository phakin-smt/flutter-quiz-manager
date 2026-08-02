import 'package:flutter_quiz_manager/data/database/app_database.dart';
import 'package:flutter_quiz_manager/models/question.dart';

class QuestionRepository {
  QuestionRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<List<Question>> getAllQuestions() async {
    final database = await _appDatabase.database;
    final maps = await database.query(
      AppDatabase.questionsTable,
      orderBy: 'id ASC',
    );

    return maps.map(Question.fromMap).toList(growable: false);
  }

  Future<Question> insertQuestion(Question question) async {
    final database = await _appDatabase.database;
    final values = question.toMap()..remove('id');
    final id = await database.insert(AppDatabase.questionsTable, values);

    return question.copyWith(id: id);
  }

  Future<void> deleteQuestion(int id) async {
    final database = await _appDatabase.database;
    await database.delete(
      AppDatabase.questionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
