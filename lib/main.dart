import 'package:flutter/material.dart';

void main() {
  runApp(const JobPrepApp());
}

class JobPrepApp extends StatelessWidget {
  const JobPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'JobPrep',
      home: Scaffold(
        body: Center(
          child: Text('Job Circular Tracker & Exam Prep'),
        ),
      ),
    );
  }
}
