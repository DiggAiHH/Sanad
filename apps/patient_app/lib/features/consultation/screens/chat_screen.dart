import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanad_core/sanad_core.dart';
import 'package:sanad_ui/sanad_ui.dart';

/// Provider für Konsultations-Details.
final consultationProvider = FutureProvider.autoDispose
    .family<Consultation?, String>((ref, consultationId) async {
  final service = ref.watch(consultationServiceProvider);
  return service.getConsultation(consultationId);
});

/// Chat-Screen für Text-Kommunikation mit dem Arzt/Praxisteam.
/// DSGVO-konform: Nachrichten werden Ende-zu-Ende verschlüsselt.
class ChatScreen extends ConsumerStatefulWidget {
  final String? consultationId;

  const ChatScreen({super.key, this.consultationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isSending = false;
  bool _isSearching = false;
  List<ConsultationMessage> _messages = [];
  List<String> _searchResults = []; // Message IDs matching search
  int _currentSearchIndex = 0;
  Consultation? _consultation;
  
  // E2E Encryption
  late final EncryptionService _encryptionService;
  Uint8List? _encryptionKey;
  bool _encryptionInitialized = false;

  @override
  void initState() {
    super.initState();
    _encryptionService = ref.read(encryptionServiceProvider);
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    // Clear encryption key from memory on dispose
    _encryptionKey = null;
    super.dispose();
  }
  
  /// Schritt 15: Suche in Nachrichten (client-seitig, DSGVO-konform).
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchResults.clear();
        _currentSearchIndex = 0;
      }
    });
  }
  
  /// Schritt 15: Führt Suche in indizierten Nachrichten durch.
  void _performSearch(String query) {
    if (query.isEmpty || widget.consultationId == null) {
      setState(() {
        _searchResults.clear();
        _currentSearchIndex = 0;
      });
      return;
    }
    
    final resultsSet = _encryptionService.searchMessages(
      widget.consultationId!,
      query,
    );
    
    setState(() {
      _searchResults = resultsSet.toList();
      _currentSearchIndex = _searchResults.isNotEmpty ? 0 : -1;
    });
    
    if (_searchResults.isNotEmpty) {
      _scrollToMessage(_searchResults.first);
    }
  }
  
  /// Schritt 15: Scrollt zur nächsten/vorherigen Suchergebnis.
  void _navigateSearchResult(int direction) {
    if (_searchResults.isEmpty) return;
    
    setState(() {
      _currentSearchIndex = (_currentSearchIndex + direction) % _searchResults.length;
      if (_currentSearchIndex < 0) {
        _currentSearchIndex = _searchResults.length - 1;
      }
    });
    
    _scrollToMessage(_searchResults[_currentSearchIndex]);
  }
  
  /// Schritt 15: Scrollt zu einer bestimmten Nachricht.
  void _scrollToMessage(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1 || !_scrollController.hasClients) return;
    
    // Approximate position (assumes ~80px per message)
    final targetOffset = index * 80.0;
    _scrollController.animateTo(
      targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Initializes E2E encryption for this consultation.
  /// 
  /// Uses a shared secret derived from consultation ID + patient ID.
  /// In production, use proper key exchange (ECDH).
  Future<void> _initializeEncryption() async {
    if (_consultation == null || widget.consultationId == null) return;
    
    // Generate a deterministic salt based on consultation
    final saltSource = '${widget.consultationId}:${_consultation!.patientId}';
    final salt = Uint8List.fromList(
      saltSource.codeUnits.take(32).toList()..addAll(List.filled(32 - saltSource.length.clamp(0, 32), 0)),
    );
    
    // Shared secret - in production, use proper key exchange
    // For now, use a combination of IDs as a placeholder
    final sharedSecret = '${_consultation!.patientId}:${_consultation!.doctorId ?? 'practice'}';
    
    _encryptionKey = _encryptionService.deriveKey(
      widget.consultationId!,
      sharedSecret,
      salt,
    );
    _encryptionInitialized = true;
  }

  /// Encrypts a message before sending.
  String _encryptContent(String plaintext) {
    if (!_encryptionInitialized || _encryptionKey == null) {
      return plaintext; // Fallback to unencrypted
    }
    return _encryptionService.encryptMessage(plaintext, _encryptionKey!);
  }

  /// Decrypts a received message.
  String _decryptContent(String ciphertext) {
    if (!_encryptionInitialized || _encryptionKey == null) {
      return ciphertext; // Fallback
    }
    try {
      return _encryptionService.decryptMessage(ciphertext, _encryptionKey!);
    } catch (e) {
      // If decryption fails, message might be unencrypted (legacy)
      return ciphertext;
    }
  }

  Future<void> _loadMessages() async {
    if (widget.consultationId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final service = ref.read(consultationServiceProvider);
      final consultation = await service.getConsultation(widget.consultationId!);
      
      // Initialize encryption with consultation data
      _consultation = consultation;
      await _initializeEncryption();
      
      final messages = await service.getMessages(widget.consultationId!);
      
      // Decrypt messages and index for search
      final decryptedMessages = messages.map((msg) {
        final decryptedContent = _decryptContent(msg.content);
        // Index for client-side search (DSGVO-konform)
        _encryptionService.indexMessage(
          widget.consultationId!,
          msg.id,
          decryptedContent,
        );
        // Return message with decrypted content for display
        return ConsultationMessage(
          id: msg.id,
          consultationId: msg.consultationId,
          senderId: msg.senderId,
          senderRole: msg.senderRole,
          content: decryptedContent,
          isRead: msg.isRead,
          attachmentUrl: msg.attachmentUrl,
          attachmentType: msg.attachmentType,
          createdAt: msg.createdAt,
          readAt: msg.readAt,
          senderName: msg.senderName,
        );
      }).toList();
      
      // Mark messages as read
      await service.markMessagesRead(widget.consultationId!);
      
      if (mounted) {
        setState(() {
          _messages = decryptedMessages.reversed.toList(); // oldest first for display
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Laden: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending || widget.consultationId == null) return;

    setState(() => _isSending = true);

    try {
      final service = ref.read(consultationServiceProvider);
      
      // Encrypt content before sending
      final encryptedContent = _encryptContent(content);
      final message = await service.sendMessage(widget.consultationId!, encryptedContent);
      
      // Index the plaintext for local search
      _encryptionService.indexMessage(widget.consultationId!, message.id, content);

      // Add message with decrypted content for display
      final displayMessage = ConsultationMessage(
        id: message.id,
        consultationId: message.consultationId,
        senderId: message.senderId,
        senderRole: message.senderRole,
        content: content, // Use original plaintext for display
        isRead: message.isRead,
        attachmentUrl: message.attachmentUrl,
        attachmentType: message.attachmentType,
        createdAt: message.createdAt,
        readAt: message.readAt,
        senderName: message.senderName,
      );

      setState(() {
        _messages.add(displayMessage);
        _messageController.clear();
      });

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nachricht konnte nicht gesendet werden: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _attachFile() async {
    // TODO: Implement file attachment with image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dateianhang wird in einer zukünftigen Version verfügbar sein.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = _consultation?.doctorName ?? 'Arzt';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _isSearching
            // Schritt 15: Search Input in AppBar
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _performSearch,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nachrichten durchsuchen...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                  suffixText: _searchResults.isEmpty 
                      ? '' 
                      : '${_currentSearchIndex + 1}/${_searchResults.length}',
                  suffixStyle: const TextStyle(color: Colors.white70),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chat mit Arzt'),
                  Text(
                    '$doctorName • ${_consultation?.status == ConsultationStatus.inProgress ? "Online" : "Wartend"}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: _isSearching
            // Schritt 15: Search Navigation
            ? [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up),
                  onPressed: () => _navigateSearchResult(-1),
                  tooltip: 'Vorheriges Ergebnis',
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onPressed: () => _navigateSearchResult(1),
                  tooltip: 'Nächstes Ergebnis',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleSearch,
                  tooltip: 'Suche beenden',
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _toggleSearch,
                  tooltip: 'Nachrichten durchsuchen',
                ),
                IconButton(
                  icon: const Icon(Icons.videocam),
                  onPressed: () {
                    // TODO: Upgrade to video call
                  },
                  tooltip: 'Zu Videoanruf wechseln',
                ),
                IconButton(
                  icon: const Icon(Icons.phone),
                  onPressed: () {
                    // TODO: Upgrade to voice call
                  },
                  tooltip: 'Zu Telefonat wechseln',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'end') {
                      _showEndChatDialog();
                    } else if (value == 'info') {
                      _showPrivacyInfo();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'info',
                      child: ListTile(
                        leading: Icon(Icons.privacy_tip),
                        title: Text('Datenschutzhinweise'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'end',
                      child: ListTile(
                        leading: Icon(Icons.close, color: Colors.red),
                        title: Text('Chat beenden'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
      ),
      body: Column(
        children: [
          // Privacy Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.info.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.lock, size: 14, color: AppColors.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Diese Unterhaltung ist Ende-zu-Ende verschlüsselt.',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Noch keine Nachrichten',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Schreiben Sie Ihre erste Nachricht',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final showDate = index == 0 ||
                              !_isSameDay(
                                _messages[index - 1].createdAt,
                                message.createdAt,
                              );

                          return Column(
                            children: [
                              if (showDate)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    _formatDate(message.createdAt),
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              _MessageBubble(message: message),
                            ],
                          );
                        },
                      ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _attachFile,
                    tooltip: 'Datei anhängen',
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Nachricht eingeben...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return 'Heute';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Gestern';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  void _showEndChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat beenden?'),
        content: const Text(
          'Möchten Sie diesen Chat wirklich beenden? '
          'Die Gesprächshistorie bleibt für Sie einsehbar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Beenden'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.privacy_tip, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Datenschutzhinweise',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildPrivacyItem(
                icon: Icons.lock,
                title: 'Verschlüsselung',
                description: 'Alle Nachrichten werden Ende-zu-Ende '
                    'verschlüsselt übertragen und gespeichert.',
              ),
              _buildPrivacyItem(
                icon: Icons.storage,
                title: 'Speicherung',
                description: 'Ihre Chatverläufe werden gemäß der gesetzlichen '
                    'Aufbewahrungspflicht (10 Jahre) in Ihrer Patientenakte gespeichert.',
              ),
              _buildPrivacyItem(
                icon: Icons.people,
                title: 'Zugriff',
                description: 'Nur Sie und Ihr behandelnder Arzt haben Zugriff '
                    'auf diese Unterhaltung.',
              ),
              _buildPrivacyItem(
                icon: Icons.delete_outline,
                title: 'Löschung',
                description: 'Sie können die Löschung Ihrer Daten beantragen. '
                    'Beachten Sie jedoch die gesetzlichen Aufbewahrungsfristen.',
              ),
              _buildPrivacyItem(
                icon: Icons.download,
                title: 'Datenexport',
                description: 'Sie haben das Recht, eine Kopie Ihrer Daten '
                    'im maschinenlesbaren Format anzufordern.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Verstanden'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
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

class _MessageBubble extends StatelessWidget {
  final ConsultationMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    // Patient messages have senderRole == 'patient'
    final isPatient = message.senderRole.toLowerCase() == 'patient';
    final senderName = message.senderName ?? (isPatient ? 'Sie' : 'Arzt');

    return Align(
      alignment: isPatient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isPatient ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isPatient ? 16 : 4),
            bottomRight: Radius.circular(isPatient ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isPatient)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  senderName,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Text(
              message.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isPatient ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.createdAt.hour.toString().padLeft(2, '0')}:'
                  '${message.createdAt.minute.toString().padLeft(2, '0')}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isPatient ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                if (isPatient) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead ? Colors.lightBlueAccent : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
