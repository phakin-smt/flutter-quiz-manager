import 'package:flutter/material.dart';
import 'package:flutter_quiz_manager/models/question.dart';
import 'package:flutter_quiz_manager/providers/question_provider.dart';
import 'package:provider/provider.dart';

class QuestionFormPage extends StatefulWidget {
  const QuestionFormPage({super.key});

  @override
  State<QuestionFormPage> createState() => _QuestionFormPageState();
}

class _QuestionFormPageState extends State<QuestionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _choiceControllers = List.generate(4, (_) => TextEditingController());

  bool _isSaving = false;

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _choiceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final question = Question(
      questionText: _questionController.text.trim(),
      choices: _choiceControllers
          .map((controller) => controller.text.trim())
          .toList(),
    );

    try {
      await context.read<QuestionProvider>().addQuestion(question);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        final message = context.read<QuestionProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'บันทึกข้อสอบไม่สำเร็จ')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอก$fieldName';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มข้อสอบ')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                key: const Key('questionTextField'),
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'คำถาม',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.next,
                validator: (value) => _requiredValidator(value, 'คำถาม'),
              ),
              const SizedBox(height: 16),
              for (var index = 0; index < _choiceControllers.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    key: Key('choiceField${index + 1}'),
                    controller: _choiceControllers[index],
                    decoration: InputDecoration(
                      labelText: 'ตัวเลือก ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: index == _choiceControllers.length - 1
                        ? TextInputAction.done
                        : TextInputAction.next,
                    validator: (value) =>
                        _requiredValidator(value, 'ตัวเลือก ${index + 1}'),
                    onFieldSubmitted: index == _choiceControllers.length - 1
                        ? (_) => _saveQuestion()
                        : null,
                  ),
                ),
              const SizedBox(height: 4),
              FilledButton.icon(
                key: const Key('saveQuestionButton'),
                onPressed: _isSaving ? null : _saveQuestion,
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'กำลังบันทึก...' : 'บันทึก'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('cancelQuestionButton'),
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                child: const Text('ยกเลิก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
