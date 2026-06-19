import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey      = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm  = true;

  late final AnimationController _fadeCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final email = GoRouterState.of(context).extra as String;
    context.read<AuthBloc>().add(
      ResetPasswordSubmitted(
        email:       email,
        newPassword: _passwordCtrl.text.trim(),
      ),
    );}
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PasswordUpdatedSuccess) {
          context.go(AppRoutes.passwordUpdated);
        }
        if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:         Text(state.message),
            backgroundColor: Colors.red,
            behavior:        SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _BackButton(onTap: () => context.go(AppRoutes.checkEmail, extra: widget.email)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 44),
                          _ResetCard(
                            formKey:          _formKey,
                            passwordCtrl:     _passwordCtrl,
                            confirmCtrl:      _confirmCtrl,
                            obscurePassword:  _obscurePassword,
                            obscureConfirm:   _obscureConfirm,
                            onTogglePassword: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                            onToggleConfirm: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                            onSubmit: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Back Button ──────────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  35,
        height: 38,
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: const [
            BoxShadow(
              color:      Colors.black12,
              blurRadius: 50,
              offset:     Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size:  20,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── Main Card ────────────────────────────────────────────────────
class _ResetCard extends StatelessWidget {
  final GlobalKey<FormState>  formKey;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool                  obscurePassword;
  final bool                  obscureConfirm;
  final VoidCallback          onTogglePassword;
  final VoidCallback          onToggleConfirm;
  final VoidCallback          onSubmit;

  const _ResetCard({
    required this.formKey,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onSubmit,
  });

  InputDecoration _fieldDecoration({
    required bool         isObscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText:  '••••••••',
      hintStyle: TextStyle(
        fontSize:      13.5,
        color:         AppColors.secondary.withOpacity(0.55),
        letterSpacing: 2,
      ),
      filled:    true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 18, vertical: 18),
      suffixIcon: GestureDetector(
        onTap: onToggle,
        child: Icon(
          isObscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.secondary,
          size:  22,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
            color: AppColors.secondary.withOpacity(0.3), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
            color: AppColors.secondary.withOpacity(0.3), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
            color: AppColors.buttonColor, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E9DB),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:      Colors.black12.withOpacity(0.2),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Title
            const Text(
              'Reset Password',
              style: TextStyle(
                fontFamily:    'AbhayaLibre',
                fontSize:      30,
                fontWeight:    FontWeight.w700,
                color:         AppColors.primary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 14),

            // Subtitle
            Text(
              'Please enter your new password below to regain access to your account.',
              style: TextStyle(
                fontSize:   12,
                height:     1.3,
                color:      AppColors.secondary.withOpacity(0.75),
                fontFamily: 'AbhayaLibre',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // New Password
            const Text(
              'New Password',
              style: TextStyle(
                fontFamily: 'AbhayaLibre',
                fontSize:   18,
                fontWeight: FontWeight.w700,
                color:      AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller:  passwordCtrl,
              obscureText: obscurePassword,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.secondary),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter a new password';
                }
                if (v.trim().length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
              decoration: _fieldDecoration(
                isObscure: obscurePassword,
                onToggle:  onTogglePassword,
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Password
            const Text(
              'Confirm New Password',
              style: TextStyle(
                fontFamily: 'AbhayaLibre',
                fontSize:   18,
                fontWeight: FontWeight.w700,
                color:      AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller:  confirmCtrl,
              obscureText: obscureConfirm,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.secondary),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please confirm your password';
                }
                if (v.trim() != passwordCtrl.text.trim()) {
                  return 'Passwords do not match';
                }
                return null;
              },
              decoration: _fieldDecoration(
                isObscure: obscureConfirm,
                onToggle:  onToggleConfirm,
              ),
            ),
            const SizedBox(height: 28),

            // Button
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) => _UpdateButton(
                isLoading: state is AuthLoading,
                onPressed: onSubmit,
              ),
            ),
            const SizedBox(height: 22),

            // Secure note
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 14,
                      color: AppColors.secondary.withOpacity(0.55)),
                  const SizedBox(width: 5),
                  Text(
                    'Secure 256-bit encrypted connection',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.secondary.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Update Button ────────────────────────────────────────────────
class _UpdateButton extends StatelessWidget {
  final bool         isLoading;
  final VoidCallback onPressed;

  const _UpdateButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          foregroundColor: Colors.white,
          elevation:       3,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          shadowColor: AppColors.buttonColor.withOpacity(0.4),
        ),
        child: isLoading
            ? const SizedBox(
          width:  22,
          height: 22,
          child:  CircularProgressIndicator(
              strokeWidth: 2.5, color: Colors.white),
        )
            : Stack(
          alignment: Alignment.center,
          children: const [
            Text(
              'Update Password',
              style: TextStyle(
                fontFamily:    'AbhayaLibre',
                fontSize:      20,
                fontWeight:    FontWeight.w700,
                color:         Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.arrow_forward,
                  size: 22, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}