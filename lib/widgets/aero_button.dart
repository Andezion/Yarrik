import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

enum AeroButtonVariant { primary, ghost, danger }

class AeroButton extends StatefulWidget {
  const AeroButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AeroButtonVariant.primary,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AeroButtonVariant variant;
  final bool expand;

  @override
  State<AeroButton> createState() => _AeroButtonState();
}

class _AeroButtonState extends State<AeroButton> {
  bool _down = false;

  _AeroPalette get _palette => switch (widget.variant) {
        AeroButtonVariant.primary => _AeroPalette(
            colors: const [Color(0xFF8CE8FF), Color(0xFF38D6FF), Color(0xFF0FB2E8), Color(0xFF48D2F6)],
            stops: const [0, 0.48, 0.52, 1],
            border: AppColors.aquaDeep.withValues(alpha: 0.55),
            textColor: Colors.white,
            glow: AppColors.aqua.withValues(alpha: 0.55),
            shadow: AppColors.aquaDeep.withValues(alpha: 0.45),
          ),
        AeroButtonVariant.danger => _AeroPalette(
            colors: const [Color(0xFFFFB4A6), Color(0xFFF2705C), Color(0xFFE14B38), Color(0xFFF58A78)],
            stops: const [0, 0.48, 0.52, 1],
            border: const Color(0xFFBE3728).withValues(alpha: 0.5),
            textColor: Colors.white,
            glow: const Color(0xFFFF8C78).withValues(alpha: 0.5),
            shadow: AppColors.red.withValues(alpha: 0.4),
          ),
        AeroButtonVariant.ghost => _AeroPalette(
            colors: [Colors.white.withValues(alpha: 0.97), const Color(0xFFF0FBFF).withValues(alpha: 0.7), const Color(0xFFE0F6FF).withValues(alpha: 0.8)],
            stops: const [0, 0.5, 1],
            border: AppColors.sky.withValues(alpha: 0.85),
            textColor: AppColors.aquaText,
            glow: AppColors.sky.withValues(alpha: 0.35),
            shadow: AppColors.blue.withValues(alpha: 0.15),
          ),
      };

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final palette = _palette;
    final scale = _down && enabled ? 0.97 : 1.0;

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 18, color: palette.textColor),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              color: palette.textColor,
              shadows: widget.variant == AeroButtonVariant.ghost
                  ? null
                  : [Shadow(color: palette.shadow, blurRadius: 2, offset: const Offset(0, 1))],
            ),
          ),
        ),
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(99),
              splashColor: Colors.white.withValues(alpha: 0.25),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: palette.colors,
                    stops: palette.stops,
                  ),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: palette.border),
                  boxShadow: [
                    BoxShadow(color: palette.shadow, blurRadius: 16, offset: const Offset(0, 6)),
                    BoxShadow(color: palette.glow, blurRadius: 18, spreadRadius: -6),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AeroPalette {
  const _AeroPalette({
    required this.colors,
    required this.stops,
    required this.border,
    required this.textColor,
    required this.glow,
    required this.shadow,
  });

  final List<Color> colors;
  final List<double> stops;
  final Color border;
  final Color textColor;
  final Color glow;
  final Color shadow;
}

class AeroIconButton extends StatelessWidget {
  const AeroIconButton({super.key, required this.icon, this.onTap, this.size = 36});

  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withValues(alpha: 0.97), const Color(0xFFE8F8FF).withValues(alpha: 0.75)],
            ),
            border: Border.all(color: AppColors.sky.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(color: AppColors.blue.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Icon(icon, size: size * 0.46, color: AppColors.muted),
        ),
      ),
    );
  }
}

class AeroChip extends StatelessWidget {
  const AeroChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.accentColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor;
    final selectedBg = accent?.withValues(alpha: 0.16);
    final selectedBorder = accent ?? AppColors.aquaDeep;
    final selectedText = accent ?? Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: selected && accent == null
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFA9EEFF), Color(0xFF4FD4F8), Color(0xFF17B2E8), Color(0xFF5CD8F8)],
                    stops: [0, 0.48, 0.52, 1],
                  )
                : null,
            color: selected && accent != null ? selectedBg : (selected ? null : Colors.white.withValues(alpha: 0.65)),
            border: Border.all(
              color: selected ? selectedBorder.withValues(alpha: accent != null ? 0.7 : 0.5) : AppColors.line2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: (accent ?? AppColors.aqua).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: selected ? (accent != null ? selectedText : Colors.white) : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
