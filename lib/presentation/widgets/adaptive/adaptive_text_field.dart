import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_utils.dart';

/// Adaptive text field widget that renders a [CupertinoTextField] on iOS
/// and a [TextFormField] on Android/web.
///
/// Requirements: 17.2, 17.7
class AdaptiveTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int? maxLines;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;

  const AdaptiveTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.focusNode,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.useCupertino) {
      return CupertinoTextField(
        controller: controller,
        placeholder: placeholder ?? labelText,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        enabled: enabled,
        maxLines: obscureText ? 1 : maxLines,
        focusNode: focusNode,
        onEditingComplete: onEditingComplete,
        prefix: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: prefixIcon,
              )
            : null,
        suffix: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: suffixIcon,
              )
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          border: Border.all(
            color: CupertinoColors.systemGrey4,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      focusNode: focusNode,
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: placeholder,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
