import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../login_controller.dart';

/// Desktop-optimised login form with wider fields, hover states,
/// and keyboard-friendly UX.
class DesktopLoginForm extends GetView<LoginController> {
  const DesktopLoginForm({super.key});

  static const Color _electricBlue = Color(0xFF06B6D4);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Welcome text ──
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFF06B6D4)],
                  ).createShader(bounds),
                  child: const Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your account to continue',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.5),
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Email ──
                _buildLabel('Email Address', Icons.alternate_email_rounded),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  cursorColor: _electricBlue,
                  decoration: _inputDecoration(
                    hint: 'you@company.com',
                    icon: Icons.email_outlined,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    // Move focus to password on Enter
                    FocusScope.of(context).nextFocus();
                  },
                ),
                const SizedBox(height: 20),

                // ── Password ──
                _buildLabel('Password', Icons.lock_outline_rounded),
                const SizedBox(height: 8),
                Obx(
                  () => TextFormField(
                    controller: controller.passwordCtrl,
                    obscureText: controller.obscurePassword.value,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    cursorColor: _electricBlue,
                    decoration: _inputDecoration(
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                    ).copyWith(
                      suffixIcon: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: IconButton(
                          icon: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 20,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Password is required';
                      }
                      if (v.length < 6) return 'At least 6 characters';
                      return null;
                    },
                    onFieldSubmitted: (_) => controller.signIn(),
                  ),
                ),
                const SizedBox(height: 10),

                // ── Forgot password ──
                Align(
                  alignment: Alignment.centerRight,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: _electricBlue.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Sign-in button with hover ──
                _DesktopSignInButton(controller: controller),

                const SizedBox(height: 24),

                // ── Footer ──
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xFF06B6D4),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _electricBlue.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.25),
        fontSize: 15,
      ),
      prefixIcon:
          Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.35)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.07),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: _electricBlue.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}

/// Sign-in button with hover elevation effect for desktop.
class _DesktopSignInButton extends StatefulWidget {
  const _DesktopSignInButton({required this.controller});
  final LoginController controller;

  @override
  State<_DesktopSignInButton> createState() => _DesktopSignInButtonState();
}

class _DesktopSignInButtonState extends State<_DesktopSignInButton> {
  bool _hovered = false;

  static const Color _richIndigo = Color(0xFF4F46E5);
  static const Color _neonPurple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _hovered
                ? [_neonPurple, _richIndigo]
                : [_richIndigo, _neonPurple],
          ),
          boxShadow: [
            BoxShadow(
              color: _richIndigo.withValues(alpha: _hovered ? 0.6 : 0.4),
              blurRadius: _hovered ? 32 : 24,
              offset: Offset(0, _hovered ? 10 : 8),
            ),
          ],
        ),
        child: Obx(
          () => ElevatedButton(
            onPressed: widget.controller.isLoading.value
                ? null
                : widget.controller.signIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: widget.controller.isLoading.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rocket_launch_rounded,
                          size: 20, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'Launch Meeting',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
