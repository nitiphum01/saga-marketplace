# SAGA — student marketplace with in-app chat

A Flutter app where students buy and sell from each other and message the seller without leaving the
listing. Built solo, bilingual Thai / English from the first screen.

## What it does

**Marketplace** — browse listings, post an item with photos, edit or delete your own, and see
everything you have listed in one place.
**Chat** — message a seller from the product page; a push notification reaches them even when the app
is closed.
**Profile & settings** — first-run profile setup, account details, and a language switch.

## Architecture

```
Flutter app (Android · iOS · Web)
        │
        ├── Firebase Auth ──────── email + Google Sign-In
        ├── Cloud Firestore ────── listings, chats, profiles
        ├── Firebase Storage ───── product images (CDN-backed)
        └── Cloud Messaging ────── delivery handled by a Cloud Function
                                           │
                 functions/src/index.ts ───┘
                 onDocumentCreated(chats/{id}/messages/{id})
                      → look up the recipient's device tokens
                      → sendEachForMulticast(...)
```

`lib/` is organised feature-first rather than by layer, so everything one feature needs sits together:

```
lib/
├── core/
│   ├── constants/      shared values
│   ├── localization/   Thai / English strings
│   ├── providers/      app-wide state
│   ├── services/       Firebase and network access — the UI never calls Firebase directly
│   └── widgets/        shared components
└── features/
    ├── auth/           login, 632 lines
    ├── marketplace/    listings, posting, editing, 3,418 lines
    ├── chat/           chat list and room, 1,509 lines
    ├── profile/        setup and profile, 587 lines
    └── settings/       account and language, 444 lines
```

12 screens, about 7,400 lines of Dart in `lib/`.

Keeping the service layer separate from the UI is deliberate: swapping Firestore for a REST API means
rewriting `core/services/`, not touching a single screen.

## Running it

Needs the Flutter SDK (Dart ^3.11) and a Firebase project of your own.

```bash
flutter pub get
flutterfire configure     # writes firebase_options.dart for your project
flutter run
```

The push notification is a separate deploy:

```bash
cd functions
npm install
npm run deploy            # firebase deploy --only functions
```

Without it the app still runs and chat still works — messages just arrive only while the app is open.

## Built with

| | |
|---|---|
| App | Flutter · Dart |
| State / routing | Provider · go_router |
| Backend | Firebase Auth · Cloud Firestore · Firebase Storage · Cloud Messaging |
| Functions | TypeScript on Cloud Functions for Firebase |
| Images | Cloudinary · `cached_network_image` |
| Other | `flutter_localizations` · `intl` · `google_fonts` · `image_picker` |

## Known limits

- No automated tests yet — the only coverage is Flutter's default widget test.
- Images go through Cloudinary as well as Firebase Storage; one of the two should go.
- No payment or delivery flow: a sale is arranged in chat, not in the app.
  
# flutter_application_1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
