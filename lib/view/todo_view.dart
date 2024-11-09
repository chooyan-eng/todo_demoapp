import 'package:todo_demoapp/model_provider.dart';
import 'package:todo_demoapp/view/add_todo_dialog.dart';
import 'package:flutter/material.dart';
import 'package:todo_demoapp/view_model/todo_view_model.dart';
import 'package:todo_demoapp/model/todo_model.dart';
import 'package:todo_demoapp/view/edit_todo_view.dart';

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  late final TodoViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = TodoViewModel(
      ModelProvider.todoModelOf(context),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> showDeleteConfirmation(Todo todo) async {
      return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Delete Todo'),
                content:
                    Text('Are you sure you want to delete "${todo.title}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          ) ??
          false;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todo List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AddTodoDialog.show(context);
        },
        child: const Icon(Icons.add),
      ),
      body: CustomScrollView(
        slivers: [
          ValueListenableBuilder<TodoViewState>(
            valueListenable: _viewModel,
            builder: (context, state, _) {
              return state.todos.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task,
                              size: 64,
                              color: Color(0xFF2D2D2D),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No todos yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final todo = state.todos[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: Icon(
                                  todo.isCompleted
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                  color: Colors.tealAccent[400],
                                ),
                                title: Text(
                                  todo.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estimated: ${todo.estimatedHours}h',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    Text(
                                      'Due: ${todo.formattedDeadline}',
                                      style: TextStyle(
                                        color: todo.deadline
                                                .isBefore(DateTime.now())
                                            ? Colors.redAccent[400]
                                            : Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () async {
                                    final result =
                                        await showDeleteConfirmation(todo);
                                    if (result) {
                                      _viewModel.deleteTodo(todo.id);
                                    }
                                  },
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    EditTodoView.route(todo),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: state.todos.length,
                        ),
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}
