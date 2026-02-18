import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/features/auth/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validates email format for MFU domain
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.endsWith('@lamduan.mfu.ac.th')) {
      return 'Only MFU students (@lamduan.mfu.ac.th) allowed';
    }
    return null;
  }

  /// Validates password field
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Handles the login action
  Future<void> _handleLogin(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        // Navigate to home on success
        context.go('/home');
      }
    } catch (e) {
      // Error is handled by AuthProvider and displayed via snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Login failed',
              style: GoogleFonts.kanit(),
            ),
            backgroundColor: const Color(0xFFB71C1C),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.green.shade50],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // SAGA Logo
                _buildLogo(),
                const SizedBox(height: 40),
                // Login Card
                _buildLoginCard(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the SAGA logo with blue "SA" and red "GA"
  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SA',
            style: GoogleFonts.kanit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          Text(
            'GA',
            style: GoogleFonts.kanit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFB71C1C),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main login card with form fields
  Widget _buildLoginCard(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'login',
                    style: GoogleFonts.kanit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    'Please enter your information to login',
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Email/Your ID Field
                  _buildTextFieldLabel('Your ID'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    validator: _validateEmail,
                    enabled: !authProvider.isLoading,
                    decoration: InputDecoration(
                      hintText: 'Enter your MFU email',
                      hintStyle: GoogleFonts.kanit(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.blue.shade400,
                      ),
                      filled: true,
                      fillColor: Colors.blue.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      errorStyle: GoogleFonts.kanit(fontSize: 12),
                    ),
                    style: GoogleFonts.kanit(fontSize: 14),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  // Password Field
                  _buildTextFieldLabel('Password'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    validator: _validatePassword,
                    enabled: !authProvider.isLoading,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: GoogleFonts.kanit(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.blue.shade400,
                      ),
                      filled: true,
                      fillColor: Colors.blue.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      errorStyle: GoogleFonts.kanit(fontSize: 12),
                    ),
                    style: GoogleFonts.kanit(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  // Remember & Forgot Password Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: authProvider.isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                              activeColor: const Color(0xFFB71C1C),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Remember',
                            style: GoogleFonts.kanit(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: authProvider.isLoading
                            ? null
                            : () {
                                // Handle forgot password
                              },
                        child: Text(
                          'Forgot password ?',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: const Color(0xFFB71C1C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _handleLogin(context, authProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        disabledBackgroundColor: Colors.blue.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.8),
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'login',
                              style: GoogleFonts.kanit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds a label for text fields
  Widget _buildTextFieldLabel(String label) {
    return Row(
      children: [
        Icon(
          label == 'Your ID' ? Icons.person_outline : Icons.lock_outline,
          size: 18,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
