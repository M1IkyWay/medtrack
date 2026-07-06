# Contributing to MedTrack

Thanks for your interest! MedTrack is an open-source portfolio project, but
issues and pull requests are welcome.

## Getting set up

```bash
flutter pub get
dart run build_runner build      # Drift code
flutter gen-l10n                 # localizations
flutter run
```

## Before you open a pull request

Please make sure the same gates CI enforces pass locally:

```bash
dart format .
flutter analyze                  # must be clean
flutter test                     # must be green
```

If you regenerate anything, run `dart run build_runner build` and
`flutter gen-l10n` — generated files are not committed.

## Conventions

- **Clean, feature-first architecture.** Business logic lives in
  `application/` (providers, pure logic) and `data/` (repositories), never in
  widgets.
- **Framework-free domain.** Models and enums in `domain/` must not import
  Flutter or Drift.
- **Immutable state** via `Equatable`.
- **No hard-coded user-facing strings** — add them to the ARB files under
  `lib/l10n/` (English is the template; please add translations where you can).
- **Enums are append-only** — they are persisted by index (see
  [docs/DATA_MODEL.md](docs/DATA_MODEL.md)).
- New repositories / controllers / pure logic should come with tests.

## Commit style

Short, imperative subject lines. Group related changes into one commit.

## License

By contributing, you agree that your contributions are licensed under the
project's [MIT License](LICENSE).
