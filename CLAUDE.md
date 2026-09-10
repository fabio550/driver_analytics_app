# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                # install dependencies
flutter analyze                # static analysis — run before committing
flutter test                   # no test files exist yet, but this is how they'd run
flutter run                    # run the app (needs a connected device/emulator)

# Drift (SQLite) code generation — required after touching any *_table.dart,
# or any @DriftDatabase table list, or adding/changing a Drift query:
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # while iterating
```

There is no backend in this repo — see "Planned backend" below.

## Architecture

Flutter app, 100% local persistence (Drift/SQLite), Riverpod 3 for state,
go_router for navigation. No backend, no sync, no auth today.

### Per-feature layering

Each feature under `lib/features/<feature>/` (`shift`, `cost`, `earning`,
`analytics`) is split into the same four layers:

```
domain/          entities, enums, repository interfaces, validators — no Flutter/Drift imports
application/     Riverpod providers, Notifier + State classes, use cases
infrastructure/  Drift tables, repository implementations, entity<->row mappers
presentation/    pages, widgets, dialogs, label extensions
```

`analytics` has no `infrastructure/` — it's purely derived: its
calculators read the *already-loaded* state of the other three features'
notifiers (via `ref.watch(shiftNotifierProvider)` etc.) and compute on
top, with no persistence of its own.

A typical write flow: `Page` (StatefulWidget/ConsumerStatefulWidget) →
calls a method on a `*Notifier` (e.g. `ShiftNotifier.createShift`) →
notifier calls a use case (`CreateShiftUseCase`) → use case runs a
`*Validator` and, if valid, calls the repository → repository (Drift)
persists via a mapper → notifier reloads the list and updates `*State`.

### Core conventions (apply across all features)

- **`Result<T, E>`** (`sealed class` with `Success`/`Failure`) is the
  return type of use cases that can fail validation — never throw for an
  expected validation error. Consume with a `switch` (`case Success(:final value): ... case Failure(:final error): ...`).
- **`ValidationFailure<TField>`** (`field`, `message`, optional `index`
  for a failure inside a list item, e.g. a bad pause) is the `E` in that
  `Result` for create/update use cases. `TField` is a feature-specific
  enum (`ShiftField`, `CostField`, `EarningField`).
- **`LoadStatus`** (`initial/loading/loaded/error`, `core/domain/enums/`)
  is the single enum every `*State` with a loaded list uses — don't
  invent a per-feature loading enum.
- **Sealed entities** for closed sets of subtypes: `CostEntity`
  (`FuelCostEntity`/`MaintenanceCostEntity`/`ExpenseCostEntity`),
  `EarningEntity` (`RideEarningEntity`/`PromotionEarningEntity`/
  `AdjustmentEarningEntity`). Each subtype lives in its own file as
  `part of` the sealed base file. Switch over these exhaustively (no
  `default`) so adding a new subtype forces every call site to be
  updated by the compiler.
- **Design tokens live in `core/presentation/theme/`** — `AppSpacing`
  (xs/sm/md/lg/xl), `AppRadius`, `AppSizes`, `AppTextStyles` (only for
  text styles that don't map to a `TextTheme` role), `AppColors` (single
  seed color, `ColorScheme.fromSeed` — never hardcode a color in a
  widget), `AppChartColors` (separate categorical palette for chart
  series, not from the Material color scheme). Always use these instead
  of literal `SizedBox(height: 16)` / `EdgeInsets.all(24)` / raw colors.
- **`ScreenScrollView`** (`core/presentation/widgets/`) is the standard
  scrollable screen body (`SafeArea` + always-visible `Scrollbar` +
  consistent padding). Use it instead of a bare `ListView`/
  `SingleChildScrollView` for any full-screen content — it was renamed
  from `FormScrollView` because it's used well beyond forms (active
  shift screen, analytics tabs).
- **Enum display labels are extensions**, never inline `switch` in a
  widget: `presentation/extensions/*_extensions.dart` per feature (e.g.
  `RideServiceTypeLabel`, `CostCategoryLabel`, `RevenueSourceLabel`).
- Drift migrations: bump `AppDatabase.schemaVersion` and add an
  `if (from < N) { await m.createTable(...); }` branch in `onUpgrade` —
  never edit a table's existing columns in place without a migration
  branch for existing installs.

### Business rules that aren't obvious from types alone

- **Shift status machine**: `idle → active ⇄ paused → finished →
  submitted`. Only `submitted` shifts count in Analytics — a `finished`
  shift can still be discarded from the summary screen, so counting it
  early would be wrong.
- **Revenue fallback (§7.1)**: when a shift has linked `EarningEntity`
  rows, their sum is the revenue; when it has none, `shift.earnings`
  (declared manually on finish) is used instead. This same rule is
  duplicated across `SummaryAnalyticsCalculator`,
  `OperationAnalyticsCalculator` and `RevenueAnalyticsCalculator` —
  change all three together if it changes.
- **Operation completeness (checksum)**: a shift only unlocks the
  detailed Operação tab (time/km split, pace, hourly earnings, district
  ranking) if the sum of its linked earnings matches its declared
  `shift.earnings` (or it has no linked earnings at all, so there's
  nothing to reconcile). Otherwise the tab shows how much is missing in
  currency instead of a possibly-wrong number.
- **Fuel efficiency (km/L)** is only computed between two full-tank
  fill-ups (`FuelCostEntity.isFullTank`) in the period — with fewer than
  two it's `null`, never estimated. `R$/km` and `R$/litro` are plain
  averages and don't need that constraint.
- `RideEarningEntity.pickupDistrictId` / `destinationDistrictId` exist in
  the entity and the Drift table but **no screen sets them yet** — the
  district ranking in Analytics will be empty until some UI populates
  these (see "Planned backend" — they were added for a geo-resolution
  pipeline that isn't built).

## Planned backend (not implemented)

An earlier planning doc describes a future Python/FastAPI backend +
Supabase/Postgres, with OCR-based ride import (Google ML Kit on-device →
extracted text sent to backend → per-app regex parser → geo resolution
from CEP → dedup hash → `rides` table) and a `zone → district →
postal_code → ride` geographic model. None of that exists in this repo
yet — the app today is entirely local/manual entry. Don't assume sync,
auth, or any network call exists when reading this codebase; if backend
work starts, check with the user for the fuller design doc before
inventing schema.
