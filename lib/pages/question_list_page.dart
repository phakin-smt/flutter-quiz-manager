import 'package:flutter/material.dart';

class QuestionListPage extends StatelessWidget {
  const QuestionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('จัดการข้อสอบ')),
      body: const Center(child: Text('ยังไม่มีข้อสอบ')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: null,
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มข้อสอบ'),
      ),
    );
  }
}
