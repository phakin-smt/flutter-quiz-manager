import 'package:flutter/foundation.dart';
import 'package:flutter_quiz_manager/data/repositories/question_repository.dart';
import 'package:flutter_quiz_manager/models/question.dart';

class QuestionProvider extends ChangeNotifier {
  QuestionProvider(this._repository);

  final QuestionRepository _repository;
  final List<Question> _questions = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Question> get questions => List.unmodifiable(_questions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadQuestions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final questions = await _repository.getAllQuestions();
      _questions
        ..clear()
        ..addAll(questions);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Question> addQuestion(Question question) async {
    _errorMessage = null;

    try {
      final insertedQuestion = await _repository.insertQuestion(question);
      _questions.add(insertedQuestion);
      notifyListeners();
      return insertedQuestion;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteQuestion(int id) async {
    _errorMessage = null;

    try {
      await _repository.deleteQuestion(id);
      _questions.removeWhere((question) => question.id == id);
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }
}
