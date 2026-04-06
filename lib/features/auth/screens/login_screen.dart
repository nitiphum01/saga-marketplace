import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/features/auth/providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _handleGoogleSignIn(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    try {
      await authProvider.signInWithGoogle();

      if (context.mounted && authProvider.isAuthenticated) {
        context.go(authProvider.postLoginRoute);
      }
    } catch (e) {
      if (!context.mounted) return;

      final rawMessage = e.toString().replaceFirst('Exception: ', '');
      final message =
          authProvider.errorMessage ??
          (rawMessage.isNotEmpty
              ? rawMessage
              : 'Access Restricted. Please use your MFU university email.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.kanit()),
          backgroundColor: const Color(0xFFB71C1C),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildBrandMark() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SA',
            style: GoogleFonts.kanit(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.blue.shade700,
            ),
          ),
          Text(
            'GA',
            style: GoogleFonts.kanit(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB71C1C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade100, Colors.green.shade50],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBrandMark(),
                      const SizedBox(height: 28),
                      Card(
                        elevation: 4,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Welcome to SAGA',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.kanit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Sign in with your MFU Google account to continue.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.kanit(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                height: 54,
                                child: ElevatedButton.icon(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : () => _handleGoogleSignIn(
                                          context,
                                          authProvider,
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  icon: authProvider.isLoading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.blue.shade700,
                                                ),
                                          ),
                                        )
                                      : Container(
                                          width: 20,
                                          height: 20,
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          child: Text(
                                            'G',
                                            style: GoogleFonts.kanit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                  label: Text(
                                    authProvider.isLoading
                                        ? 'Signing in...'
                                        : 'Sign in with Google',
                                    style: GoogleFonts.kanit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Only university emails ending in @mfu.ac.th or @lamduan.mfu.ac.th are allowed.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.kanit(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody(context));
  }
}
