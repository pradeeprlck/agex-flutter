import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/agex_logo.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _loading = false;
  int _countdown = 0;
  Timer? _timer;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  String _selectedLang = 'EN';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _animController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (_phoneController.text.length < 10) {
      _showSnack('Enter a valid 10-digit phone number');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).sendOtp(_phoneController.text);
      setState(() { _otpSent = true; _countdown = 30; });
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() { _countdown--; if (_countdown <= 0) t.cancel(); });
      });
      _showSnack('OTP sent!', isError: false);
    } catch (_) {
      _showSnack('Failed to send OTP');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.length != 6) {
      _showSnack('Enter a valid 6-digit OTP');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).verifyOtp(
            _phoneController.text, _otpController.text);
      if (mounted) context.go('/dashboard');
    } catch (_) {
      _showSnack('Verification failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.red500 : AppColors.brand600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(child: _buildHero()),
            _buildBottomSheet(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment(0.7, 1),
          colors: [Color(0xFF1A4A2E), Color(0xFF1E6B3A), Color(0xFF2D8B4E), Color(0xFF3DA564)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -80, right: -60,
            child: Container(width: 260, height: 260,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
          Positioned(top: 40, left: -50,
            child: Container(width: 160, height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04)))),
          Positioned(bottom: 30, right: 40,
            child: Transform.rotate(angle: 0.43,
              child: Container(width: 100, height: 180,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50), topRight: Radius.circular(50),
                      bottomLeft: Radius.circular(20), bottomRight: Radius.circular(80)),
                  color: const Color(0xFF4ADE80).withOpacity(0.08))))),
          Positioned(top: MediaQuery.of(context).size.height * 0.17, left: 30,
            child: Container(width: 10, height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFD4A843).withOpacity(0.7)))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AgexLogo(size: 36),
                      Row(children: [
                        for (final lang in ['EN', 'हि', 'తె'])
                          Padding(padding: const EdgeInsets.only(left: 6),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedLang = lang),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: _selectedLang == lang
                                      ? Colors.white.withOpacity(0.92)
                                      : Colors.white.withOpacity(0.12)),
                                child: Text(lang, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                    color: _selectedLang == lang ? const Color(0xFF1A5C32) : Colors.white60)))))
                      ]),
                    ],
                  ),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SMART FARMING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.6), letterSpacing: 1.5)),
                            const SizedBox(height: 8),
                            RichText(text: const TextSpan(
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2, letterSpacing: -0.5),
                              children: [
                                TextSpan(text: 'THE NEW\nERA OF '),
                                TextSpan(text: 'AGRICULTURE', style: TextStyle(color: Color(0xFF86EFAC))),
                              ])),
                            const SizedBox(height: 16),
                            Row(children: [
                              _badge('AI-Powered', false),
                              const SizedBox(width: 10),
                              _badge('🌾 Crop Care', true),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, bool isGold) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isGold ? const Color(0xFFD4A843).withOpacity(0.2) : Colors.white.withOpacity(0.14),
        border: isGold ? Border.all(color: const Color(0xFFD4A843).withOpacity(0.3)) : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (!isGold) ...[
          Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4ADE80))),
          const SizedBox(width: 6),
        ],
        Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
            color: isGold ? const Color(0xFFFFE4A0) : Colors.white.withOpacity(0.85))),
      ]),
    );
  }

  Widget _buildBottomSheet() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4))],
        ),
        padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: const Color(0xFFD4E8D4)))),
              const SizedBox(height: 16),
              Text(_otpSent ? 'Verification Code' : 'Welcome Back',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A2E1A))),
              const SizedBox(height: 4),
              Text(_otpSent ? 'We sent a code to +91 ${''/*_phoneController.text*/}' : 'Sign in to your farming assistant',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8A9A8A), height: 1.4)),
              const SizedBox(height: 18),
              _buildLabel('PHONE NUMBER'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E8E0), width: 1.5),
                  color: const Color(0xFFF7FAF7)),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF5EE),
                      border: Border(right: BorderSide(color: Color(0xFFE0E8E0))),
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(13))),
                    child: const Text('+91', style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2D6B3F)))),
                  Expanded(
                    child: TextField(
                      controller: _phoneController, enabled: !_otpSent,
                      keyboardType: TextInputType.phone, maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
                          color: Color(0xFF1A2E1A), letterSpacing: 0.8),
                      decoration: const InputDecoration(
                        hintText: 'Enter phone number',
                        hintStyle: TextStyle(color: Color(0xFFB5B5B5)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        counterText: ''))),
                ])),
              if (_otpSent) ...[
                const SizedBox(height: 14),
                _buildLabel('VERIFICATION CODE'),
                const SizedBox(height: 8),
                _buildOtpBoxes(),
              ],
              const SizedBox(height: 18),
              _buildCta(),
              if (_otpSent) ...[
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (_countdown > 0)
                    Text('Resend in ${_countdown}s', style: const TextStyle(fontSize: 13, color: Color(0xFF8A9A8A)))
                  else
                    GestureDetector(onTap: _handleSendOtp,
                        child: const Text('Resend OTP', style: TextStyle(fontSize: 13, color: Color(0xFF2D8B4E), fontWeight: FontWeight.w600))),
                  Container(width: 1, height: 14, color: const Color(0xFFE0E8E0), margin: const EdgeInsets.symmetric(horizontal: 12)),
                  GestureDetector(onTap: () => setState(() { _otpSent = false; _otpController.clear(); }),
                      child: const Text('Change number', style: TextStyle(fontSize: 13, color: Color(0xFF6B8A6B), fontWeight: FontWeight.w500))),
                ]),
              ],
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 28, height: 1, color: const Color(0xFFD4E8D4)),
                const SizedBox(width: 10),
                RichText(text: const TextSpan(
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2, color: Color(0xFF6B8A6B)),
                    children: [TextSpan(text: 'Ag'), TextSpan(text: 'Ex', style: TextStyle(color: Color(0xFF2D8B4E)))])),
                const SizedBox(width: 10),
                Container(width: 28, height: 1, color: const Color(0xFFD4E8D4)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCta() {
    return GestureDetector(
      onTap: _loading ? null : (_otpSent ? _handleVerifyOtp : _handleSendOtp),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
              colors: _loading ? [const Color(0xFFC4C4C4), const Color(0xFFA3A3A3)]
                  : [const Color(0xFF2D8B4E), const Color(0xFF1A5C32)]),
          boxShadow: _loading ? [] : [BoxShadow(color: const Color(0xFF1A5C32).withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (_loading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          else ...[
            Expanded(child: Text(_otpSent ? 'Verify OTP' : 'Send OTP', textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5))),
            Container(width: 28, height: 28, margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
                child: const Center(child: Text('→', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)))),
          ],
        ]),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(
      fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B8A6B), letterSpacing: 0.8));

  Widget _buildOtpBoxes() {
    return Stack(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(6, (i) {
        final filled = i < _otpController.text.length;
        return Container(width: 46, height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: filled ? const Color(0xFF4ADE80) : const Color(0xFFE0E8E0), width: filled ? 2 : 1.5),
            color: filled ? const Color(0xFFF0FDF4) : const Color(0xFFF7FAF7)),
          alignment: Alignment.center,
          child: Text(filled ? _otpController.text[i] : '•',
              style: TextStyle(fontSize: filled ? 22 : 16, fontWeight: filled ? FontWeight.w700 : FontWeight.w500,
                  color: filled ? const Color(0xFF1A5C32) : const Color(0xFFC4C4C4))));
      })),
      Positioned.fill(
        child: Opacity(opacity: 0,
          child: TextField(controller: _otpController, keyboardType: TextInputType.number, maxLength: 6, autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(counterText: '', border: InputBorder.none)))),
    ]);
  }
}
