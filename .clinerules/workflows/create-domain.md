---
name: create-domain
description: "Introduce a new Flutter domain aggregate with full architectural rigor—docs, value objects, projections, repository contracts, and DI wiring."
---

# Workflow: Create Domain (Flutter)

## Purpose

Introduce a new Flutter domain aggregate with full architectural rigor—docs, value objects, projections, repository contracts, and DI wiring—aligned with backend-driven UI, DTO→Domain→Projection flow, feature-first structure.

## Triggers

- A Flutter feature needs business logic/data not covered by an existing domain
- Widgets/controllers are using DTOs or ad-hoc models that represent a domain concept
- Architecture docs call for a new aggregate or projection

## Prerequisites

- [ ] Core instructions loaded (`delphi-ai/main_instructions.md`, `system_architecture_principles.md`)
- [ ] Flutter architecture doc reviewed
- [ ] Project-specific docs reviewed (`domain_entities.md`, module summaries/roadmap)
- [ ] Backend/API contracts for the new entity, if available

## Procedure


### Step 0: Package-First Gate
Read the proprietary packages checklist at `delphi-ai/config/ecosystem_packages.yaml & foundation_documentation/local_packages.yaml` and check whether an existing Flutter library already covers this domain. If a matching library exists, extend it. Record the Package-First Assessment. See `paced.core.package-first`.


### Step 1: Document First

Add/extend the domain entry in:
- `foundation_documentation/domain_entities.md` (purpose, invariants, value objects)
- Relevant module summary/system roadmap entry
- Cross-stack impact recorded in the relevant `foundation_documentation/system_roadmap.md` entry

### Step 2: Scaffold Domain Directory

Create the following structure:

```
lib/domain/<domain_name>/
├── <domain_name>.dart           # Entity/aggregate
├── value_objects/
│   └── *.dart                   # Value objects
└── projections/
    └── *.dart                   # Projections for UI
```

### Step 3: Implement Entity with ValueObjects

```dart
// lib/domain/booking/booking.dart
class Booking {
  final BookingId id;
  final BookingStatus status;
  final CustomerName customerName;
  final ScheduledTime scheduledTime;
  final Price totalPrice;

  const Booking({
    required this.id,
    required this.status,
    required this.customerName,
    required this.scheduledTime,
    required this.totalPrice,
  });

  // Business logic methods
  bool get isEditable => status == BookingStatus.pending;
  
  Booking confirm() {
    if (!isEditable) {
      throw BookingNotEditableException();
    }
    return Booking(
      id: id,
      status: BookingStatus.confirmed,
      customerName: customerName,
      scheduledTime: scheduledTime,
      totalPrice: totalPrice,
    );
  }
}
```

### Step 4: Define Value Objects

```dart
// lib/domain/booking/value_objects/booking_status.dart
enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled;

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => throw InvalidBookingStatusException(value),
    );
  }
}
```

### Step 5: Define Projections

Place in `lib/domain/<domain_name>/projections/`:

```dart
// lib/domain/booking/projections/booking_summary.dart
class BookingSummary {
  final String id;
  final String displayStatus;
  final String formattedTime;
  final String formattedPrice;
  final bool canEdit;

  const BookingSummary({
    required this.id,
    required this.displayStatus,
    required this.formattedTime,
    required this.formattedPrice,
    required this.canEdit,
  });

  // Projections expose UI-ready primitives
  // Widgets/controllers never reformat data
}
```

### Step 6: Repository Contract

Create/extend in `lib/domain/repositories/`:

```dart
// lib/domain/repositories/booking_repository_contract.dart
abstract class BookingRepositoryContract {
  Future<Booking> fetchById(BookingId id);
  Future<List<BookingSummary>> fetchSummaries(DateTimeRange range);
  Future<Booking> create(CreateBookingParams params);
  Future<Booking> update(Booking booking);
  Stream<BookingDelta> watchDeltas();
}
```

**Important:**
- Domain-centric methods (no screen language)
- Add TODO comments if method temporarily returns projections

### Step 7: Infrastructure Mapping

Create DTO mappers in `lib/infrastructure/mappers/`:

```dart
mixin BookingMapper {
  Booking toDomain(BookingDTO dto) {
    return Booking(
      id: BookingId(dto.id),
      status: BookingStatus.fromString(dto.status),
      customerName: CustomerName(dto.customerName),
      scheduledTime: ScheduledTime.parse(dto.scheduledTime),
      totalPrice: Price.fromCents(dto.totalPriceCents),
    );
  }

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
}
```

### Step 8: Dependency Injection

Register in feature module or `module_settings.dart`:

```dart
@module
abstract class BookingModule {
  @lazySingleton
  BookingRepositoryContract provideRepository(BookingRepository impl) {
    return impl;
  }
}
```

### Step 9: Controller/Presentation Cleanup

- Update controllers/widgets to depend on new domain types
- Remove DTO/view-model leaks
- Keep widgets pure UI

### Step 10: Verification

- Run `fvm flutter analyze`
- Run unit tests for new domain types
- Verify DTOs remain confined to infrastructure

## Outputs

- [ ] Updated domain + module documentation
- [ ] `lib/domain/<domain_name>/` with entity, value objects, projections
- [ ] Repository contract + infrastructure mapper/implementation registered in DI
- [ ] Controllers/widgets consuming the domain types
- [ ] TODO comments for deferred backend fields

## Validation Checklist

- [ ] Analyzer/tests pass with new domain wired
- [ ] Documentation reflects new concept (no dangling placeholders)
- [ ] DTOs remain confined to infrastructure
- [ ] Presentation imports only domain types
