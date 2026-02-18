import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/features/auth/providers/auth_provider.dart';
import 'package:flutter_application_1/features/auth/services/auth_service.dart';
import 'package:flutter_application_1/features/marketplace/providers/product_provider.dart';
import 'package:flutter_application_1/features/marketplace/services/product_service.dart';
import 'package:flutter_application_1/features/chat/providers/chat_provider.dart';
import 'package:flutter_application_1/core/router.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized before Firebase setup
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

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
      ],
      child: MaterialApp.router(
        title: 'SAGA - Student Marketplace',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: mfuDeepRed,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.kanitTextTheme(),
        ),
        routerConfig: createRouter(),
      ),
    );
  }
}
