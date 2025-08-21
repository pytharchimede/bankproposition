import 'package:flutter/material.dart';
import '../theme.dart';

enum BduButtonType { primary, secondary }

class BduButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final BduButtonType type;
  final bool isLoading;
  final bool isDisabled;

  const BduButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = BduButtonType.primary,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = type == BduButtonType.primary
        ? BduColors.primary
        : BduColors.secondary;
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
