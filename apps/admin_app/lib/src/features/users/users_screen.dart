import 'package:flutter/material.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// User management screen
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _query = '';
  String _roleFilter = 'Alle';
  DateTime _lastUpdated = DateTime.now();

  final List<_UserRow> _users = List.generate(
    10,
    (index) {
      final roles = ['Admin', 'Arzt', 'MFA', 'Patient'];
      final role = roles[index % roles.length];
      return _UserRow(
        name: 'Benutzer $index',
        email: 'user$index@example.com',
        role: role,
        isActive: index % 3 != 0,
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers();
    final activeCount = users.where((user) => user.isActive).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Benutzerverwaltung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Benutzer hinzufügen'),
      ),
      body: Column(
        children: [
          // Search and filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 700) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SearchInput(
                        hint: 'Benutzer suchen...',
                        onChanged: (value) => setState(() => _query = value.trim()),
                        onClear: () => setState(() => _query = ''),
                      ),
                      const SizedBox(height: 12),
                      _buildRoleFilter(),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: SearchInput(
                        hint: 'Benutzer suchen...',
                        onChanged: (value) => setState(() => _query = value.trim()),
                        onClear: () => setState(() => _query = ''),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildRoleFilter(),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ergebnisse: ${users.length} · Aktiv: $activeCount',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                _buildLastUpdated(context),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Users list
          Expanded(
            child: ScreenState(
              isEmpty: users.isEmpty,
              emptyTitle: 'Keine Benutzer gefunden',
              emptySubtitle: 'Passen Sie Filter oder Suche an.',
              emptyActionLabel: 'Filter zurücksetzen',
              onAction: () => setState(() {
                _query = '';
                _roleFilter = 'Alle';
              }),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: users.length,
                itemBuilder: (context, index) => _buildUserCard(context, users[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilter() {
    return DropdownButton<String>(
      value: _roleFilter,
      items: const [
        DropdownMenuItem(value: 'Alle', child: Text('Alle Rollen')),
        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
        DropdownMenuItem(value: 'Arzt', child: Text('Arzt')),
        DropdownMenuItem(value: 'MFA', child: Text('MFA')),
        DropdownMenuItem(value: 'Patient', child: Text('Patient')),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => _roleFilter = value);
      },
    );
  }

  Widget _buildUserCard(BuildContext context, _UserRow user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Stack(
          children: [
            AppAvatar(name: user.name),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: user.isActive ? AppColors.success : AppColors.textSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusBadge(
              text: user.role,
              color: _getRoleColor(user.role),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                const PopupMenuItem(value: 'toggle', child: Text('Aktivieren/Deaktivieren')),
                const PopupMenuItem(value: 'delete', child: Text('Löschen')),
              ],
              onSelected: (value) {},
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return AppColors.error;
      case 'Arzt':
        return AppColors.primary;
      case 'MFA':
        return AppColors.secondary;
      case 'Patient':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  List<_UserRow> _filteredUsers() {
    return _users.where((user) {
      final matchesQuery = _query.isEmpty ||
          user.name.toLowerCase().contains(_query.toLowerCase()) ||
          user.email.toLowerCase().contains(_query.toLowerCase());
      final matchesRole = _roleFilter == 'Alle' || user.role == _roleFilter;
      return matchesQuery && matchesRole;
    }).toList();
  }

  void _refresh() {
    setState(() => _lastUpdated = DateTime.now());
  }

  Widget _buildLastUpdated(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(Icons.update, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          'Aktualisiert: ${_formatTime(context, _lastUpdated)}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatTime(BuildContext context, DateTime time) {
    final localizations = MaterialLocalizations.of(context);
    final timeOfDay = TimeOfDay.fromDateTime(time);
    return localizations.formatTimeOfDay(
      timeOfDay,
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neuer Benutzer'),
        content: const SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextInput(label: 'Vorname', prefixIcon: Icons.person),
              SizedBox(height: 16),
              TextInput(label: 'Nachname', prefixIcon: Icons.person),
              SizedBox(height: 16),
              TextInput(label: 'E-Mail', prefixIcon: Icons.email),
              SizedBox(height: 16),
              TextInput(label: 'Telefon', prefixIcon: Icons.phone),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );
  }
}

class _UserRow {
  final String name;
  final String email;
  final String role;
  final bool isActive;

  const _UserRow({
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });
}
