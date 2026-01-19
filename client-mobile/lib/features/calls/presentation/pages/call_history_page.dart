/// Call History Page
///
/// Displays list of past calls with filtering options.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/entities.dart';
import '../bloc/call_history_bloc.dart';

/// Page displaying call history
class CallHistoryPage extends StatefulWidget {
  const CallHistoryPage({super.key});

  static const routeName = '/call-history';

  @override
  State<CallHistoryPage> createState() => _CallHistoryPageState();
}

class _CallHistoryPageState extends State<CallHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<CallHistoryBloc>().add(const LoadCallHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearHistoryDialog(context),
            tooltip: 'Clear history',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(),
          // Call list
          Expanded(
            child: BlocBuilder<CallHistoryBloc, CallHistoryState>(
              builder: (context, state) {
                return switch (state) {
                  CallHistoryInitial() ||
                  CallHistoryLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  CallHistoryError(message: final msg) =>
                    Center(child: Text('Error: $msg')),
                  CallHistoryLoaded() => _buildCallList(state),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter tabs
  Widget _buildFilterTabs() {
    return BlocBuilder<CallHistoryBloc, CallHistoryState>(
      buildWhen: (prev, curr) {
        if (prev is! CallHistoryLoaded || curr is! CallHistoryLoaded) {
          return true;
        }
        return prev.filter != curr.filter;
      },
      builder: (context, state) {
        final currentFilter = state is CallHistoryLoaded
            ? state.filter
            : CallHistoryFilter.all;

        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: CallHistoryFilter.values.map((filter) {
              final isSelected = filter == currentFilter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_getFilterLabel(filter)),
                  selected: isSelected,
                  onSelected: (_) {
                    context
                        .read<CallHistoryBloc>()
                        .add(ChangeFilterEvent(filter));
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Build call list
  Widget _buildCallList(CallHistoryLoaded state) {
    final calls = state.filteredCalls;

    if (calls.isEmpty) {
      return _buildEmptyState(state.filter);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<CallHistoryBloc>().add(const RefreshCallHistoryEvent());
      },
      child: ListView.builder(
        itemCount: calls.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= calls.length) {
            // Load more indicator
            if (!state.isLoadingMore) {
              context.read<CallHistoryBloc>().add(const LoadMoreCallsEvent());
            }
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return _CallHistoryItem(
            call: calls[index],
            onTap: () => _onCallTap(calls[index]),
            onDismiss: () => _onCallDismiss(calls[index]),
          );
        },
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(CallHistoryFilter filter) {
    final message = switch (filter) {
      CallHistoryFilter.all => 'No calls yet',
      CallHistoryFilter.missed => 'No missed calls',
      CallHistoryFilter.incoming => 'No incoming calls',
      CallHistoryFilter.outgoing => 'No outgoing calls',
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.call,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Get filter label
  String _getFilterLabel(CallHistoryFilter filter) {
    return switch (filter) {
      CallHistoryFilter.all => 'All',
      CallHistoryFilter.missed => 'Missed',
      CallHistoryFilter.incoming => 'Incoming',
      CallHistoryFilter.outgoing => 'Outgoing',
    };
  }

  /// Handle call tap (callback)
  void _onCallTap(Call call) {
    // TODO: Navigate to call or initiate new call
    debugPrint('Tapped call: ${call.id}');
  }

  /// Handle call dismiss (delete)
  void _onCallDismiss(Call call) {
    context.read<CallHistoryBloc>().add(DeleteCallEvent(call.id));
  }

  /// Show clear history dialog
  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Call History'),
        content:
            const Text('Are you sure you want to delete all call history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CallHistoryBloc>().add(const ClearHistoryEvent());
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single call history item
class _CallHistoryItem extends StatelessWidget {
  final Call call;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const _CallHistoryItem({
    required this.call,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isMissed = call.endReason == CallEndReason.noAnswer ||
        call.endReason == CallEndReason.declined;

    return Dismissible(
      key: Key(call.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: call.remoteUserAvatar != null
                  ? NetworkImage(call.remoteUserAvatar!)
                  : null,
              child: call.remoteUserAvatar == null
                  ? Text(
                      _getInitials(call.remoteUserName ?? '?'),
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  call.isVideoCall ? Icons.videocam : Icons.call,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                call.remoteUserName ?? 'Unknown',
                style: TextStyle(
                  fontWeight: isMissed ? FontWeight.bold : FontWeight.normal,
                  color: isMissed ? Colors.red : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            _buildDirectionIcon(),
            const SizedBox(width: 4),
            Text(
              _formatCallInfo(),
              style: TextStyle(
                color: isMissed ? Colors.red.shade300 : null,
              ),
            ),
          ],
        ),
        trailing: Text(
          _formatTime(call.initiatedAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionIcon() {
    final IconData icon;
    final Color color;

    if (call.direction == CallDirection.incoming) {
      if (call.endReason == CallEndReason.noAnswer) {
        icon = Icons.call_missed;
        color = Colors.red;
      } else {
        icon = Icons.call_received;
        color = Colors.green;
      }
    } else {
      if (call.endReason == CallEndReason.noAnswer) {
        icon = Icons.call_missed_outgoing;
        color = Colors.orange;
      } else {
        icon = Icons.call_made;
        color = Colors.blue;
      }
    }

    return Icon(icon, size: 16, color: color);
  }

  String _formatCallInfo() {
    if (call.durationSeconds != null && call.durationSeconds! > 0) {
      final duration = Duration(seconds: call.durationSeconds!);
      if (duration.inHours > 0) {
        return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
      } else if (duration.inMinutes > 0) {
        return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
      }
      return '${duration.inSeconds}s';
    }
    return call.endReason?.message ?? 'No answer';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      return DateFormat.jm().format(time);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return DateFormat.EEEE().format(time);
    }
    return DateFormat.MMMd().format(time);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}
