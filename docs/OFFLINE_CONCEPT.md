# Offline/Retry Konzept für Sanad Apps

> **Version:** 1.0  
> **Status:** 🟡 Konzept (noch nicht implementiert)  
> **Priorität:** P2 (Post-MVP)

---

## 1. Problemstellung

Medizinische Praxen können temporäre Netzwerkausfälle erleben:
- Router-Neustart
- ISP-Probleme
- WLAN-Interferenzen
- Server-Wartung

Während dieser Zeit sollten kritische Operationen (Check-in, Ticket-Aufruf) weiterhin funktionieren.

---

## 2. Architektur-Übersicht

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                          │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ API Service │  │ Offline     │  │ Sync Manager    │  │
│  │ (Dio)       │──│ Queue       │──│ (Background)    │  │
│  └─────────────┘  │ (SQLite)    │  └─────────────────┘  │
│                   └─────────────┘                        │
│                         │                                │
│                         ▼                                │
│               ┌─────────────────┐                        │
│               │ Local Cache     │                        │
│               │ (Isar/Hive)     │                        │
│               └─────────────────┘                        │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                    Backend (FastAPI)                     │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ REST API    │  │ Idempotency │  │ Conflict        │  │
│  │             │──│ Keys        │──│ Resolution      │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Komponenten

### 3.1 Offline Queue (Flutter)

```dart
/// Pending request stored locally when offline
class OfflineRequest {
  final String id;               // UUID für Idempotency
  final String endpoint;         // z.B. "/api/nfc/check-in"
  final String method;           // POST, PUT, DELETE
  final Map<String, dynamic> body;
  final DateTime createdAt;
  final int retryCount;
  final OfflineRequestStatus status;
}

enum OfflineRequestStatus {
  pending,    // Noch nicht versucht
  retrying,   // Wird gerade versucht
  failed,     // Permanent fehlgeschlagen
  synced,     // Erfolgreich synchronisiert
}
```

### 3.2 Local Cache (Flutter)

```dart
/// Cached queue data for offline display
class CachedQueue {
  final String id;
  final String name;
  final String code;
  final int ticketCount;
  final DateTime lastSynced;
}

/// Cached tickets for offline status check
class CachedTicket {
  final String ticketNumber;
  final String status;
  final int position;
  final DateTime lastSynced;
}
```

### 3.3 Sync Manager (Flutter)

```dart
class SyncManager {
  /// Periodisch prüfen und synchronisieren
  Future<void> syncPendingRequests() async {
    if (!await hasConnectivity()) return;
    
    final pending = await offlineQueue.getPending();
    for (final request in pending) {
      try {
        await retryRequest(request);
        await offlineQueue.markSynced(request.id);
      } on DioException catch (e) {
        if (e.response?.statusCode == 409) {
          // Konflikt: Request bereits verarbeitet
          await handleConflict(request, e.response);
        } else if (shouldRetry(e)) {
          await offlineQueue.incrementRetry(request.id);
        } else {
          await offlineQueue.markFailed(request.id);
        }
      }
    }
  }
}
```

---

## 4. Idempotency-Keys

### 4.1 Client-Generierung

```dart
/// Generiere eindeutigen Key pro Request
String generateIdempotencyKey(String operation, Map<String, dynamic> params) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final paramsHash = sha256(jsonEncode(params)).substring(0, 8);
  return '$operation:$paramsHash:$timestamp';
}
```

### 4.2 Backend-Validierung

```python
# backend/app/middleware/idempotency.py

from redis import Redis

async def check_idempotency(
    key: str, 
    redis: Redis,
    ttl_seconds: int = 86400  # 24h
) -> tuple[bool, dict | None]:
    """
    Returns (is_duplicate, cached_response).
    """
    cached = await redis.get(f"idempotency:{key}")
    if cached:
        return True, json.loads(cached)
    return False, None


async def store_idempotency(
    key: str,
    response: dict,
    redis: Redis,
    ttl_seconds: int = 86400
):
    await redis.set(
        f"idempotency:{key}",
        json.dumps(response),
        ex=ttl_seconds
    )
```

### 4.3 NFC Check-in mit Idempotency

```python
@router.post("/check-in")
async def nfc_check_in(
    request: NFCCheckInRequest,
    idempotency_key: str = Header(None, alias="X-Idempotency-Key"),
    db: AsyncSession = Depends(get_db),
    redis: Redis = Depends(get_redis),
):
    # Check for duplicate
    if idempotency_key:
        is_dup, cached = await check_idempotency(idempotency_key, redis)
        if is_dup:
            return JSONResponse(content=cached, status_code=200)
    
    # Process request...
    response = await process_checkin(request, db)
    
    # Cache response
    if idempotency_key:
        await store_idempotency(idempotency_key, response.dict(), redis)
    
    return response
```

