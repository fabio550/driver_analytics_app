# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                # install dependencies
flutter analyze                # static analysis — run before committing
flutter test                   # unit tests live under test/, mirroring lib/
flutter run                    # run the app (needs a connected device/emulator)

# Drift (SQLite) code generation — required after touching any *_table.dart,
# or any @DriftDatabase table list, or adding/changing a Drift query:
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # while iterating
```

There is no backend in this repo — see "Planned backend" below.

`HomePage` has a "Popular dados de exemplo" button behind `kDebugMode`
(`core/infrastructure/database/seed_data_service.dart`) that inserts
~6 months of shifts/fuel/maintenance/financing/taxes/insurance straight
through the repositories — useful to get enough history to exercise
`CostAllocationCalculator`'s window/interval logic without hand-entering
months of data through the UI. It never ships in a release build and it
only adds data, never clears existing rows.

## Architecture

Flutter app, 100% local persistence (Drift/SQLite), Riverpod 3 for state,
go_router for navigation. No backend, no sync, no auth today.

### Navigation

Four tabs behind a `StatefulShellRoute.indexedStack` (`core/routes/
routes.dart`, shell chrome in `core/presentation/pages/app_shell_page.dart`):

| tab | route | page |
|---|---|---|
| Início | `/` | `HomePage` — the day: start a shift, this week's summary, recent shifts |
| Jornadas | `/shifts` | `ShiftsPage` |
| Lançamentos | `/entries` | `EntriesPage` — Ganhos and Custos as two segments |
| Análises | `/analytics` | `AnalyticsPage` |

Each branch keeps its own stack. Everything else (forms, the active
shift, the shift summary) is a **top-level** `GoRoute`, so it renders
above the shell on the root navigator and hides the nav bar. Add a new
form there, not inside a branch.

`EntriesPage` lives in `core/presentation/` because it composes two
features: it owns the segment/filter chrome and delegates to
`EarningsListView` (earning) and `CostListView` (cost), which stay in
their own features.

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
  (xs/sm/md/lg/xl), `AppRadius` (sm/md/lg + `xl` for hero cards),
  `AppSizes`, `AppTextStyles` (only for text styles that don't map to a
  `TextTheme` role), `AppColors` (single seed color), `AppChartColors`
  (separate categorical palette for chart series, not from the Material
  color scheme). Always use these instead of literal
  `SizedBox(height: 16)` / `EdgeInsets.all(24)` / raw colors.
- **`ColorScheme.fromSeed` runs with `DynamicSchemeVariant.vibrant`**
  (`AppTheme`). The default variant (`tonalSpot`) resolves the
  `#2E5CFF` seed to `#4F5B92`, a desaturated slate: the brand colour
  never reached the screen. `test/core/presentation/theme/app_theme_test.dart`
  pins this so the variant can't silently go back.
- **`AppSemanticColors`** (a `ThemeExtension`, read with
  `AppSemanticColors.of(context)`) is the only place profit / loss /
  pending colours live. Use `forAmount(value)` for any money figure
  whose sign matters — before it, a negative net profit was painted in
  `colorScheme.primary`, i.e. blue. Colour is never the only signal: the
  sign and the label carry it too.
- **Money and time digits use `.tabular`** (`AppTextStyles`, an extension
  on `TextStyle`): `textTheme.titleMedium?.copyWith(...).tabular`.
  Without it a column of values shifts as digits change.
- **`EmptyStateView`, `ErrorStateView`, `SkeletonBox`/`SkeletonCard`**
  (`core/presentation/widgets/`) are the three non-happy states. An
  empty list always says what to do next and offers the action; an
  error always offers a retry; loading uses a skeleton shaped like the
  real content, never a centred spinner, so the layout doesn't jump.
- **Forms**: `AmountField` for the one money figure the form is about
  (bigger box, focused border), `FormSection` for the eyebrow-labelled
  groups, `FormSwitchTile` for a switch that needs to explain *why* it
  matters, `PrimaryButton` pinned via `Scaffold.bottomNavigationBar`.
- **`ScreenScrollView`** (`core/presentation/widgets/`) is the standard
  scrollable screen body (`SafeArea` + consistent padding, plus a fixed
  `Scrollbar` on desktop only). Use it instead of a bare `ListView`/
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
- **Detailing rides is optional.** The finish-shift dialog takes km,
  gross earnings and, if the driver wants, the rides of the shift
  (`RideDraft` → persisted with the new shift's id once it finishes, in
  `ActiveShiftPage._saveRides`). A shift with no linked rides is normal,
  not incomplete: nothing in the UI compares the sum of the rides
  against `shift.earnings`, and no screen gates on that. The domain
  still computes `OperationAnalytics.completeness` / `hasDetail` but no
  screen reads them.
- **Fuel efficiency (km/L)** is only computed between two full-tank
  fill-ups (`FuelCostEntity.isFullTank`) in the period — with fewer than
  two it's `null`, never estimated. `R$/km` and `R$/litro` are plain
  averages and don't need that constraint.
- `RideEarningEntity.pickupDistrictId` / `destinationDistrictId` exist in
  the entity and the Drift table but **no screen sets them yet** — the
  district ranking in Analytics will be empty until some UI populates
  these (see "Planned backend" — they were added for a geo-resolution
  pipeline that isn't built).
- **Cost allocation (`CostAllocationCalculator`, `analytics/domain/
  services/`)**: the "cost" that feeds net profit/R$-per-hour is not the
  raw sum of what was logged in the period — it's a smoothed rate applied
  to the period, one method per `CostAllocationMethod`
  (`cost/domain/enums/`, classification via `cost/domain/extensions/
  cost_allocation_extensions.dart`, **not** a presentation label):
  - `kmDriven` (fuel, all of maintenance): rate × km driven in the
    period. Maintenance's rate uses the entire history up to the
    period's end (a tire doesn't pay for itself in a short window);
    fuel's rate uses a window starting last calendar month, expanding a
    month at a time until it finds 2 full tanks (fuel price moves too
    fast for an all-time average), reusing `FuelConsumptionCalculator`.
  - `timeDriven` (financing/taxes/insurance, each isolated): rate = most
    recent entry's amount ÷ days since that subcategory's previous
    entry — self-adapts to whatever cadence that subcategory actually
    has, no hardcoded "30 days"/"365 days" anywhere.
  - `direct` (parking/carWash/fine/toll/other): raw sum, never smoothed.
  A group's rate locks (`attributedCost = null`) only with exactly one
  data point (can't tell a one-off from a pattern yet); zero entries
  ever is a legitimate zero. Locking is per-group — one group short on
  history falls back to its own raw amount, it never blocks the other
  groups or the whole total. `costAllocationProvider` computes this once
  and both `SummaryAnalyticsCalculator` and `CostAnalyticsCalculator`
  consume it, to avoid the kind of duplication the §7.1 rule above
  already has. The existing period-scoped `FuelEfficiencyStats` (the
  "Combustível" card's consumo/R$-km/R$-litro) is unrelated and
  unaffected by any of this.
- **"Lucro por dia" (Resumo)** only plots days with a `submitted` shift
  starting that day — a cost or loose earning logged on a day with no
  shift still counts in the period total but doesn't get its own bar.

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
