import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/widgets/saga_app_bar.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();

  bool _consentGiven = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return _displayNameController.text.trim().isNotEmpty &&
        _consentGiven &&
        !_isSubmitting;
  }

  Future<void> _completeSetup() async {
    if (!_canSubmit || !_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your session has expired. Please sign in again.',
            style: GoogleFonts.kanit(),
          ),
          backgroundColor: const Color(0xFFB71C1C),
        ),
      );
      context.go('/');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id).set({
        'uid': user.id,
        'email': user.email,
        'displayName': _displayNameController.text.trim(),
        'consentGiven': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      authProvider.markProfileSetupComplete();

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: GoogleFonts.kanit(),
          ),
          backgroundColor: AppColors.mfuRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: SagaAppBar(
        backgroundColor: AppColors.mfuBlue,
        title: Text(
          'Profile Setup & Consent',
          style: GoogleFonts.kanit(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome to SAGA! Let's set up your profile",
                          style: GoogleFonts.kanit(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We only collect the minimum information needed to help buyers and sellers identify each other.',
                          style: GoogleFonts.kanit(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 22),
                        TextFormField(
                          controller: _displayNameController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Display Name or Store Name',
                            hintText: 'e.g. SAGA Books Corner',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: GoogleFonts.kanit(),
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            final name = value?.trim() ?? '';
                            if (name.isEmpty) {
                              return 'Please enter your display name.';
                            }
                            if (name.length < 2) {
                              return 'Display name must be at least 2 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CheckboxListTile(
                            value: _consentGiven,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            onChanged: _isSubmitting
                                ? null
                                : (value) {
                                    setState(() {
                                      _consentGiven = value ?? false;
                                    });
                                  },
                            title: Text(
                              'I consent to SAGA storing my display name and university email.',
                              style: GoogleFonts.kanit(
                                fontSize: 13.5,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _canSubmit ? _completeSetup : null,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Complete Setup',
                                    style: GoogleFonts.kanit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
