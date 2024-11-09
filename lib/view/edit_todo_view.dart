import 'package:todo_demoapp/model_provider.dart';
import 'package:flutter/material.dart';
import 'package:todo_demoapp/model/todo_model.dart';
import 'package:todo_demoapp/view_model/edit_todo_view_model.dart';
import 'package:todo_demoapp/view/member_select_field.dart';

class EditTodoView extends StatefulWidget {
  const EditTodoView({
    super.key,
    required this.todo,
  });

  final Todo todo;

  static Route<void> route(Todo todo) {
    return MaterialPageRoute(
      builder: (context) => EditTodoView(todo: todo),
    );
  }

  @override
  State<EditTodoView> createState() => _EditTodoViewState();
}

class _EditTodoViewState extends State<EditTodoView> {
  late final EditTodoViewModel _viewModel;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _viewModel = EditTodoViewModel(
      ModelProvider.todoModelOf(context),
      ModelProvider.memberModelOf(context),
      widget.todo,
    );
    _titleController = TextEditingController(text: widget.todo.title);
    _titleController.addListener(() {
      _viewModel.updateTitle(_titleController.text);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _viewModel.value.deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      if (context.mounted) {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_viewModel.value.deadline),
        );
        if (pickedTime != null) {
          final DateTime combinedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _viewModel.updateDeadline(combinedDateTime);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EditTodoViewState>(
      valueListenable: _viewModel,
      builder: (context, state, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Edit Todo',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _viewModel.isValid
                    ? () {
                        _viewModel.save();
                        Navigator.of(context).pop();
                      }
                    : null,
                child: const Text('Save'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.grey),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              MemberSelectField(
                members: state.availableMembers,
                selectedMember: state.assignee,
                onChanged: _viewModel.updateAssignee,
              ),
              const SizedBox(height: 24),
              Text(
                'Estimated Hours: ${state.estimatedHours}',
                style: TextStyle(
                  color: Colors.grey[400],
                ),
              ),
              Slider(
                value: state.estimatedHours,
                min: 0.5,
                max: 8.0,
                divisions: 15,
                label: state.estimatedHours.toString(),
                onChanged: _viewModel.updateEstimatedHours,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _showDatePicker(context),
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  'Deadline: ${state.formattedDeadline}',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
