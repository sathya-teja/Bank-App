import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:lucide_icons/lucide_icons.dart'; // lightweight modern icon pack

class BalanceCard extends StatelessWidget {
  final String title;
  final double balance;
  final String currency;

  const BalanceCard({
    super.key,
    required this.title,
    required this.balance,
    this.currency = '₹',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    // Gradient based on theme
    final gradientColors = isDark
        ? [
            colorScheme.surfaceVariant.withOpacity(0.4),
            colorScheme.primary.withOpacity(0.5),
          ]
        : const [
            Color(0xFF0D1B2A),
            Color(0xFF1B998B),
          ];

    final titleColor = isDark
        ? colorScheme.onSurfaceVariant.withOpacity(0.9)
        : Colors.white70;
    final valueColor = isDark ? colorScheme.onPrimary : Colors.white;

    return Neumorphic(
      style: NeumorphicStyle(
        depth: isDark ? 1.5 : 4,
        intensity: isDark ? 0.35 : 0.7,
        surfaceIntensity: isDark ? 0.15 : 0.25,
        lightSource: LightSource.topLeft,
        color: isDark ? colorScheme.surface : null,
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.all(Radius.circular(20)),
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: Stack(
          children: [
            // Decorative translucent circle (gives illustration-like vibe)
            Positioned(
              right: -30,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(isDark ? 0.05 : 0.15),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(isDark ? 0.15 : 0.1),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: title + wallet icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        LucideIcons.wallet2,
                        color: isDark
                            ? colorScheme.primary.withOpacity(0.8)
                            : Colors.white.withOpacity(0.9),
                        size: 28,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Balance text
                  Text(
                    '$currency ${balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Small subtitle
                  Text(
                    'Available balance',
                    style: TextStyle(
                      fontSize: 13,
                      color: valueColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
