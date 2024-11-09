import 'package:todo_demoapp/model/todo_model.dart';

class TodoStorage {
  final List<Todo> _todos = [];

  void save(Todo todo) {
    _todos.add(todo);
  }

  void update(Todo todo) {
    _todos[_todos.indexWhere((t) => t.id == todo.id)] = todo;
  }

  List<Todo> fetchAll() {
    return [..._todos];
  }

  void delete(String id) {
    _todos.removeWhere((todo) => todo.id == id);
  }
}
