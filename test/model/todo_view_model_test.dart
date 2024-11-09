import 'package:flutter_test/flutter_test.dart';
import 'package:todo_demoapp/model/member.dart';
import 'package:todo_demoapp/model/todo_model.dart';
import 'package:todo_demoapp/storage/todo_storage.dart';
import 'package:todo_demoapp/view_model/todo_view_model.dart';

void main() {
  late TodoStorage storage;
  late TodoModel model;
  late TodoViewModel viewModel;

  final member = Member(
    id: 'test-member',
    name: 'Test Member',
    icon: IconType.person,
  );

  setUp(() {
    storage = TodoStorage();
    model = TodoModel(storage);
    viewModel = TodoViewModel(model);
  });

  group('TodoViewModel Filter', () {
    setUp(() {
      model.addTodo(
        title: 'Test Todo',
        estimatedHours: 1.0,
        deadline: DateTime.now().add(const Duration(hours: 3)),
        assignee: member,
      );
    });

    test('should show all todos by default', () {
      expect(viewModel.value.showCompleted, true);
      expect(viewModel.value.filteredTodos.length, 1);
    });

    test('should filter completed todos when showCompleted is false', () {
      // Add completed and incomplete todos
      model.toggleTodoCompletion(storage.fetchAll().first.id);

      model.addTodo(
        title: 'Incomplete Todo',
        estimatedHours: 1.0,
        deadline: DateTime.now().add(const Duration(hours: 3)),
        assignee: member,
      );

      // Toggle filter
      viewModel.toggleShowCompleted();

      // Should only show incomplete todos
      expect(viewModel.value.showCompleted, false);
      expect(viewModel.value.filteredTodos.length, 1);
      expect(viewModel.value.filteredTodos.first.title, 'Incomplete Todo');
    });

    test('should show all todos when showCompleted is true', () {
      model.toggleTodoCompletion(storage.fetchAll().first.id);

      model.addTodo(
        title: 'Incomplete Todo',
        estimatedHours: 1.0,
        deadline: DateTime.now().add(const Duration(hours: 3)),
        assignee: member,
      );

      // Should show all todos
      expect(viewModel.value.showCompleted, true);
      expect(viewModel.value.filteredTodos.length, 2);
    });
  });
}
