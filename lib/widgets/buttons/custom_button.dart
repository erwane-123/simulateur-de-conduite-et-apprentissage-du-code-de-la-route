import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

enum ButtonVariant { primary, secondary, success, danger }

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final bool loading;
  final bool disabled;
  final Widget? icon;
  final double? width;

  const CustomButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.loading = false,
    this.disabled = false,
    this.icon,
    this.width,
  }) : super(key: key);

  LinearGradient get _gradient {
    switch (variant) {
      case ButtonVariant.success: return AppGradients.success;
      case ButtonVariant.danger: return AppGradients.danger;
      default: return AppGradients.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || loading;
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        width: width,
        height: 56,
        decoration: variant == ButtonVariant.secondary
            ? BoxDecoration(color: AppColors.bgElevated, borderRadius: BorderRadius.circular(12))
            : BoxDecoration(
                gradient: _gradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
              ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)))
                  else ...[
                    if (icon != null) ...[icon!, const SizedBox(width: 8)],
                    Text(title, style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: variant == ButtonVariant.secondary ? AppColors.textPrimary : AppColors.white,
                    )),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
