import 'package:flutter_application_1/core/providers/language_provider.dart';

class AppTranslations {
  static const Map<String, Map<String, String>> _map = {
    'en': {
      'appTitle': 'SAGA - Student Marketplace',
      'settings': 'Settings',
      'account': 'Account',
      'myListings': 'My Listings',
      'listedProducts': 'Listed products',
      'editProfile': 'Edit Profile',
      'editProfileSoon': 'Edit Profile - Coming Soon',
      'general': 'General',
      'notifications': 'Notifications',
      'newMessageAlert': 'New message alert',
      'language': 'Language',
      'english': 'English',
      'thai': 'Thai',
      'support': 'Support',
      'itSupportUniversity': 'IT Support University',
      'logout': 'Log out',
      'logoutConfirm': 'Are you sure you want to log out?',
      'cancel': 'Cancel',
    },
    'th': {
      'appTitle': 'SAGA - ตลาดนักศึกษา',
      'settings': 'ตั้งค่า',
      'account': 'บัญชี',
      'myListings': 'รายการของฉัน',
      'listedProducts': 'สินค้าที่ลงขาย',
      'editProfile': 'แก้ไขโปรไฟล์',
      'editProfileSoon': 'ฟีเจอร์แก้ไขโปรไฟล์กำลังมาเร็วๆ นี้',
      'general': 'ทั่วไป',
      'notifications': 'การแจ้งเตือน',
      'newMessageAlert': 'แจ้งเตือนข้อความใหม่',
      'language': 'ภาษา',
      'english': 'อังกฤษ',
      'thai': 'ไทย',
      'support': 'ช่วยเหลือ',
      'itSupportUniversity': 'ศูนย์ไอทีมหาวิทยาลัย',
      'logout': 'ออกจากระบบ',
      'logoutConfirm': 'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?',
      'cancel': 'ยกเลิก',
    },
  };

  static String tr(LanguageProvider provider, String key) {
    final code = provider.locale.languageCode;
    return _map[code]?[key] ?? _map['en']?[key] ?? key;
  }
}
