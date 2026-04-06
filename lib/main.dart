import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/features/auth/providers/auth_provider.dart';
import 'package:flutter_application_1/features/auth/services/auth_service.dart';
import 'package:flutter_application_1/features/marketplace/providers/product_provider.dart';
import 'package:flutter_application_1/features/marketplace/services/product_service.dart';
import 'package:flutter_application_1/features/chat/providers/chat_provider.dart';
import 'package:flutter_application_1/core/providers/language_provider.dart';
import 'package:flutter_application_1/core/localization/app_translations.dart';
import 'package:flutter_application_1/core/services/notification_service.dart';
import 'package:flutter_application_1/core/router.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.onBackgroundMessage(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initializeForegroundHandlers();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // SAGA Colors
    const Color mfuDeepRed = Color(0xFFB71C1C);

    return MultiProvider(
      providers: [
        // Auth Provider with Mock Service
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService: MockAuthService()),
        ),
        // Product Provider with Mock Service
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(productService: MockProductService()),
        ),
        // Chat Provider
        ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
        // Language Provider
        ChangeNotifierProvider<LanguageProvider>(
          create: (_) => LanguageProvider(),
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return MaterialApp.router(
            title: AppTranslations.tr(languageProvider, 'appTitle'),
            locale: languageProvider.locale,
            supportedLocales: const [Locale('en'), Locale('th')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: mfuDeepRed,
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.kanitTextTheme(),
            ),
            routerConfig: createRouter(),
          );
        },
      ),
    );
  }
}
