import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_utils.dart';

/// Shows an adaptive alert dialog.
///
/// Renders a [CupertinoAlertDialog] on iOS and an [AlertDialog] on Android/web.
///
/// Requirements: 17.2, 17.7
Future<void> showAdaptiveAlert({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'OK',
  VoidCallback? onConfirm,
}) {
  if (PlatformUtils.useCupertino) {
    return showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm?.call();
            },
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            onConfirm?.call();
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

/// Shows an adaptive confirmation dialog with confirm and cancel actions.
///
/// Returns `true` if the user confirmed, `false` otherwise.
///
/// Requirements: 17.2, 17.7
Future<bool> showAdaptiveConfirmation({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) async {
  if (PlatformUtils.useCupertino) {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: isDestructive
              ? TextButton.styleFrom(foregroundColor: Colors.red)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Adaptive dialog widget for custom content dialogs.
///
/// Renders a [CupertinoAlertDialog] on iOS and a [Dialog] on Android/web.
class AdaptiveDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<AdaptiveDialogAction> actions;

  const AdaptiveDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.useCupertino) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: content,
        actions: actions
            .map(
              (a) => CupertinoDialogAction(
                isDefaultAction: a.isDefault,
                isDestructiveAction: a.isDestructive,
                onPressed: a.onPressed,
                child: Text(a.label),
              ),
            )
            .toList(),
      );
    }

    return AlertDialog(
      title: Text(title),
      content: content,
      actions: actions
          .map(
            (a) => TextButton(
              onPressed: a.onPressed,
              style: a.isDestructive
                  ? TextButton.styleFrom(foregroundColor: Colors.red)
                  : null,
              child: Text(a.label),
            ),
          )
          .toList(),
    );
  }
}

/// Represents an action button in an [AdaptiveDialog].
class AdaptiveDialogAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isDefault;
  final bool isDestructive;

  const AdaptiveDialogAction({
    required this.label,
    this.onPressed,
    this.isDefault = false,
    this.isDestructive = false,
  });
}