---

## 5. Konflikt-Auflösung

### 5.1 Check-in Konflikte

| Szenario | Auflösung |
|----------|-----------|
| Gleiche Karte, gleiches Gerät, < 5 min | Ignorieren, altes Ticket zurückgeben |
| Gleiche Karte, anderes Gerät, < 5 min | Warnung, beide Tickets gültig |
| Gleiche Karte, > 5 min | Neues Ticket erstellen |

### 5.2 Ticket-Status Konflikte

| Szenario | Auflösung |
|----------|-----------|
| Offline: "called" → Online: "completed" | Online gewinnt |
| Offline: "cancelled" → Online: "in_progress" | Konflikt-Dialog |
| Beide "completed" mit unterschiedlicher Zeit | Früherer Timestamp gewinnt |

---

## 6. Offline-Modus Flows

### 6.1 NFC Check-in (Offline)

```
1. Patient scannt Karte
2. App erkennt: Offline
3. App zeigt: "Check-in wird gespeichert..."
4. Lokales Ticket mit PENDING Status erstellen
5. Request in Offline-Queue speichern
6. Ticket-Nummer anzeigen (lokal generiert)
7. [Später] Sync Manager sendet Request
8. [Später] Ticket-Status aktualisieren
```

### 6.2 Queue-Anzeige (Offline)

```
1. MFA öffnet Queue-Screen
2. App erkennt: Offline
3. Banner zeigen: "Offline - Letzte Aktualisierung: 10:42"
4. Gecachte Queue-Daten anzeigen
5. Änderungen in Offline-Queue speichern
6. [Später] Sync Manager synchronisiert
```

### 6.3 Ticket-Status (Patient App, Offline)

```
1. Patient öffnet App
2. App erkennt: Offline
3. Banner zeigen: "Offline - Status möglicherweise veraltet"
4. Gecachten Ticket-Status anzeigen
5. [Später] WebSocket reconnect, Live-Update
```

---

## 7. Technische Entscheidungen

### 7.1 Storage-Wahl

| Option | Vorteile | Nachteile | Entscheidung |
|--------|----------|-----------|--------------|
| **Isar** | Schnell, Flutter-native, reaktiv | Neuer, weniger Doku | ✅ Empfohlen |
| Hive | Einfach, bewährt | Langsamer bei großen Daten | Alternative |
| SQLite | SQL-Kompatibel, robust | Mehr Boilerplate | Für komplexe Queries |
| Shared Prefs | Einfach | Nur Key-Value | Nur für Flags |

### 7.2 Sync-Strategie

| Strategie | Wann | Interval |
|-----------|------|----------|
| **Eager** | Sofort bei Connectivity | - |
| **Periodic** | Background | 30 Sekunden |
| **Manual** | User Pull-to-Refresh | - |

### 7.3 Retry-Policy

```dart
const retryPolicy = RetryPolicy(
  maxAttempts: 5,
  backoffFactor: 2.0,
  initialDelay: Duration(seconds: 1),
  maxDelay: Duration(minutes: 5),
  retryIf: (response) => response.statusCode >= 500,
);
```

---

## 8. Implementierungs-Roadmap

### Phase 1: Grundlagen (1 Sprint)

- [ ] Isar Setup in core Package
- [ ] OfflineRequest Model
- [ ] OfflineQueueService
- [ ] Connectivity-Listener

### Phase 2: API-Integration (1 Sprint)

- [ ] Dio Interceptor für Offline-Queueing
- [ ] Idempotency-Key Header
- [ ] Backend Idempotency Middleware

### Phase 3: Caching (1 Sprint)

- [ ] Queue Cache Model
- [ ] Ticket Cache Model
- [ ] Cache Invalidation Logic

### Phase 4: Sync & Konflikte (1 Sprint)

- [ ] SyncManager Service
- [ ] Konflikt-Dialoge UI
- [ ] Background Sync (workmanager)

---

## 9. Dependencies

```yaml
# pubspec.yaml Ergänzungen
dependencies:
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0
  connectivity_plus: ^5.0.0
  workmanager: ^0.5.0

dev_dependencies:
  isar_generator: ^3.1.0
```

---

## 10. Offene Fragen

1. **Ticket-Nummerierung offline:** Lokale Sequenz oder Server-Sync?
2. **Maximale Offline-Dauer:** Wie lange sind gecachte Daten gültig?
3. **Konflikt-Priorität:** Wer gewinnt bei Konflikt – lokal oder Server?
4. **Push-Sync:** Sollen Push-Notifications Sync triggern?

---

*Dokument erstellt von Senior Architect Agent v2025.1*
