# ARCHITECTURE.md

lib/
├── core/
├── shared/
├── features/
│ ├── auth/
│ ├── workout/
│ ├── progress/
│ └── settings/
└── main.dart

Feature Structure:
feature/
├── data/
├── domain/
├── presentation/
├── providers/
└── widgets/

Principles:

- Domain independent
- UI dumb
- Providers orchestrate
- Repository pattern
