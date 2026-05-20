import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/style/colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height = 52,
    this.gradient,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double height;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (isLoading) {
      child = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: ColorManager.darkTextPrimary,
        ),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: ColorManager.darkTextPrimary),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: ColorManager.darkTextPrimary),
          ),
        ],
      );
    } else {
      child = Text(
        text,
        style: const TextStyle(color: ColorManager.darkTextPrimary),
      );
    }

    if (gradient != null && !isOutlined) {
      return GradientButton(
        text: text,
        onPressed: onPressed,
        isLoading: isLoading,
        icon: icon,
        width: width,
        height: height,
        gradient: gradient,
      );
    }

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
  });

  final String text;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: color ?? colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
    this.gradient,
    this.borderRadius = 16,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final Gradient? gradient;
  final double borderRadius;

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (isLoading) {
      child = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: ColorManager.darkTextPrimary,
        ),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: ColorManager.darkTextPrimary),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ColorManager.darkTextPrimary,
            ),
          ),
        ],
      );
    } else {
      child = Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: ColorManager.darkTextPrimary,
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isLoading ? null : (gradient ?? purpleGradient),
          borderRadius: BorderRadius.circular(borderRadius),
          color: isLoading ? ColorManager.darkTextDisabled : null,
        ),
        child: Material(
          color: const Color(0x00000000),
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
