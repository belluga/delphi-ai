---
name: docker-realtime-delta-streams
description: "Specify realtime SSE streams that deliver delta updates for paginated feeds while keeping page-based listing as the source of truth."
---

# Workflow: Realtime Delta Streams (SSE)

## Purpose

Specify realtime SSE streams that deliver delta updates for paginated feeds (events, invites, map POIs) while keeping page-based listing as the source of truth.

## Triggers

- Adding realtime updates to existing paginated feeds
- New feature requires live data updates
- Implementing SSE streams for mobile/web clients

## Prerequisites

- [ ] `system_architecture_principles.md` reviewed (P-15 Deterministic Pagination + Delta Streams)
- [ ] Current contracts in `endpoints_mvp_contracts.md` understood
- [ ] Relevant route files identified

## Procedure

### Step 1: Confirm List Endpoint

Verify page-based list endpoint:
- Endpoint URL and HTTP method
- Pagination parameters (page, per_page)
- Filter parameters (search, tags, categories, geo)
- Sort order

**The list endpoint is the source of truth.**

### Step 2: Define SSE Stream Route

Specify SSE endpoint:
- Route name (e.g., `/api/v1/events/stream`)
- Scope (tenant/app vs landlord/account)
- Authentication requirements
- Middleware stack

```php
// Example route definition
Route::get('/events/stream', [EventStreamController::class, 'stream'])
    ->middleware(['auth:sanctum', 'check_tenant_access']);
```

### Step 3: Define Stream Filters

Stream filters must match list endpoint:
- Same filter parameters
- Same search syntax
- Same geo bounds (if applicable)
- Same tag/category filters

```php
// Stream accepts same filters as list
GET /api/v1/events/stream?search=concert&tags=music&lat=40.7&lng=-74.0
```

### Step 4: Define Event Types

Standard event types:

| Event Type | Description | Payload |
|------------|-------------|---------|
| `created` | New item added | Full item or minimal delta |
| `updated` | Item changed | Changed fields only |
| `deleted` | Item removed | Item ID only |

**Minimal delta payload:**
```json
{
  "event": "created",
  "id": "evt_123",
  "type": "event",
  "data": {
    "id": "evt_123",
    "title": "Concert Title",
    "updated_at": "2024-01-15T10:00:00Z"
  }
}
```

### Step 5: Document Resync Behavior

Define client reconnection strategy:

**On reconnect:**
1. Client re-fetches page 1
2. Compare timestamps to last seen item
3. Apply any missed deltas
4. Resume SSE connection

**On invalidation:**
1. Server sends `invalidate` event
2. Client re-fetches page 1
3. Clear local cache
4. Resume SSE connection

```json
{
  "event": "invalidate",
  "reason": "schema_change"
}
```

### Step 6: Update Endpoint Contracts

Document in `endpoints_mvp_contracts.md`:

```markdown
## Events SSE Stream

**Endpoint:** `GET /api/v1/events/stream`
**Auth:** Bearer token (Sanctum)
**Scope:** Tenant

### Query Parameters
- `search` (optional): Search string
- `tags` (optional): Comma-separated tags
- `lat`, `lng` (optional): Geo center point
- `radius` (optional): Radius in meters

### Event Types
- `created`: New event added
- `updated`: Event modified
- `deleted`: Event removed
- `invalidate`: Client must refresh

### Payload
Minimal delta - ID + changed fields only

### Resync Strategy
Re-fetch page 1 on reconnect or invalidation
```

### Step 7: Update Roadmap

Add to `system_roadmap.md`:
- Realtime delivery workstream
- Backend SSE implementation
- Client integration requirements
- Testing strategy

### Step 8: Record Client Changes

Note in `system_roadmap.md` or submodule summary (only when implementation snapshot changed):
- Flutter: SSE client implementation
- Controller changes for delta handling
- UI update strategy

## SSE Implementation Pattern

### Server-Side (Laravel)

```php
class EventStreamController
{
    public function stream(Request $request): StreamedResponse
    {
        return response()->stream(function () use ($request) {
            $filters = $request->only(['search', 'tags', 'lat', 'lng']);
            
            // Subscribe to event channel with filters
            $channel = "events.{$tenantId}." . md5(json_encode($filters));
            
            echo "event: connected\n";
            echo "data: " . json_encode(['timestamp' => now()]) . "\n\n";
            
            // Stream events...
        }, 200, [
            'Content-Type' => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'X-Accel-Buffering' => 'no',
        ]);
    }
}
```

### Client-Side (Flutter)

```dart
class EventStreamService {
  Stream<EventDelta> subscribe({
    String? search,
    List<String>? tags,
  }) async* {
    final uri = Uri.parse('/api/v1/events/stream').replace(
      queryParameters: {
        if (search != null) 'search': search,
        if (tags != null) 'tags': tags.join(','),
      },
    );
    
    final client = HttpClient();
    final request = await client.getUrl(uri);
    request.headers.contentType = ContentType.text;
    
    final response = await request.close();
    
    await for (final line in response.transform(utf8.decoder)) {
      if (line.startsWith('data: ')) {
        yield EventDelta.fromJson(
          jsonDecode(line.substring(6)),
        );
      }
    }
  }
}
```

## Architecture Principles

| Principle | Description |
|-----------|-------------|
| List is canonical | Page-based listing is source of truth |
| Deltas are minimal | Only changed fields, not full objects |
| Resync on reconnect | Client re-fetches page 1 after disconnect |
| Same filters | Stream uses same filters as list endpoint |

## Outputs

- [ ] SSE endpoint definition
- [ ] Event types documented
- [ ] Resync strategy documented
- [ ] Endpoint contracts updated
- [ ] Roadmap updated
- [ ] Client changes noted

## Validation Checklist

- [ ] Page-based listing remains canonical
- [ ] SSE payload is delta-only
- [ ] No duplicate pagination in SSE
- [ ] Filters match list endpoint
- [ ] Resync strategy is documented
