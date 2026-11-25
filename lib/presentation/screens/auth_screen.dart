

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _hidePassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        final credential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await credential.user?.updateDisplayName(
          _nameController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'Bu email avval ro‘yxatdan o‘tgan.';
          break;
        case 'invalid-email':
          message = 'Email manzili noto‘g‘ri.';
          break;
        case 'weak-password':
          message = 'Parol kamida 6 ta belgidan iborat bo‘lsin.';
          break;
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Email yoki parol noto‘g‘ri.';
          break;
        case 'network-request-failed':
          message = 'Internet aloqasini tekshiring.';
          break;
        default:
          message = e.message ?? 'Xatolik yuz berdi.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kutilmagan xatolik yuz berdi.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF246BFD);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.location_city_rounded,
                    size: 65,
                    color: blue,
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'SMART CITY TERMEZ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF183B78),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _isLogin
                        ? 'Hisobingizga kiring'
                        : 'Yangi hisob yarating',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (!_isLogin) ...[
                    _buildField(
                      controller: _nameController,
                      label: 'Ism va familiya',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildField(
                    controller: _emailController,
                    label: 'Elektron pochta',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email kiriting';
                      }
                      if (!RegExp(
                        r'^[^@]+@[^@]+\.[^@]+$',
                      ).hasMatch(value.trim())) {
                        return 'Email noto‘g‘ri kiritilgan';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    controller: _passwordController,
                    label: 'Parol',
                    icon: Icons.lock_outline,
                    obscureText: _hidePassword,
                    suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Parol kiriting';
                      }
                      if (value.length < 6) {
                        return 'Parol kamida 6 ta belgidan iborat bo‘lsin';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              _isLogin
                                  ? 'Tizimga kirish'
                                  : 'Ro‘yxatdan o‘tish',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                            _formKey.currentState?.reset();
                          },
                    child: Text(
                      _isLogin
                          ? 'Hisobingiz yo‘qmi? Ro‘yxatdan o‘ting'
                          : 'Hisobingiz bormi? Tizimga kiring',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: blue,
                        fontWeight: FontWeight.w600,
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
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label kiriting';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE5EAF3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF246BFD),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
