import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

import '../../../providers/last_ticket_provider.dart';

/// Screen for entering ticket number to check status.
class TicketEntryScreen extends ConsumerStatefulWidget {
  const TicketEntryScreen({super.key});

  @override
  ConsumerState<TicketEntryScreen> createState() => _TicketEntryScreenState();
}

class _TicketEntryScreenState extends ConsumerState<TicketEntryScreen> {
  final _ticketController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ticketController.addListener(() => setState(() {}));
    _restoreLastTicket();
  }

  void _restoreLastTicket() {
    final storage = ref.read(storageServiceProvider);
    final lastTicket = storage.getString(AppConstants.keyLastTicketNumber);
    if (lastTicket != null && lastTicket.isNotEmpty) {
      _ticketController.text = lastTicket;
    }
  }

  @override
  void dispose() {
    _ticketController.dispose();
    super.dispose();
  }

  Future<void> _checkTicketStatus() async {
    if (_formKey.currentState?.validate() ?? false) {
      final ticketNumber = _ticketController.text.trim().toUpperCase();
      final storage = ref.read(storageServiceProvider);
      await storage.setString(
        AppConstants.keyLastTicketNumber,
        ticketNumber,
      );
      ref.invalidate(lastTicketNumberProvider);
      context.push('/ticket/$ticketNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Ticket-Status',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Illustration
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.confirmation_number,
                    color: AppColors.primary,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Instructions
              Text(
                'Ticketnummer eingeben',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Geben Sie Ihre Ticketnummer ein, die Sie am Empfang erhalten haben (z.B. A-042).',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Ticket Input
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _ticketController,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.search,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                      decoration: InputDecoration(
                        hintText: 'A-000',
                        hintStyle: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.4),
                          letterSpacing: 4,
                        ),
                        helperText: 'Beispiel: A-042',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.error),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        suffixIcon: _ticketController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _ticketController.clear();
                                },
                              ),
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6),
                        _TicketNumberFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Bitte geben Sie eine Ticketnummer ein';
                        }
                        if (!RegExp(r'^[A-Za-z]-?\d{1,4}$').hasMatch(value.trim())) {
                          return 'Ungültiges Format (z.B. A-042 oder A042)';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _checkTicketStatus(),
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _checkTicketStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Status prüfen',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Help Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.help_outline,
                      color: AppColors.info,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ihre Ticketnummer finden Sie auf dem Ausdruck vom Empfang.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = newValue.text.toUpperCase();
    final filtered = upper.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    String letter = '';
    final digitsBuffer = StringBuffer();

    for (final char in filtered.split('')) {
      if (letter.isEmpty && RegExp(r'[A-Z]').hasMatch(char)) {
        letter = char;
      } else if (letter.isNotEmpty &&
          RegExp(r'[0-9]').hasMatch(char) &&
          digitsBuffer.length < 4) {
        digitsBuffer.write(char);
      }
    }

    final digits = digitsBuffer.toString();
    final formatted = letter.isEmpty
        ? filtered
        : (digits.isEmpty ? letter : '$letter-$digits');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
