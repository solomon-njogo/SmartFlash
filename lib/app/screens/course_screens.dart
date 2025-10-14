import 'package:flutter/material.dart';

/// Placeholder screen for creating courses
class CreateCourseScreen extends StatelessWidget {
  const CreateCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Course')),
      body: const Center(child: Text('Create Course Screen - Coming Soon')),
    );
  }
}

/// Placeholder screen for editing courses
class EditCourseScreen extends StatelessWidget {
  final String courseId;

  const EditCourseScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Course')),
      body: Center(child: Text('Edit Course Screen - Course ID: $courseId')),
    );
  }
}
