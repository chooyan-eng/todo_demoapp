import 'package:todo_demoapp/model_provider.dart';
import 'package:flutter/material.dart';
import 'package:todo_demoapp/view_model/add_todo_view_model.dart';
import 'package:todo_demoapp/view/member_select_field.dart';

class AddTodoDialog extends StatefulWidget {
  const AddTodoDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => const AddTodoDialog(),
    );
  }

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  late final AddTodoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddTodoViewModel(
      ModelProvider.todoModelOf(context),
      ModelProvider.memberModelOf(context),
    );
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
          final combinedDateTime = DateTime(
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
    return Dialog(
      child: ValueListenableBuilder<AddTodoViewState>(
        valueListenable: _viewModel,
        builder: (context, state, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Todo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: Navigator.of(context).pop,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: _viewModel.updateTitle,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter new todo',
                    prefixIcon: Icon(Icons.task_alt),
                  ),
                ),
                const SizedBox(height: 16),
                MemberSelectField(
                  members: state.availableMembers,
                  selectedMember: state.assignee,
                  onChanged: _viewModel.updateAssignee,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Hours: ${state.estimatedHours}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Slider(
                      value: state.estimatedHours,
                      min: 0.5,
                      max: 8.0,
                      divisions: 15,
                      label: state.estimatedHours.toString(),
                      onChanged: _viewModel.updateEstimatedHours,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _showDatePicker(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        'Deadline: ${state.formattedDeadline}',
                      ),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _viewModel.isValid
                            ? () {
                                final succeeded = _viewModel.save();
                                if (succeeded) {
                                  Navigator.of(context).pop();
                                }
                              }
                            : null,
                        child: const Text('Add Todo'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
