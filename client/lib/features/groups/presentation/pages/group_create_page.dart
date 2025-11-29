import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';

/// Page for creating a new group
class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({super.key});

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _membersController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _membersController.dispose();
    super.dispose();
  }

  List<String> _parseMembers(String input) {
    return input
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  void _handleCreate(BuildContext blocContext) {
    if (!_formKey.currentState!.validate()) return;

    final memberUserIds = _parseMembers(_membersController.text);

    blocContext.read<GroupBloc>().add(GroupCreate(
          name: _nameController.text.trim(),
          memberUserIds: memberUserIds,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GroupBloc>(),
      child: Builder(
        builder: (blocContext) => Scaffold(
          appBar: AppBar(
            title: const Text('Create Group'),
          ),
          body: BlocConsumer<GroupBloc, GroupState>(
            listener: (context, state) {
              if (state is GroupCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Group "${state.group.name}" created!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true);
              }
              if (state is GroupError) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              if (state is GroupLoading) {
                setState(() => _isLoading = true);
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Group icon placeholder
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Theme.of(context).primaryColor.withAlpha(51),
                          child: Icon(
                            Icons.group,
                            size: 50,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Group name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Group Name',
                          hintText: 'Enter group name',
                          prefixIcon: Icon(Icons.edit),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a group name';
                          }
                          if (value.trim().length < 3) {
                            return 'Group name must be at least 3 characters';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Members field
                      TextFormField(
                        controller: _membersController,
                        decoration: const InputDecoration(
                          labelText: 'Members (optional)',
                          hintText:
                              'Enter user IDs separated by commas',
                          prefixIcon: Icon(Icons.people),
                          border: OutlineInputBorder(),
                          helperText:
                              'Leave empty to create a group with just yourself',
                        ),
                        maxLines: 2,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 8),

                      // Info text
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You will be added as the group admin. '
                                  'You can add more members later.',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Create button
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _handleCreate(blocContext),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Create Group',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
