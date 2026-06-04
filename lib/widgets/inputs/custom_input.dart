import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomInput extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final Widget? prefixIcon;
  final Function(String)? onChanged;

  const CustomInput({
    Key? key, this.label, this.placeholder,
    required this.controller, this.obscureText = false,
    this.keyboardType = TextInputType.text, this.errorText,
    this.prefixIcon, this.onChanged,
  }) : super(key: key);

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _isFocused = false;
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
        ],
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? AppColors.danger : _isFocused ? AppColors.primary : AppColors.border,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null) Padding(padding: const EdgeInsets.only(left: 16, right: 8), child: widget.prefixIcon),
              Expanded(
                child: Focus(
                  onFocusChange: (v) => setState(() => _isFocused = v),
                  child: TextField(
                    controller: widget.controller,
                    obscureText: widget.obscureText && !_showPassword,
                    keyboardType: widget.keyboardType,
                    onChanged: widget.onChanged,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ),
              if (widget.obscureText)
                IconButton(
                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(widget.errorText!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
