import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardyn_client/features/auth/presentation/bloc/auth_state.dart';

/// Settings page with account management options
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _hasNavigated = false;
  bool _showedDeleteMessage = false;

  void _navigateToLogin() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    // Schedule navigation for the next frame to avoid widget lifecycle conflicts
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // Stop listening once we've navigated
      listenWhen: (previous, current) => !_hasNavigated,
      listener: (context, state) {
        if (_hasNavigated || !mounted) return;

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is AuthUnauthenticated) {
          final message = state.message;
          if (message != null && !_showedDeleteMessage) {
            _showedDeleteMessage = true;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          // Navigate to login page
          _navigateToLogin();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isDeleting = state is AuthAccountDeleting;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Account section
                _buildSectionHeader('Account'),
                const SizedBox(height: 8),

                // Logout button
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  subtitle: const Text('Sign out from this device'),
                  onTap: isDeleting ? null : () => _showLogoutDialog(context),
                ),

                const Divider(),

                // Danger zone
                _buildSectionHeader('Danger Zone', color: Colors.red),
                const SizedBox(height: 8),

                // Delete account button
                Card(
                  color: Colors.red.shade50,
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_forever,
                      color: Colors.red.shade700,
                    ),
                    title: Text(
                      'Delete Account',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Permanently delete your account and all data',
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                    trailing: isDeleting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.red.shade700,
                          ),
                    onTap: isDeleting
                        ? null
                        : () => _showDeleteAccountDialog(context),
                  ),
                ),

                const SizedBox(height: 16),

                // Warning text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.amber.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Deleting your account is permanent and cannot be undone. All your messages, conversations, and data will be erased.',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color ?? Colors.grey.shade700,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    // Capture the bloc reference before showing the dialog
    final authBloc = context.read<AuthBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Use pre-captured bloc reference to avoid context issues
              authBloc.add(AuthLogoutRequested());
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;

    // We dispose the controller only after the dialog is fully closed to
    // avoid rebuilds referencing a disposed notifier during animations.
    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade700),
              const SizedBox(width: 8),
              const Text('Delete Account'),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This action is PERMANENT and cannot be undone!',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('The following data will be permanently deleted:'),
                const SizedBox(height: 8),
                const Text('• Your profile and account information'),
                const Text('• All your messages and conversations'),
                const Text('• All your encryption keys'),
                const Text('• All group memberships'),
                const SizedBox(height: 16),
                const Text(
                  'Enter your password to confirm:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password too short';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final pwd = passwordController.text;
                  Navigator.pop(dialogContext, pwd);
                }
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );

    // Safe disposal after the dialog lifecycle completes.
    passwordController.dispose();

    if (!mounted || password == null || password.isEmpty) {
      return;
    }

    _showFinalConfirmation(context, password);
  }

  void _showFinalConfirmation(BuildContext context, String password) {
    // Capture the bloc reference before showing the dialog
    // This ensures we can access it even after the dialog is closed
    final authBloc = context.read<AuthBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'Are you absolutely sure you want to delete your account? This action CANNOT be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No, keep my account'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Close the dialog first
              Navigator.pop(dialogContext);
              // Use the pre-captured bloc reference to dispatch the event
              // This avoids issues with context being invalid after navigation
              authBloc.add(AuthDeleteAccountRequested(password: password));
            },
            child: const Text('Yes, delete my account'),
          ),
        ],
      ),
    );
  }
}
