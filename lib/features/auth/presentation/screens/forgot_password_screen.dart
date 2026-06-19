import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

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
    _emailCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      ForgotPasswordSubmitted(email: _emailCtrl.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ForgotPasswordEmailSent) {
          context.go(
            AppRoutes.checkEmail,
            extra: state.email,
          );
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
                    _BackButton(onTap: () => context.go(AppRoutes.login)),
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

                          _ForgotCard(
                            formKey:   _formKey,
                            emailCtrl: _emailCtrl,
                            onSubmit:  _submit,
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
          boxShadow: [
            BoxShadow(
              color:      Colors.black12,
              blurRadius: 50,
              offset:     const Offset(0, 2),
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


class _ForgotCard extends StatelessWidget {
  final GlobalKey<FormState>    formKey;
  final TextEditingController   emailCtrl;
  final VoidCallback            onSubmit;

  const _ForgotCard({
    required this.formKey,
    required this.emailCtrl,
    required this.onSubmit,
  });

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

            const Text(
              'Forgot Password',
              style: TextStyle(
                fontFamily:    'AbhayaLibre',
                fontSize:      30,
                fontWeight:    FontWeight.w700,
                color:         AppColors.primary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 14),

            Text(
              "Enter your email address below. We'll send you a secure link to reset your password and regain access to your medical suite.",
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                color:    AppColors.secondary.withOpacity(0.75),
                fontFamily: 'AbhayaLibre-ExtraBold',
                fontWeight:  FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'Email Address',
              style: TextStyle(
                fontFamily:  'AbhayaLibre',
                fontSize:    18,
                fontWeight:  FontWeight.w700,
                color:       AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),


            TextFormField(
              controller:   emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                fontSize: 14,
                color:    AppColors.secondary,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter your email address';
                }
                final emailRegex =
                RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');
                if (!emailRegex.hasMatch(v.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText:  'e.g., dr.smith@wonderbrand.com',
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  color:    AppColors.secondary.withOpacity(0.55),
                ),
                filled:    true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.secondary.withOpacity(0.3),
                    width: 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.secondary.withOpacity(0.3),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: AppColors.buttonColor,
                    width: 1.8,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1.2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),


            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) => _SendButton(
                isLoading: state is AuthLoading,
                onPressed: onSubmit,
              ),
            ),
            const SizedBox(height: 22),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Remember your password?',
                    style: TextStyle(
                      fontSize: 13,
                      color:    AppColors.secondary.withOpacity(0.7),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.login),
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize:   13,
                        fontWeight: FontWeight.w700,
                        color:      AppColors.buttonColor,
                      ),
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


class _SendButton extends StatelessWidget {
  final bool         isLoading;
  final VoidCallback onPressed;

  const _SendButton({required this.isLoading, required this.onPressed});

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
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: Colors.white),
        )
            : Stack(
          alignment: Alignment.center,
          children: const [
            Text(
              'Send Reset Link',
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