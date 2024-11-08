import 'package:arc_todo/model/todo_model.dart';
import 'package:arc_todo/storage/todo_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TodoStorage storage;
  late TodoModel model;

  setUp(() {
    storage = TodoStorage();
    model = TodoModel(storage);
  });

  test('initial state should be empty', () {
    expect(storage.fetchAll(), isEmpty);
  });

  group('addTodo', () {
    test('should add new todo', () async {
      // Arrange
      const title = 'Test Todo';
      const estimatedHours = 2.0;
      final deadline = DateTime(2024, 1, 1, 12, 0);

      // Act
      model.addTodo(
        title: title,
        estimatedHours: estimatedHours,
        deadline: deadline,
      );

      // Assert
      final todos = storage.fetchAll();
      expect(todos.length, 1);
      expect(todos.first.title, title);
      expect(todos.first.estimatedHours, estimatedHours);
      expect(todos.first.deadline, deadline);
      expect(todos.first.isCompleted, false);
    });

    test('should notify listeners when todo is added', () async {
      // Arrange
      const title = 'Test Todo';
      const estimatedHours = 2.0;
      final deadline = DateTime(2024, 1, 1, 12, 0);

      // Act & Assert
      expectLater(
        model.todoStream,
        emits(predicate<List<Todo>>((todos) {
          return todos.length == 1 &&
              todos.first.title == title &&
              todos.first.estimatedHours == estimatedHours &&
              todos.first.deadline == deadline;
        })),
      );

      model.addTodo(
        title: title,
        estimatedHours: estimatedHours,
        deadline: deadline,
      );
    });
  });

  group('updateTodo', () {
    late String todoId;

    setUp(() {
      model.addTodo(
        title: 'Original Title',
        estimatedHours: 1.0,
        deadline: DateTime(2024, 1, 1),
      );
      todoId = storage.fetchAll().first.id;
    });

    test('should update todo title', () {
      // Act
      model.updateTodo(todoId, title: 'Updated Title');

      // Assert
      final todo = storage.fetchAll().first;
      expect(todo.title, 'Updated Title');
      expect(todo.estimatedHours, 1.0); // unchanged
      expect(todo.deadline, DateTime(2024, 1, 1)); // unchanged
    });

    test('should update estimated hours', () {
      // Act
      model.updateTodo(todoId, estimatedHours: 3.0);

      // Assert
      final todo = storage.fetchAll().first;
      expect(todo.title, 'Original Title'); // unchanged
      expect(todo.estimatedHours, 3.0);
      expect(todo.deadline, DateTime(2024, 1, 1)); // unchanged
    });

    test('should update deadline', () {
      // Act
      final newDeadline = DateTime(2024, 2, 1);
      model.updateTodo(todoId, deadline: newDeadline);

      // Assert
      final todo = storage.fetchAll().first;
      expect(todo.title, 'Original Title'); // unchanged
      expect(todo.estimatedHours, 1.0); // unchanged
      expect(todo.deadline, newDeadline);
    });

    test('should notify listeners when todo is updated', () {
      // Arrange
      const newTitle = 'Updated Title';

      // Act & Assert
      expectLater(
        model.todoStream,
        emits(predicate<List<Todo>>((todos) {
          return todos.length == 1 && todos.first.title == newTitle;
        })),
      );

      model.updateTodo(todoId, title: newTitle);
    });

    test('should do nothing when todo id does not exist', () {
      // Act
      model.updateTodo('non-existent-id', title: 'New Title');

      // Assert
      final todo = storage.fetchAll().first;
      expect(todo.title, 'Original Title'); // unchanged
    });
  });

  group('deleteTodo', () {
    late String todoId;

    setUp(() {
      model.addTodo(
        title: 'Test Todo',
        estimatedHours: 1.0,
        deadline: DateTime(2024, 1, 1),
      );
      todoId = storage.fetchAll().first.id;
    });

    test('should delete todo', () {
      // Act
      model.deleteTodo(todoId);

      // Assert
      expect(storage.fetchAll(), isEmpty);
    });

    test('should notify listeners when todo is deleted', () {
      // Act & Assert
      expectLater(
        model.todoStream,
        emits(isEmpty),
      );

      model.deleteTodo(todoId);
    });

    test('should do nothing when todo id does not exist', () {
      // Act
      model.deleteTodo('non-existent-id');

      // Assert
      expect(storage.fetchAll().length, 1);
    });
  });

  test('dispose should close the stream', () async {
    // Act
    model.dispose();

    // Assert
    await expectLater(
      model.todoStream,
      emitsError(isA<StateError>()),
    );
  });
}
