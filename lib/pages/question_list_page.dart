import 'package:flutter/material.dart';
import 'package:flutter_quiz_manager/models/question.dart';
import 'package:flutter_quiz_manager/pages/question_form_page.dart';
import 'package:flutter_quiz_manager/providers/question_provider.dart';
import 'package:provider/provider.dart';

class QuestionListPage extends StatelessWidget {
  const QuestionListPage({super.key});

  Future<void> _openQuestionForm(BuildContext context) async {
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const QuestionFormPage()));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Question question,
    int runningNumber,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการลบข้อที่ $runningNumber หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    try {
      await context.read<QuestionProvider>().deleteQuestion(question.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ลบข้อที่ $runningNumber แล้ว')));
      }
    } catch (_) {
      if (context.mounted) {
        final message = context.read<QuestionProvider>().errorMessage;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message ?? 'ลบข้อสอบไม่สำเร็จ')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('จัดการข้อสอบ')),
      body: Consumer<QuestionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(key: Key('questionsLoading')),
            );
          }

          if (provider.errorMessage != null && provider.questions.isEmpty) {
            return _ErrorState(
              message: provider.errorMessage!,
              onRetry: provider.loadQuestions,
            );
          }

          if (provider.questions.isEmpty) {
            return const _EmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            itemCount: provider.questions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final question = provider.questions[index];
              final runningNumber = index + 1;
              return _QuestionCard(
                question: question,
                runningNumber: runningNumber,
                onDelete: () =>
                    _confirmDelete(context, question, runningNumber),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addQuestionButton'),
        onPressed: () => _openQuestionForm(context),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มข้อสอบ'),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.runningNumber,
    required this.onDelete,
  });

  final Question question;
  final int runningNumber;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      key: Key('questionCard-${question.id}'),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'ข้อที่ $runningNumber',
                    key: Key('runningNumber-${question.id}'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  key: Key('deleteQuestion-${question.id}'),
                  onPressed: onDelete,
                  tooltip: 'ลบข้อที่ $runningNumber',
                  color: colorScheme.error,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              question.questionText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < question.choices.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Text('${index + 1}'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(question.choices[index])),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_outlined, size: 64),
            SizedBox(height: 12),
            Text('ยังไม่มีข้อสอบ'),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            const Text('โหลดข้อสอบไม่สำเร็จ'),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              key: const Key('retryLoadButton'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('ลองใหม่'),
            ),
          ],
        ),
      ),
    );
  }
}
