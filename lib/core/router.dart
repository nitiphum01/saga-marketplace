import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/features/auth/screens/login_screen.dart';
import 'package:flutter_application_1/features/auth/providers/auth_provider.dart';
import 'package:flutter_application_1/features/marketplace/models/product_model.dart';
import 'package:flutter_application_1/features/marketplace/screens/home_screen.dart';
import 'package:flutter_application_1/features/marketplace/screens/product_detail_screen.dart';
import 'package:flutter_application_1/features/marketplace/screens/add_product_screen.dart';
import 'package:flutter_application_1/features/marketplace/screens/my_listings_screen.dart';
import 'package:flutter_application_1/features/marketplace/screens/edit_product_screen.dart';
import 'package:flutter_application_1/features/chat/screens/chat_list_screen.dart';
import 'package:flutter_application_1/features/chat/screens/chat_room_screen.dart';
import 'package:flutter_application_1/features/profile/screens/profile_screen.dart';
import 'package:flutter_application_1/features/settings/screens/settings_screen.dart';
import 'package:flutter_application_1/core/widgets/scaffold_with_navbar.dart';

/// GoRouter configuration for SAGA
///
/// Routes:
/// - /login: Login screen (no bottom nav)
/// - /home: Marketplace home (with bottom nav)
/// - /chat: Chat list (with bottom nav)
/// - /profile: User profile (with bottom nav)
/// - /settings: Settings (with bottom nav)
/// - /add-product: Add product (no bottom nav)
GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/';

      // Redirect unauthenticated users to login
      if (!isAuthenticated && !isLoggingIn) {
        return '/';
      }

      // Redirect authenticated users away from login
      if (isAuthenticated && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Login route - NO bottom nav
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),

      // Main app routes with persistent bottom nav
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Add product route - NO bottom nav
      GoRoute(
        path: '/add-product',
        builder: (context, state) => const AddProductScreen(),
      ),

      // Product Detail route - NO bottom nav
      GoRoute(
        path: '/product-detail',
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductDetailScreen(product: product);
        },
      ),

      // Chat Room route - NO bottom nav
      GoRoute(
        path: '/chat-room',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ChatRoomScreen(
            roomId: extra['roomId'],
            product: extra['product'],
            sellerId: extra['sellerId'],
          );
        },
      ),

      // My Listings route - NO bottom nav
      GoRoute(
        path: '/my-listings',
        builder: (context, state) => const MyListingsScreen(),
      ),

      // Edit Product route - NO bottom nav
      GoRoute(
        path: '/edit-product',
        builder: (context, state) {
          final product = state.extra as Product;
          return EditProductScreen(product: product);
        },
      ),
    ],
  );
}
