import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:core/core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Meine Termine - Übersicht aller gebuchten Termine
class MyAppointmentsScreen extends ConsumerStatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  ConsumerState<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends ConsumerState<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mock-Daten - werden durch API ersetzt
  final List<Appointment> _appointments = [
    Appointment(
      id: '1',
      type: 'Vorsorge/Check-up',
      date: DateTime.now().add(const Duration(days: 3)),
      time: '09:30',
      duration: 30,
      status: AppointmentStatus.confirmed,
      doctorName: 'Dr. med. Schmidt',
      location: 'Zimmer 2',
    ),
    Appointment(
      id: '2',
      type: 'Laborbesprechung',
      date: DateTime.now().add(const Duration(days: 7)),
      time: '14:00',
      duration: 15,
      status: AppointmentStatus.pending,
      doctorName: 'Dr. med. Müller',
    ),
    Appointment(
      id: '3',
      type: 'Impfung',
      date: DateTime.now().subtract(const Duration(days: 14)),
      time: '10:00',
      duration: 15,
      status: AppointmentStatus.completed,
      doctorName: 'Dr. med. Schmidt',
    ),
    Appointment(
      id: '4',
      type: 'Akutsprechstunde',
      date: DateTime.now().subtract(const Duration(days: 30)),
      time: '11:30',
      duration: 15,
      status: AppointmentStatus.completed,
      doctorName: 'Dr. med. Weber',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    
    final upcoming = _appointments
        .where((a) => a.date.isAfter(DateTime.now()) && 
                      a.status != AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    final past = _appointments
        .where((a) => a.date.isBefore(DateTime.now()) || 
                      a.status == AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Neueste zuerst

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appointmentMyAppointments),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.appointmentUpcoming),
            Tab(text: l10n.appointmentPast),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Kommende Termine
          upcoming.isEmpty
              ? _buildEmptyState(l10n.appointmentNoUpcoming, Icons.event_available)
              : _buildAppointmentList(upcoming, isUpcoming: true),
          
          // Vergangene Termine
          past.isEmpty
              ? _buildEmptyState(l10n.appointmentNoPast, Icons.history)
              : _buildAppointmentList(past, isUpcoming: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/appointments/book');
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.appointmentBook),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments, {required bool isUpcoming}) {
    final l10n = context.l10n;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _AppointmentCard(
          appointment: appointment,
          isUpcoming: isUpcoming,
          onCancel: isUpcoming ? () => _showCancelDialog(appointment) : null,
          onReschedule: isUpcoming ? () => _reschedule(appointment) : null,
          onViewDetails: () => _viewDetails(appointment),
        );
      },
    );
  }

  void _showCancelDialog(Appointment appointment) {
    final l10n = context.l10n;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.appointmentCancelTitle),
        content: Text(l10n.appointmentCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.buttonNo),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelAppointment(appointment);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.buttonYesCancel),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(Appointment appointment) {
    final l10n = context.l10n;
    // TODO: API-Call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.appointmentCancelled)),
    );
  }

  void _reschedule(Appointment appointment) {
    // TODO: Navigation zur Umbuchung
  }

  void _viewDetails(Appointment appointment) {
    // TODO: Detail-Ansicht
  }
}

/// Einzelne Terminkarte
class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isUpcoming;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onViewDetails;

  const _AppointmentCard({
    required this.appointment,
    required this.isUpcoming,
    this.onCancel,
    this.onReschedule,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    
    final statusColor = _getStatusColor(appointment.status);
    final statusText = _getStatusText(appointment.status, l10n);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header mit Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isUpcoming && appointment.status != AppointmentStatus.cancelled)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'cancel') onCancel?.call();
                        if (value == 'reschedule') onReschedule?.call();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'reschedule',
                          child: ListTile(
                            leading: const Icon(Icons.edit_calendar),
                            title: Text(l10n.appointmentReschedule),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'cancel',
                          child: ListTile(
                            leading: const Icon(Icons.cancel, color: Colors.red),
                            title: Text(l10n.appointmentCancel, 
                                style: const TextStyle(color: Colors.red)),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Termintyp
              Text(
                appointment.type,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Datum & Zeit
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, dd. MMMM yyyy', 'de').format(appointment.date),
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    '${appointment.time} Uhr (${appointment.duration} ${l10n.minutesAbbrev})',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              
              // Arzt & Raum
              if (appointment.doctorName != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      appointment.doctorName!,
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
              if (appointment.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.room, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      appointment.location!,
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
              
              // Anamnese-Erinnerung für kommende Termine
              if (isUpcoming && appointment.status == AppointmentStatus.confirmed) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.assignment, size: 20, color: AppColors.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.appointmentFillAnamnesisReminder,
                          style: const TextStyle(color: AppColors.info, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigation zum Anamnese-Bogen
                        },
                        child: Text(l10n.buttonFillNow),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.warning;
      case AppointmentStatus.confirmed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.error;
      case AppointmentStatus.completed:
        return AppColors.info;
      case AppointmentStatus.noShow:
        return AppColors.completed;
    }
  }

  String _getStatusText(AppointmentStatus status, SanadLocalizations l10n) {
    switch (status) {
      case AppointmentStatus.pending:
        return l10n.appointmentStatusPending;
      case AppointmentStatus.confirmed:
        return l10n.appointmentStatusConfirmed;
      case AppointmentStatus.cancelled:
        return l10n.appointmentStatusCancelled;
      case AppointmentStatus.completed:
        return l10n.appointmentStatusCompleted;
      case AppointmentStatus.noShow:
        return l10n.appointmentStatusNoShow;
    }
  }
}

/// Termin-Modell
class Appointment {
  final String id;
  final String type;
  final DateTime date;
  final String time;
  final int duration;
  final AppointmentStatus status;
  final String? doctorName;
  final String? location;

  const Appointment({
    required this.id,
    required this.type,
    required this.date,
    required this.time,
    required this.duration,
    required this.status,
    this.doctorName,
    this.location,
  });
}

enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  noShow,
}
