import 'package:flutter/cupertino.dart';

/// Custom text field with iOS-style design
class CustomTextField extends StatelessWidget {
  final String? placeholder;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefix;
  final Widget? suffix;
  final EdgeInsetsGeometry? padding;
  final String? errorText;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.placeholder,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.maxLength,
    this.prefix,
    this.suffix,
    this.padding,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: enabled 
                ? CupertinoColors.systemBackground 
                : CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null 
                  ? CupertinoColors.systemRed 
                  : CupertinoColors.systemGrey4,
            ),
          ),
          child: Row(
            children: [
              if (prefix != null) ...[
                prefix!,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: CupertinoTextField(
                  controller: controller,
                  placeholder: placeholder,
                  onChanged: onChanged,
                  onTap: onTap,
                  readOnly: readOnly,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  textCapitalization: textCapitalization,
                  maxLines: maxLines,
                  maxLength: maxLength,
                  enabled: enabled,
                  decoration: const BoxDecoration(),
                  padding: EdgeInsets.zero,
                  style: const TextStyle(
                    fontSize: 17,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 8),
                suffix!,
              ],
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontSize: 13,
                color: CupertinoColors.systemRed,
              ),
            ),
          ),
        ],
      ],
    );
}

/// Multi-line text field variant
class CustomTextArea extends StatelessWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int maxLines;
  final String? errorText;
  final bool enabled;

  const CustomTextArea({
    super.key,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 6,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => CustomTextField(
      placeholder: placeholder,
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      errorText: errorText,
      enabled: enabled,
      padding: const EdgeInsets.all(16),
    );
}

/// Search field variant
class CustomSearchField extends StatelessWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const CustomSearchField({
    super.key,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) => CustomTextField(
      placeholder: placeholder ?? 'Search',
      controller: controller,
      onChanged: onChanged,
      prefix: const Icon(
        CupertinoIcons.search,
        color: CupertinoColors.systemGrey,
        size: 20,
      ),
      suffix: controller?.text.isNotEmpty == true
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
              child: const Icon(
                CupertinoIcons.clear_circled_solid,
                color: CupertinoColors.systemGrey,
                size: 20,
              ),
            )
          : null,
    );
}
