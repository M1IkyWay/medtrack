# 💊 MedTrack — Smart Medication Reminder

> A privacy-first, offline-only medication tracker built around a proper medical
> data model.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

> ⚠️ **Work in progress.** Foundation (Day 1) is in place: architecture,
> theming, routing, localization and the codegen pipeline. Features land over
> the following days. The full README (screenshots, feature tour) arrives once
> the MVP is complete.

## Why this exists

Most medication reminder apps model a name and a time. Real tracking is richer —
dose forms, units, meal relations, finite courses and as-needed (PRN) meds.
MedTrack pairs Flutter engineering with a medical domain model to treat
medication tracking with the complexity it deserves.

## Tech stack

| Category | Choice |
|---|---|
| Framework | Flutter 3.x |
| State | Riverpod 3.x (manual providers) |
| Storage | Drift (SQLite) |
| Routing | go_router |
| Notifications | flutter_local_notifications + timezone |
| i18n | flutter_localizations + ARB (EN · UK · ES · DE) |

## Architecture

Feature-first with clean separation:

```
lib/
├── app/        # MaterialApp, router, theme
├── core/       # Shared utils, extensions, failures
├── data/       # Drift database + services
├── features/   # medications / history / settings
└── l10n/       # ARB translations
```

Each feature is split into `domain/` · `data/` · `application/` ·
`presentation/`.

## Getting started

```bash
flutter pub get
dart run build_runner build      # generates Drift code
flutter gen-l10n                 # generates localizations
flutter run
```

## Testing

```bash
flutter test
```

## License

MIT — see [LICENSE](LICENSE).
