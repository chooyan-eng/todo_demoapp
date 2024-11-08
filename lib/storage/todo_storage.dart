import 'package:arc_todo/model/todo_model.dart';

class TodoStorage {
  final List<Todo> _todos = [];

  void save(Todo todo) {
    _todos.add(todo);
  }

  List<Todo> fetchAll() {
    return [..._todos];
  }

  void delete(String id) {
    _todos.removeWhere((todo) => todo.id == id);
  }
}
