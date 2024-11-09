import 'package:flutter/material.dart';
import 'package:todo_demoapp/model/member.dart';
import 'package:todo_demoapp/view_model/member_list_view_model.dart';
import 'package:todo_demoapp/model_provider.dart';

class MemberListView extends StatefulWidget {
  const MemberListView({super.key});

  @override
  State<MemberListView> createState() => _MemberListViewState();
}

class _MemberListViewState extends State<MemberListView> {
  late final MemberListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MemberListViewModel(ModelProvider.memberModelOf(context));
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  IconData _getIconData(IconType iconType) {
    switch (iconType) {
      case IconType.person:
        return Icons.person;
      case IconType.work:
        return Icons.work;
      case IconType.school:
        return Icons.school;
      case IconType.home:
        return Icons.home;
      case IconType.favorite:
        return Icons.favorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Team Members',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ValueListenableBuilder<MemberListViewState>(
        valueListenable: _viewModel,
        builder: (context, state, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.members.length,
            itemBuilder: (context, index) {
              final member = state.members[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    _getIconData(member.icon),
                    color: Colors.tealAccent[400],
                  ),
                  title: Text(
                    member.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
