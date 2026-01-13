import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Screen displaying the status of a specific ticket.
class TicketStatusScreen extends StatefulWidget {
  final String ticketNumber;

  const TicketStatusScreen({
    super.key,
    required this.ticketNumber,
  });

  @override
  State<TicketStatusScreen> createState() => _TicketStatusScreenState();
}

class _TicketStatusScreenState extends State<TicketStatusScreen> {
  late Timer _refreshTimer;
  
  // Demo data - would come from API
  int _positionInQueue = 3;
  int _estimatedWaitMinutes = 15;
  String _status = 'waiting'; // waiting, called, in_progress, completed
  int _currentlyServing = 39;

  @override
  void initState() {
    super.initState();
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshStatus();
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  void _refreshStatus() {
    // Simulate status update
    setState(() {
      if (_positionInQueue > 0) {
        _positionInQueue--;
        _estimatedWaitMinutes = _positionInQueue * 5;
        _currentlyServing++;
      }
      if (_positionInQueue == 0) {
        _status = 'called';
      }
    });
  }

  Color _getStatusColor() {
    switch (_status) {
      case 'called':
        return AppColors.success;
      case 'in_progress':
        return AppColors.info;
      case 'completed':
        return AppColors.textSecondary;
      default:
        return AppColors.warning;
    }
  }

  String _getStatusText() {
    switch (_status) {
      case 'called':
        return 'Sie werden aufgerufen!';
      case 'in_progress':
        return 'In Behandlung';
      case 'completed':
        return 'Abgeschlossen';
      default:
        return 'In Warteschlange';
    }
  }

  IconData _getStatusIcon() {
    switch (_status) {
      case 'called':
        return Icons.notifications_active;
      case 'in_progress':
        return Icons.medical_services;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCalled = _status == 'called';
    
    return Scaffold(
      backgroundColor: isCalled ? AppColors.success : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isCalled ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Ticket ${widget.ticketNumber}',
          style: AppTextStyles.titleLarge.copyWith(
            color: isCalled ? Colors.white : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isCalled ? Colors.white : AppColors.primary,
            ),
            onPressed: _refreshStatus,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Status Card
              if (isCalled) ...[
                _CalledStatusCard(ticketNumber: widget.ticketNumber),
              ] else ...[
                _WaitingStatusCard(
                  ticketNumber: widget.ticketNumber,
                  status: _status,
                  statusColor: _getStatusColor(),
                  statusText: _getStatusText(),
                  statusIcon: _getStatusIcon(),
                  positionInQueue: _positionInQueue,
                  estimatedWaitMinutes: _estimatedWaitMinutes,
                  currentlyServing: _currentlyServing,
                ),
              ],
              
              const SizedBox(height: 24),
              
              // QR Code
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Ihr Ticket-QR-Code',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    QrImageView(
                      data: 'sanad://ticket/${widget.ticketNumber}',
                      version: QrVersions.auto,
                      size: 180,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.ticketNumber,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Info Cards
              _InfoCard(
                icon: Icons.access_time,
                title: 'Auto-Aktualisierung',
                description: 'Diese Seite wird automatisch alle 30 Sekunden aktualisiert.',
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.volume_up,
                title: 'Aufruf',
                description: 'Achten Sie auf die Anzeige im Wartebereich, wenn Ihre Nummer aufgerufen wird.',
              ),
              
              const SizedBox(height: 32),
              
              // Back to Home Button
              OutlinedButton.icon(
                onPressed: () => context.go('/'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isCalled ? Colors.white : AppColors.primary,
                  side: BorderSide(
                    color: isCalled ? Colors.white : AppColors.primary,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.home),
                label: const Text('Zur Startseite'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalledStatusCard extends StatelessWidget {
  final String ticketNumber;

  const _CalledStatusCard({required this.ticketNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sie werden aufgerufen!',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bitte begeben Sie sich jetzt zum Behandlungszimmer.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              ticketNumber,
              style: AppTextStyles.displaySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
                letterSpacing: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingStatusCard extends StatelessWidget {
  final String ticketNumber;
  final String status;
  final Color statusColor;
  final String statusText;
  final IconData statusIcon;
  final int positionInQueue;
  final int estimatedWaitMinutes;
  final int currentlyServing;

  const _WaitingStatusCard({
    required this.ticketNumber,
    required this.status,
    required this.statusColor,
    required this.statusText,
    required this.statusIcon,
    required this.positionInQueue,
    required this.estimatedWaitMinutes,
    required this.currentlyServing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Ticket Number
          Text(
            ticketNumber,
            style: AppTextStyles.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: positionInQueue.toString(),
                  label: 'Position',
                  color: AppColors.primary,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppColors.border,
              ),
              Expanded(
                child: _StatItem(
                  value: '~$estimatedWaitMinutes',
                  label: 'Min. Wartezeit',
                  color: AppColors.warning,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppColors.border,
              ),
              Expanded(
                child: _StatItem(
                  value: 'A-${currentlyServing.toString().padLeft(3, '0')}',
                  label: 'Aktuell',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
