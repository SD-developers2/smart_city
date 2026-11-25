
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tizimdan chiqish'),
          content: const Text(
            'Haqiqatan ham hisobingizdan chiqmoqchimisiz?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Chiqish'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.signOut();

      debugPrint(
        'FIREBASE LOGOUT: ${FirebaseAuth.instance.currentUser}',
      );
    } catch (e) {
      debugPrint('LOGOUT ERROR: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tizimdan chiqishda xatolik: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showInfo(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Yopish'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final displayName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : 'Foydalanuvchi';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Mening profilim'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFFE5ECFF),
              child: const Icon(
                Icons.person,
                size: 55,
                color: Color(0xFF3157D5),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Center(
            child: Text(
              displayName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202A44),
              ),
            ),
          ),

          const SizedBox(height: 6),

          Center(
            child: Text(
              user?.email ?? 'Email mavjud emas',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 25),

          _sectionTitle('Shaxsiy ma’lumotlar'),

          _profileTile(
            icon: Icons.location_city,
            title: 'Shahar',
            subtitle: 'Termiz shahri',
          ),

          _profileTile(
            icon: Icons.email_outlined,
            title: 'Elektron pochta',
            subtitle: user?.email ?? 'Mavjud emas',
          ),

          const SizedBox(height: 18),

          _sectionTitle('Sozlamalar'),

          // BILDIRISHNOMALAR
          _profileTile(
            icon: Icons.notifications_outlined,
            title: 'Bildirishnomalar',
            subtitle: 'Kelgan xabarlarni ko‘rish',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const NotificationsScreen(),
                ),
              );
            },
          ),

          _profileTile(
            icon: Icons.language,
            title: 'Til',
            subtitle: 'O‘zbek tili',
            onTap: () {
              _showInfo(
                context,
                'Til sozlamalari',
                'Smart City Termez hozircha '
                    'o‘zbek tilida ishlaydi.',
              );
            },
          ),

          _profileTile(
            icon: Icons.lock_outline,
            title: 'Maxfiylik',
            subtitle: 'Hisob xavfsizligi',
            onTap: () {
              _showInfo(
                context,
                'Maxfiylik',
                'Hisobingiz Firebase Authentication '
                    'orqali boshqariladi.',
              );
            },
          ),

          const SizedBox(height: 18),

          _sectionTitle('Ilova haqida'),

          _profileTile(
            icon: Icons.info_outline,
            title: 'Smart City Termez',
            subtitle: 'Ilova haqida ma’lumot',
            onTap: () {
              _showInfo(
                context,
                'Smart City Termez',
                'Smart City Termez — Termiz shahridagi '
                    'muammolar haqida murojaat yuborish, '
                    'ularni kuzatish va shahar hayotini '
                    'yaxshilashga qaratilgan loyiha.',
              );
            },
          ),

          _profileTile(
            icon: Icons.location_on_outlined,
            title: 'Loyiha hududi',
            subtitle: 'Termiz shahri',
          ),

          _profileTile(
            icon: Icons.code,
            title: 'Ilova versiyasi',
            subtitle: '1.0.0',
          ),

          const SizedBox(height: 25),

          SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text(
                'Tizimdan chiqish',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(
                  color: Colors.red,
                  width: 1.3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFF3157D5),
        ),
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 5,
        ),
        leading: Icon(
          icon,
          color: const Color(0xFF3157D5),
          size: 25,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: onTap != null
            ? const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
