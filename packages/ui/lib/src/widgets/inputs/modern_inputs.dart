import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

/// Modern text input with floating label and validation
class ModernTextInput extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool autofocus;
  final int? maxLength;
  final int maxLines;
  final bool enabled;
  final TextCapitalization textCapitalization;

  const ModernTextInput({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<ModernTextInput> createState() => _ModernTextInputState();
}

class _ModernTextInputState extends State<ModernTextInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;
  bool _obscureVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (!_isFocused && widget.validator != null) {
      _validate(widget.controller?.text ?? '');
    }
  }

  void _validate(String value) {
    final error = widget.validator?.call(value);
    setState(() {
      _hasError = error != null;
      _errorText = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _hasError
        ? AppColors.error
        : _isFocused
            ? AppColors.primary
            : AppColors.divider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.enabled
                ? AppColors.surfaceVariant
                : AppColors.divider.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText && !_obscureVisible,
            keyboardType: widget.keyboardType,
            autofocus: widget.autofocus,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            enabled: widget.enabled,
            textCapitalization: widget.textCapitalization,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              counterText: '',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16, right: 12),
                      child: Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                    )
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureVisible = !_obscureVisible;
                        });
                        HapticFeedback.selectionClick();
                      },
                    )
                  : widget.suffixIcon != null
                      ? IconButton(
                          icon: Icon(
                            widget.suffixIcon,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: widget.onSuffixTap,
                        )
                      : null,
              labelStyle: TextStyle(
                color: _isFocused
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              hintStyle: const TextStyle(
                color: AppColors.textHint,
              ),
            ),
            onChanged: (value) {
              if (_hasError) {
                _validate(value);
              }
              widget.onChanged?.call(value);
            },
            onFieldSubmitted: widget.onSubmitted,
          ),
        ),
        if (_hasError && _errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 14,
                  color: AppColors.error,
                ),
                const SizedBox(width: 6),
                Text(
                  _errorText!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Large ticket number input with auto-focus
class TicketNumberInput extends StatefulWidget {
  final void Function(String) onSubmit;
  final String? initialValue;

  const TicketNumberInput({
    super.key,
    required this.onSubmit,
    this.initialValue,
  });

  @override
  State<TicketNumberInput> createState() => _TicketNumberInputState();
}

class _TicketNumberInputState extends State<TicketNumberInput> {
  late TextEditingController _prefixController;
  late TextEditingController _numberController;
  late FocusNode _prefixFocus;
  late FocusNode _numberFocus;

  @override
  void initState() {
    super.initState();
    _prefixController = TextEditingController(
      text: widget.initialValue?.split('-').first ?? '',
    );
    _numberController = TextEditingController(
      text: widget.initialValue?.split('-').last ?? '',
    );
    _prefixFocus = FocusNode();
    _numberFocus = FocusNode();
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _numberController.dispose();
    _prefixFocus.dispose();
    _numberFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final prefix = _prefixController.text.toUpperCase();
    final number = _numberController.text.padLeft(3, '0');
    if (prefix.isNotEmpty && number.length == 3) {
      widget.onSubmit('$prefix-$number');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Prefix input (A, B, C, etc.)
        SizedBox(
          width: 80,
          child: TextField(
            controller: _prefixController,
            focusNode: _prefixFocus,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 4,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'A',
              hintStyle: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.textHint.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
              UpperCaseTextFormatter(),
            ],
            onChanged: (value) {
              if (value.length == 1) {
                _numberFocus.requestFocus();
              }
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '-',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        // Number input
        SizedBox(
          width: 140,
          child: TextField(
            controller: _numberController,
            focusNode: _numberFocus,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 3,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 4,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '001',
              hintStyle: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.textHint.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onSubmitted: (_) => _submit(),
          ),
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
