import 'package:todo_demoapp/model/todo_model.dart';
import 'package:todo_demoapp/storage/todo_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TodoStorage storage;
  late TodoModel model;
  late DateTime now;

  setUp(() {
    storage = TodoStorage();
    model = TodoModel(storage);
    now = DateTime.now();
  });

  test('initial state should be empty', () {
    expect(storage.fetchAll(), isEmpty);
  });

  group('addTodo', () {
    test('should add new todo', () async {
      // Arrange
      const title = 'Test Todo';
      const estimatedHours = 2.0;
      final deadline = now.add(const Duration(hours: 3));

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
      final deadline = now.add(const Duration(hours: 3));

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
        deadline: now.add(const Duration(hours: 4)),
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
      expect(todo.deadline, now.add(const Duration(hours: 4))); // unchanged
    });

    test('should update estimated hours', () {
      // Act
      model.updateTodo(todoId, estimatedHours: 3.0);

      // Assert
      final todo = storage.fetchAll().first;
      expect(todo.title, 'Original Title'); // unchanged
      expect(todo.estimatedHours, 3.0);
      expect(todo.deadline, now.add(const Duration(hours: 4))); // unchanged
    });

    test('should update deadline', () {
      // Act
      final newDeadline = now.add(const Duration(hours: 2));
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
        deadline: now.add(const Duration(hours: 3)),
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

  group('addTodo with deadline restrictions', () {
    test('should throw when deadline is too soon for estimated hours', () {
      // Arrange
      final deadline = now.add(const Duration(hours: 2));
      const estimatedHours = 3.0;

      // Act & Assert
      expect(
        () => model.addTodo(
          title: 'Test Todo',
          estimatedHours: estimatedHours,
          deadline: deadline,
        ),
        throwsA(isA<DeadlineRestrictionException>()),
      );
    });

    test('should throw when not enough time considering existing todos', () {
      // Arrange
      // Add first todo: 3 hours, due in 5 hours
      model.addTodo(
        title: 'First Todo',
        estimatedHours: 3.0,
        deadline: now.add(const Duration(hours: 5)),
      );

      // Try to add second todo: 3 hours, due in 5 hours
      // This should fail because first todo needs 3 hours
      expect(
        () => model.addTodo(
          title: 'Second Todo',
          estimatedHours: 3.0,
          deadline: now.add(const Duration(hours: 5)),
        ),
        throwsA(isA<DeadlineRestrictionException>()),
      );
    });

    test('should allow adding todo when enough time is available', () {
      // Arrange
      // Add first todo: 2 hours, due in 8 hours
      model.addTodo(
        title: 'First Todo',
        estimatedHours: 2.0,
        deadline: now.add(const Duration(hours: 8)),
      );

      // Act & Assert - should succeed
      // Add second todo: 3 hours, due in 8 hours
      // Total 5 hours of work in 8 hour window is feasible
      expect(
        () => model.addTodo(
          title: 'Second Todo',
          estimatedHours: 3.0,
          deadline: now.add(const Duration(hours: 8)),
        ),
        returnsNormally,
      );
    });

    test('should consider only todos before new deadline', () {
      // Arrange
      // Add first todo: 2 hours, due in 10 hours
      model.addTodo(
        title: 'Later Todo',
        estimatedHours: 2.0,
        deadline: now.add(const Duration(hours: 10)),
      );

      // Act & Assert
      // Add second todo: 3 hours, due in 5 hours
      // Should succeed because the first todo is due after this one
      expect(
        () => model.addTodo(
          title: 'Earlier Todo',
          estimatedHours: 3.0,
          deadline: now.add(const Duration(hours: 5)),
        ),
        returnsNormally,
      );
    });
  });
}
