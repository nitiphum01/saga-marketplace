import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/features/profile/models/user_profile_model.dart';

/// Profile screen showing detailed student information
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Mock user profile data
  UserProfile get _mockProfile => UserProfile(
    studentId: '6531234567',
    name: 'Somchai Jai-dee',
    profileImageUrl: 'https://via.placeholder.com/150',
    programOfStudy: 'Bachelor of Science',
    fieldOfStudy: 'Information Technology',
    school: 'School of Information Technology',
    mobilePhone: '081-234-5678',
    personalEmail: 'somchai.j@gmail.com',
    universityEmail: 'somchai.j@lamduan.mfu.ac.th',
    emergencyContactName: 'Mrs. Malee Jai-dee (Mother)',
    emergencyContactPhone: '089-876-5432',
    advisorName: 'Dr. Smart Panya',
    advisorPhone: '053-123-456',
    advisorEmail: 'smart.p@mfu.ac.th',
  );

  @override
  Widget build(BuildContext context) {
    final profile = _mockProfile;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFB71C1C),
        title: Text(
          'Student Profile',
          style: GoogleFonts.kanit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header - Profile Picture, Name, and Student ID
            _buildHeader(profile),

            const SizedBox(height: 16),

            // Section 1: Academic Information
            _buildSection(
              title: 'Academic Information',
              icon: Icons.school,
              iconColor: const Color(0xFFB71C1C),
              children: [
                _buildInfoTile(
                  label: 'Program of Study',
                  value: profile.programOfStudy,
                  icon: Icons.menu_book,
                ),
                _buildInfoTile(
                  label: 'Field of Study',
                  value: profile.fieldOfStudy,
                  icon: Icons.category,
                ),
                _buildInfoTile(
                  label: 'School',
                  value: profile.school,
                  icon: Icons.school_outlined,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 2: Contact Information
            _buildSection(
              title: 'Contact Information',
              icon: Icons.contact_phone,
              iconColor: const Color(0xFFB71C1C),
              children: [
                _buildInfoTile(
                  label: 'Mobile Phone',
                  value: profile.mobilePhone,
                  icon: Icons.phone_android,
                ),
                _buildInfoTile(
                  label: 'Personal Email',
                  value: profile.personalEmail,
                  icon: Icons.email_outlined,
                ),
                _buildInfoTile(
                  label: 'University Email',
                  value: profile.universityEmail,
                  icon: Icons.email,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 3: Emergency Contact (Highlighted)
            _buildEmergencyContactSection(profile),

            const SizedBox(height: 16),

            // Section 4: Advisor Information (Business Card Style)
            _buildAdvisorSection(profile),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Builds the header with profile picture, name, and student ID
  Widget _buildHeader(UserProfile profile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFB71C1C),
            const Color(0xFFB71C1C).withOpacity(0.8),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          // Profile Picture
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4AF37), width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 60, color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(height: 20),
          // Student Name
          Text(
            profile.name,
            style: GoogleFonts.kanit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Student ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ID: ${profile.studentId}',
              style: GoogleFonts.kanit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a section container with title and children
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  /// Builds an information tile (label + value with icon)
  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.kanit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.kanit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the emergency contact section with red accent
  Widget _buildEmergencyContactSection(UserProfile profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB71C1C).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB71C1C).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Emergency Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFB71C1C).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB71C1C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Emergency Contact',
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB71C1C),
                  ),
                ),
              ],
            ),
          ),
          // Emergency Contact Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoTile(
                  label: 'Contact Name',
                  value: profile.emergencyContactName,
                  icon: Icons.person_outline,
                ),
                _buildInfoTile(
                  label: 'Contact Phone',
                  value: profile.emergencyContactPhone,
                  icon: Icons.phone_in_talk,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the advisor section in business card style
  Widget _buildAdvisorSection(UserProfile profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFD4AF37).withOpacity(0.1), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Advisor Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.badge, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Academic Advisor',
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Business Card Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Advisor Name (Prominent)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.grey.shade700,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        profile.advisorName,
                        style: GoogleFonts.kanit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Contact Details
                _buildAdvisorContactRow(
                  icon: Icons.phone,
                  value: profile.advisorPhone,
                ),
                const SizedBox(height: 12),
                _buildAdvisorContactRow(
                  icon: Icons.email,
                  value: profile.advisorEmail,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a contact row for advisor information
  Widget _buildAdvisorContactRow({
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFB71C1C)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.kanit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
