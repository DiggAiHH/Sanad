import 'package:flutter/material.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// User management screen
class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benutzerverwaltung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
            tooltip: 'Filter',
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
            child: Row(
              children: [
                const Expanded(child: SearchInput(hint: 'Benutzer suchen...')),
                const SizedBox(width: 16),
                _buildRoleFilter(),
              ],
            ),
          ),
          // Users list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 10,
              itemBuilder: (context, index) => _buildUserCard(context, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilter() {
    return DropdownButton<String>(
      value: 'Alle',
      items: const [
        DropdownMenuItem(value: 'Alle', child: Text('Alle Rollen')),
        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
        DropdownMenuItem(value: 'Arzt', child: Text('Arzt')),
        DropdownMenuItem(value: 'MFA', child: Text('MFA')),
        DropdownMenuItem(value: 'Patient', child: Text('Patient')),
      ],
      onChanged: (value) {},
    );
  }

  Widget _buildUserCard(BuildContext context, int index) {
    final roles = ['Admin', 'Arzt', 'MFA', 'Patient'];
    final role = roles[index % roles.length];
    final isActive = index % 3 != 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Stack(
          children: [
            AppAvatar(name: 'User $index'),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.success : AppColors.textSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text('Benutzer $index'),
        subtitle: Text('user$index@example.com'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusBadge(
              text: role,
              color: _getRoleColor(role),
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
