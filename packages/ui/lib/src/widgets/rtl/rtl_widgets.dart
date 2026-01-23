// =============================================================================
// RTL-AWARE WRAPPER
// =============================================================================
// Automatische RTL-Unterstützung für Arabisch und andere RTL-Sprachen.
// Wraps Widget-Tree mit korrekter TextDirection.
// =============================================================================

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Wrapper für RTL-Unterstützung
/// Verwendet automatisch die korrekte TextDirection basierend auf Locale
class RtlAwareWidget extends StatelessWidget {
  final Widget child;

  const RtlAwareWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = SanadLocalizations.of(context);

    return Directionality(
      textDirection: l10n.textDirection,
      child: child,
    );
  }
}

/// Extension für einfaches RTL-Wrapping
extension RtlExtension on Widget {
  Widget withRtlSupport(BuildContext context) {
    return RtlAwareWidget(child: this);
  }
}

/// Padding, das RTL-aware ist
class RtlPadding extends StatelessWidget {
  final Widget child;
  final double? start;
  final double? end;
  final double? top;
  final double? bottom;

  const RtlPadding({
    super.key,
    required this.child,
    this.start,
    this.end,
    this.top,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: start ?? 0,
        end: end ?? 0,
        top: top ?? 0,
        bottom: bottom ?? 0,
      ),
      child: child,
    );
  }
}

/// Row, die automatisch in RTL-Kontext reversed wird
class RtlRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const RtlRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: Directionality.of(context),
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

/// Icon, das in RTL automatisch gespiegelt wird (z.B. Pfeile)
class RtlIcon extends StatelessWidget {
  final IconData icon;
  final IconData? rtlIcon;
  final double? size;
  final Color? color;

  const RtlIcon({
    super.key,
    required this.icon,
    this.rtlIcon,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final displayIcon = isRtl && rtlIcon != null ? rtlIcon! : icon;

    return Transform.scale(
      scaleX: isRtl && rtlIcon == null ? -1.0 : 1.0,
      child: Icon(displayIcon, size: size, color: color),
    );
  }
}

/// Häufig verwendete RTL-Icons
class RtlIcons {
  static Widget arrowForward({double? size, Color? color}) => RtlIcon(
        icon: Icons.arrow_forward,
        rtlIcon: Icons.arrow_back,
        size: size,
        color: color,
      );

  static Widget arrowBack({double? size, Color? color}) => RtlIcon(
        icon: Icons.arrow_back,
        rtlIcon: Icons.arrow_forward,
        size: size,
        color: color,
      );

  static Widget chevronRight({double? size, Color? color}) => RtlIcon(
        icon: Icons.chevron_right,
        rtlIcon: Icons.chevron_left,
        size: size,
        color: color,
      );

  static Widget chevronLeft({double? size, Color? color}) => RtlIcon(
        icon: Icons.chevron_left,
        rtlIcon: Icons.chevron_right,
        size: size,
        color: color,
      );
}

/// Alignment-Helper für RTL
class RtlAlignment {
  static AlignmentDirectional get start => AlignmentDirectional.centerStart;
  static AlignmentDirectional get end => AlignmentDirectional.centerEnd;
  static AlignmentDirectional get topStart => AlignmentDirectional.topStart;
  static AlignmentDirectional get topEnd => AlignmentDirectional.topEnd;
  static AlignmentDirectional get bottomStart =>
      AlignmentDirectional.bottomStart;
  static AlignmentDirectional get bottomEnd => AlignmentDirectional.bottomEnd;
}
