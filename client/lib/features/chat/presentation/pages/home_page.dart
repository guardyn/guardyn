import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guardyn_client/core/di/injection.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_state.dart';
import 'package:guardyn_client/features/groups/presentation/bloc/group_bloc.dart';
import 'package:guardyn_client/features/groups/presentation/pages/group_list_page.dart';
import 'package:guardyn_client/features/messaging/presentation/bloc/message_bloc.dart';
import 'package:guardyn_client/features/messaging/presentation/pages/conversation_list_page.dart';

/// Home page with navigation to conversations and groups
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasNavigated = false;
  late final AuthBloc _authBloc;
  StreamSubscription<AuthState>? _authSubscription;
  AuthState? _currentAuthState;

  @override
  void initState() {
    super.initState();
    _authBloc = context.read<AuthBloc>();
    _currentAuthState = _authBloc.state;

    // Use stream subscription instead of BlocListener to avoid
    // InheritedWidget dependency issues during navigation
    _authSubscription = _authBloc.stream.listen(_handleAuthStateChange);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _authSubscription = null;
    super.dispose();
  }

  void _handleAuthStateChange(AuthState state) {
    if (_hasNavigated || !mounted) return;

    setState(() {
      _currentAuthState = state;
    });

    if (state is AuthUnauthenticated) {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    _authSubscription?.cancel();
    _authSubscription = null;

    Future.microtask(() {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasNavigated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardyn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authBloc.add(AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final state = _currentAuthState;
    if (state is AuthAuthenticated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/logo.svg', width: 100, height: 100),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Guardyn!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Logged in as: ${state.user.username}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'User ID: ${state.user.userId}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              'Device ID: ${state.user.deviceId}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => getIt<MessageBloc>(),
                      child: const ConversationListPage(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.message),
              label: const Text('Open Messages'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => getIt<GroupBloc>(),
                      child: const GroupListPage(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.group),
              label: const Text('Open Groups'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
