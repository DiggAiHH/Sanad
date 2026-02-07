// =============================================================================
// ACCESSIBILITY WIDGETS - WCAG 2.1 AA COMPLIANCE
// =============================================================================
// Barrierefreie Widgets für Screenreader, hohen Kontrast und
// Motor-/Sehbehinderungen. WCAG 2.1 Level AA konform.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility Settings Provider
class AccessibilitySettings extends InheritedWidget {
  final bool highContrast;
  final double textScaleFactor;
  final bool reduceMotion;
  final bool screenReaderMode;

  const AccessibilitySettings({
    super.key,
    required super.child,
    this.highContrast = false,
    this.textScaleFactor = 1.0,
    this.reduceMotion = false,
    this.screenReaderMode = false,
  });

  static AccessibilitySettings? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AccessibilitySettings>();
  }

  @override
  bool updateShouldNotify(AccessibilitySettings oldWidget) {
    return highContrast != oldWidget.highContrast ||
        textScaleFactor != oldWidget.textScaleFactor ||
        reduceMotion != oldWidget.reduceMotion ||
        screenReaderMode != oldWidget.screenReaderMode;
  }
}

/// Semantically labeled button with minimum touch target (48x48)
class A11yButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String semanticLabel;
  final String? semanticHint;
  final bool isDestructive;
  final bool isEnabled;

  const A11yButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.semanticLabel,
    this.semanticHint,
    this.isDestructive = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: isEnabled && onPressed != null,
      label: semanticLabel,
      hint: semanticHint,
      child: ConstrainedBox(
        // WCAG: Minimum touch target 44x44, we use 48x48 for better UX
        constraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? Colors.red : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Accessible text input with proper labeling
class A11yTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final String? errorText;
  final String? semanticLabel;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final int? maxLength;

  const A11yTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.errorText,
    this.semanticLabel,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.autofocus = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: semanticLabel ?? labelText,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        autofocus: autofocus,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          errorText: errorText,
          // WCAG: Error indication not only by color
          errorStyle: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: errorText != null
              ? const Icon(Icons.error, color: Colors.red)
              : null,
        ),
      ),
    );
  }
}

/// Card with semantic grouping for screen readers
class A11yCard extends StatelessWidget {
  final Widget child;
  final String semanticLabel;
  final VoidCallback? onTap;
  final bool isSelected;

  const A11yCard({
    super.key,
    required this.child,
    required this.semanticLabel,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      selected: isSelected,
      button: onTap != null,
      child: Card(
        elevation: isSelected ? 4 : 1,
        child: InkWell(
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

/// Image with required alt text
class A11yImage extends StatelessWidget {
  final ImageProvider image;
  final String altText;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool isDecorative;

  const A11yImage({
    super.key,
    required this.image,
    required this.altText,
    this.width,
    this.height,
    this.fit,
    this.isDecorative = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image(
      image: image,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: isDecorative ? null : altText,
    );

    if (isDecorative) {
      return ExcludeSemantics(child: imageWidget);
    }

    return Semantics(
      image: true,
      label: altText,
      child: imageWidget,
    );
  }
}

/// Progress indicator with semantic announcement
class A11yProgressIndicator extends StatelessWidget {
  final double? value;
  final String semanticLabel;
  final String? semanticValue;

  const A11yProgressIndicator({
    super.key,
    this.value,
    required this.semanticLabel,
    this.semanticValue,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = value != null ? '${(value! * 100).round()}%' : null;

    return Semantics(
      label: semanticLabel,
      value: semanticValue ?? percentage,
      child: value != null
          ? LinearProgressIndicator(value: value)
          : const CircularProgressIndicator(),
    );
  }
}

/// Live region for dynamic content announcements
class A11yLiveRegion extends StatelessWidget {
  final Widget child;
  final String announcement;
  final bool isPolite;

  const A11yLiveRegion({
    super.key,
    required this.child,
    required this.announcement,
    this.isPolite = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: announcement,
      child: child,
    );
  }
}

/// Accessible heading for sections
class A11yHeading extends StatelessWidget {
  final String text;
  final int level;
  final TextStyle? style;

  const A11yHeading({
    super.key,
    required this.text,
    this.level = 1,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = switch (level) {
      1 => Theme.of(context).textTheme.headlineLarge,
      2 => Theme.of(context).textTheme.headlineMedium,
      3 => Theme.of(context).textTheme.headlineSmall,
      4 => Theme.of(context).textTheme.titleLarge,
      5 => Theme.of(context).textTheme.titleMedium,
      _ => Theme.of(context).textTheme.titleSmall,
    };

    return Semantics(
      header: true,
      child: Text(
        text,
        style: style ?? defaultStyle,
      ),
    );
  }
}

/// Skip link for keyboard navigation
class A11ySkipLink extends StatelessWidget {
  final String label;
  final VoidCallback onActivate;

  const A11ySkipLink({
    super.key,
    required this.label,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      label: label,
      child: Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            if (!hasFocus) {
              return const SizedBox.shrink();
            }
            return TextButton(
              onPressed: onActivate,
              child: Text(label),
            );
          },
        ),
      ),
    );
  }
}

/// Error summary for form validation
class A11yErrorSummary extends StatelessWidget {
  final List<String> errors;
  final String title;

  const A11yErrorSummary({
    super.key,
    required this.errors,
    this.title = 'Fehler',
  });

  @override
  Widget build(BuildContext context) {
    if (errors.isEmpty) return const SizedBox.shrink();

    return Semantics(
      liveRegion: true,
      label: '$title: ${errors.length} Fehler gefunden',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...errors.map((e) => Padding(
                  padding: const EdgeInsets.only(left: 24, top: 4),
                  child: Text('• $e'),
                )),
          ],
        ),
      ),
    );
  }
}

/// High contrast colors for accessibility
class A11yColors {
  // WCAG AA requires 4.5:1 contrast ratio for normal text
  // WCAG AA requires 3:1 contrast ratio for large text (18pt+)

  static const Color textOnLight = Color(0xFF000000);
  static const Color textOnDark = Color(0xFFFFFFFF);

  static const Color primaryHighContrast = Color(0xFF0000CC);
  static const Color errorHighContrast = Color(0xFFCC0000);
  static const Color successHighContrast = Color(0xFF006600);
  static const Color warningHighContrast = Color(0xFF996600);

  static const Color linkColor = Color(0xFF0066CC);
  static const Color visitedLinkColor = Color(0xFF660099);

  // Focus indicator - must be clearly visible
  static const Color focusIndicator = Color(0xFF0066FF);
}

/// Focus-visible wrapper for keyboard navigation
class A11yFocusHighlight extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const A11yFocusHighlight({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: hasFocus
                  ? BoxDecoration(
                      border: Border.all(
                        color: A11yColors.focusIndicator,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
