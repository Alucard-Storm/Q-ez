import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/connectivity_provider.dart';

/// Wraps [child] with an animated offline indicator banner.
///
/// When the device loses connectivity a yellow banner slides in at the top
/// of the screen. It disappears automatically when connectivity is restored.
///
/// Usage — wrap your root scaffold or navigator:
/// ```dart
/// OfflineBanner(child: MyScaffold())
/// ```
class OfflineBanner extends ConsumerWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isOnline ? 0 : 32,
          color: Colors.orange.shade700,
          child: isOnline
              ? const SizedBox.shrink()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'No internet connection',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
