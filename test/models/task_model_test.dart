import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/models/task_model.dart';
import 'package:taskflow/models/enums.dart';

void main() {
  group('TaskModel Tests', () {
    test('copyWith should update specified fields and keep others intact', () {
      // Arrange
      final initialTime = DateTime(2026, 4, 24);
      final task = TaskModel(
        id: '1',
        title: 'Old Title',
        description: 'Old Description',
        status: TaskStatus.todo,
        priority: TaskPriority.low,
        createdBy: 'user1',
        createdAt: initialTime,
        updatedAt: initialTime,
      );

      // Act
      final updatedTask = task.copyWith(
        title: 'New Title',
        status: TaskStatus.inProgress,
      );

      // Assert
      expect(updatedTask.id, '1'); // Unchanged
      expect(updatedTask.title, 'New Title'); // Changed
      expect(updatedTask.description, 'Old Description'); // Unchanged
      expect(updatedTask.status, TaskStatus.inProgress); // Changed
      expect(updatedTask.priority, TaskPriority.low); // Unchanged
      expect(updatedTask.createdBy, 'user1'); // Unchanged
      expect(updatedTask.createdAt, initialTime); // Unchanged
      expect(updatedTask.updatedAt.isAfter(initialTime), true); // updatedAt should automatically update
    });
  });
}
