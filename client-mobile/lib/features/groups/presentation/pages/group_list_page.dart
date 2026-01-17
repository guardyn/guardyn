import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/group.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';
import 'group_chat_page.dart';
import 'group_create_page.dart';

/// Page showing list of user's groups
class GroupListPage extends StatelessWidget {
  const GroupListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GroupBloc>()..add(const GroupLoadAll()),
      child: const _GroupListView(),
    );
  }
}

class _GroupListView extends StatelessWidget {
  const _GroupListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCreateGroup(context),
          ),
        ],
      ),
      body: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, state) {
          if (state is GroupLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GroupError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<GroupBloc>().add(const GroupLoadAll());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is GroupListLoaded) {
            if (state.groups.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildGroupList(context, state.groups);
          }

          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateGroup(context),
        child: const Icon(Icons.group_add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No groups yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a group to start chatting',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateGroup(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Group'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList(BuildContext context, List<Group> groups) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<GroupBloc>().add(const GroupLoadAll());
      },
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return _GroupListTile(group: group);
        },
      ),
    );
  }

  void _navigateToCreateGroup(BuildContext context) {
    final bloc = context.read<GroupBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GroupCreatePage(),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh the list after creating a group
        bloc.add(const GroupLoadAll());
      }
    });
  }
}

class _GroupListTile extends StatelessWidget {
  final Group group;

  const _GroupListTile({required this.group});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(group.name),
      subtitle: Text(
        '${group.memberCount} members',
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: group.lastMessage != null
          ? Text(
              group.lastMessage!.displayTime,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupChatPage(
              groupId: group.groupId,
              groupName: group.name,
            ),
          ),
        );
      },
    );
  }
}
