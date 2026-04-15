import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/providers/auth_providers.dart';
import '../../../presentation/providers/biometric_auth_provider.dart';

/// Settings screen with a toggle for enabling/disabling biometric authentication.
///
/// Requirements: 17.6
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isTogglingBiometric = false;

  Future<void> _toggleBiometric(BiometricState biometricState) async {
    if (_isTogglingBiometric) return;

    final notifier = ref.read(biometricAuthProvider.notifier);

    if (biometricState.isEnabled) {
      // Disable: just clear credentials and update setting
      setState(() => _isTogglingBiometric = true);
      try {
        await notifier.disable();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric sign-in disabled')),
          );
        }
      } finally {
        if (mounted) setState(() => _isTogglingBiometric = false);
      }
    } else {
      // Enable: need current credentials to store them
      await _showEnableBiometricDialog(notifier);
    }
  }

  Future<void> _showEnableBiometricDialog(BiometricAuthNotifier notifier) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscure = true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Enable Biometric Sign-in'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your credentials once to enable biometric sign-in.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter your email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setDialogState(() => obscure = !obscure),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter your password' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop(true);
                }
              },
              child: const Text('Enable'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isTogglingBiometric = true);
    try {
      await notifier.enable(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric sign-in enabled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to enable biometrics: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingBiometric = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final biometricAsync = ref.watch(biometricAuthProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          // Security section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Security',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          biometricAsync.when(
            loading: () => const ListTile(
              leading: Icon(Icons.fingerprint),
              title: Text('Biometric Sign-in'),
              trailing: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const ListTile(
              leading: Icon(Icons.fingerprint),
              title: Text('Biometric Sign-in'),
              subtitle: Text('Not available on this device'),
              enabled: false,
            ),
            data: (state) {
              if (!state.isAvailable) {
                return const ListTile(
                  leading: Icon(Icons.fingerprint),
                  title: Text('Biometric Sign-in'),
                  subtitle: Text('Not available on this device'),
                  enabled: false,
                );
              }

              return SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: const Text('Biometric Sign-in'),
                subtitle: Text(
                  state.isEnabled
                      ? 'Use fingerprint or face ID to sign in'
                      : 'Enable to sign in with fingerprint or face ID',
                ),
                value: state.isEnabled,
                onChanged: _isTogglingBiometric
                    ? null
                    : (_) => _toggleBiometric(state),
              );
            },
          ),
          const Divider(),

          // Account section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Account',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () async {
              final authRepository = ref.read(authRepositoryProvider);
              await authRepository.signOut();
            },
          ),
        ],
      ),
    );
  }
}
