import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AgexLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool darkVariant;

  const AgexLogo({
    super.key,
    this.size = 72,
    this.showText = false,
    this.darkVariant = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glow ring
        Container(
          width: size + 8,
          height: size + 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.brand400.withOpacity(0.15),
          ),
          alignment: Alignment.center,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4ADE80), Color(0xFF22C55E), Color(0xFF15803D)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x2615803D),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Leaf icon
                Icon(
                  Icons.eco_rounded,
                  size: size * 0.5,
                  color: Colors.white.withOpacity(0.92),
                ),
                // Small accent dot
                Positioned(
                  top: size * 0.18,
                  right: size * 0.22,
                  child: Container(
                    width: size * 0.08,
                    height: size * 0.08,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: size * 0.34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(
                  text: 'Ag',
                  style: TextStyle(
                    color: darkVariant ? AppColors.brand900 : Colors.white,
                  ),
                ),
                const TextSpan(
                  text: 'Ex',
                  style: TextStyle(color: Color(0xFF22C55E)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
