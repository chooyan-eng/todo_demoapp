import 'package:todo_demoapp/model/todo_model.dart';
import 'package:todo_demoapp/storage/todo_storage.dart';
import 'package:flutter/material.dart';

class ModelProvider extends StatefulWidget {
  const ModelProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  static TodoModel todoModelOf(BuildContext context) {
    final _ModelProviderScope? result =
        context.getInheritedWidgetOfExactType<_ModelProviderScope>();
    assert(result != null, 'No ModelProviderScope found in context');
    return result!.todoModel;
  }

  @override
  State<ModelProvider> createState() => _ModelProviderState();
}

class _ModelProviderState extends State<ModelProvider> {
  late final TodoModel _todoModel;

  @override
  void initState() {
    super.initState();
    final todoStorage = TodoStorage();

    _todoModel = TodoModel(todoStorage);
  }

  @override
  Widget build(BuildContext context) {
    return _ModelProviderScope(
      todoModel: _todoModel,
      child: widget.child,
    );
  }
}

class _ModelProviderScope extends InheritedWidget {
  const _ModelProviderScope({
    required super.child,
    required this.todoModel,
    // Add other models as needed
  });

  final TodoModel todoModel;
  // Declare other model instances

  @override
  bool updateShouldNotify(_ModelProviderScope oldWidget) {
    return false;
  }
}
