---
name: create-repository
description: "Establish domain-aligned data access for Flutter features, keeping DTO knowledge in infrastructure and enforcing architecture mandates."
---

# Workflow: Create Repository (Flutter)

## Purpose

Establish domain-aligned data access for Flutter features, keeping DTO knowledge in infrastructure and enforcing the architecture mandates.

## Triggers

- A new Flutter domain requires persistence/read APIs
- Existing repositories mix multiple aggregates or leak screen terminology
- Backend contracts change, requiring new DTO mappers

## Prerequisites

- [ ] Domain contract + projections defined (`lib/domain/**`)
- [ ] Architecture docs + backend DTO definitions reviewed
- [ ] DI configuration files understood

## Procedure


### Step 0: Package-First Gate
Read the proprietary packages checklist at `foundation_documentation/package_registry.md` and check whether an existing Flutter library already provides the data access layer for this domain. If a matching library exists, extend it. Record the Package-First Assessment. See `paced.core.package-first`.


### Step 1: Define Domain Contract

Create/update in `lib/domain/repositories/`:

```dart
// lib/domain/repositories/booking_repository_contract.dart
abstract class BookingRepositoryContract {
  /// Fetches a booking by its unique identifier.
  Future<Booking> fetchById(BookingId id);
  
  /// Fetches booking summaries for a date range.
  Future<List<BookingSummary>> fetchSummaries(DateTimeRange range);
  
  /// Creates a new booking.
  Future<Booking> create(CreateBookingParams params);
  
  /// Updates an existing booking.
  Future<Booking> update(Booking booking);
  
  /// Watches for real-time delta updates.
  Stream<BookingDelta> watchDeltas();
}
```

**Important:**
- Use domain verbs (no "screen" references)
- Annotate temporary projection returns with TODOs if full entity is pending

### Step 2: Design DTO Mapper

Create in `lib/infrastructure/mappers/`:

```dart
// lib/infrastructure/mappers/booking_dto_mapper.dart
mixin BookingDtoMapper {
  /// Converts DTO to domain entity.
  Booking toDomain(BookingDTO dto) {
    return Booking(
      id: BookingId(dto.id),
      status: BookingStatus.fromString(dto.status),
      customerName: CustomerName(dto.customerName),
      scheduledTime: ScheduledTime.parse(dto.scheduledTime),
      totalPrice: Price.fromCents(dto.totalPriceCents),
    );
  }

  /// Converts DTO to projection for UI.
  BookingSummary toSummary(BookingDTO dto) {
    final domain = toDomain(dto);
    return BookingSummary(
      id: domain.id.value,
      displayStatus: domain.status.displayName,
      formattedTime: domain.scheduledTime.format(),
      formattedPrice: domain.totalPrice.format(),
      canEdit: domain.isEditable,
    );
  }

  /// Converts domain entity to DTO for persistence.
  BookingDTO toDto(Booking booking) {
    return BookingDTO(
      id: booking.id.value,
      status: booking.status.name,
      customerName: booking.customerName.value,
      scheduledTime: booking.scheduledTime.toIso8601String(),
      totalPriceCents: booking.totalPrice.cents,
    );
  }
}
```

**Key Rules:**
- Keep slugging/formatting helpers inside the mapper
- No presentation imports in mapper

### Step 3: Define DAO/Decoder Transport Boundary

Before repository implementation, define the transport boundary explicitly:

- Raw response envelope parsing (`data/meta`, list extraction, map casts) must live in DAO/decoder layer.
- Write payload assembly (including multipart/form-data) must be produced by typed request DTO/command builders at DAO boundary.
- Repository code must not own raw payload map parsing/building patterns (`Map<String, Object?>`, `as Map` payload casts, inline map payload literals for transport contracts).

### Step 4: Implement Repository

Create in `lib/infrastructure/repositories/`:

```dart
// lib/infrastructure/repositories/booking_repository.dart
@injectable
class BookingRepository implements BookingRepositoryContract, BookingDtoMapper {
  final BookingApi _api;
  final BookingCache _cache;

  BookingRepository({
    required BookingApi api,
    required BookingCache cache,
  })  : _api = api,
        _cache = cache;

  @override
  Future<Booking> fetchById(BookingId id) async {
    final dto = await _api.fetchBooking(id.value);
    return toDomain(dto);
  }

  @override
  Future<List<BookingSummary>> fetchSummaries(DateTimeRange range) async {
    final dtos = await _api.fetchBookings(
      startDate: range.start.toIso8601String(),
      endDate: range.end.toIso8601String(),
    );
    return dtos.map(toSummary).toList();
  }

  @override
  Future<Booking> create(CreateBookingParams params) async {
    final request = CreateBookingRequest(
      customerName: params.customerName.value,
      scheduledTime: params.scheduledTime.toIso8601String(),
    );
    final dto = await _api.createBooking(request);
    return toDomain(dto);
  }

  @override
  Future<Booking> update(Booking booking) async {
    final dto = await _api.updateBooking(booking.id.value, toDto(booking));
    return toDomain(dto);
  }

  @override
  Stream<BookingDelta> watchDeltas() {
    return _api.watchBookingDeltas().map((dto) => BookingDelta(
      id: BookingId(dto.id),
      action: dto.action,
      data: dto.data != null ? toDomain(dto.data!) : null,
    ));
  }
}
```

### Step 5: Dependency Injection

Register in module or `module_settings.dart`:

```dart
@module
abstract class BookingInfrastructureModule {
  @lazySingleton
  BookingRepositoryContract provideBookingRepository(
    BookingApi api,
    BookingCache cache,
  ) {
    return BookingRepository(api: api, cache: cache);
  }
}
```

### Step 6: Controller Adoption

Update controllers to depend on contract:

```dart
class BookingController {
  final BookingRepositoryContract _repository;
  
  BookingController({required BookingRepositoryContract repository})
      : _repository = repository;

  // Use repository through contract
  Future<void> loadBooking(BookingId id) async {
    final booking = await _repository.fetchById(id);
    stateStreamValue.value = booking;
  }
}
```

**Remove any direct DTO parsing from controllers.**

### Step 7: Documentation Update

- Note repository availability in module summaries/system roadmap
- Update `system_roadmap.md` with the new capability or technical debt payoff when it affects planned work

### Step 8: Verification

```bash
fvm flutter analyze
fvm flutter test test/infrastructure/repositories/booking_repository_test.dart
# branch-delta guard when debt program enables disabled rules
bash tool/belluga_custom_lint/bin/check_branch_delta_raw_payload_map.sh
```

## Outputs

- [ ] Repository contract file
- [ ] Repository implementation file
- [ ] DTO mapper mixin covering new conversions
- [ ] DI registration
- [ ] Controller usage updated
- [ ] Documentation/roadmap notes

## Validation Checklist

- [ ] Analyzer/tests pass
- [ ] Controllers/widgets import only the contract, not DTOs
- [ ] DTO handling remains infrastructure-only
- [ ] No presentation imports in repository layer
- [ ] No repository-owned raw payload map parsing/building (`Map<String, Object?>`)
