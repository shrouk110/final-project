import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class CheckEmailScreen extends StatefulWidget {
  final String email;

  const CheckEmailScreen({
    super.key,
    required this.email,
  });

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen>
    with SingleTickerProviderStateMixin {

  final List<TextEditingController> _otpControllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(4, (_) => FocusNode());

  int  _secondsLeft = 60;
  bool _canResend   = false;
  Timer? _timer;

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
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end:   Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic),
    );

    _fadeCtrl.forward();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeCtrl.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _canResend   = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _resend() {
    if (!_canResend) return;
    context.read<AuthBloc>().add(ResendResetLink(email: widget.email));
    _startTimer();
  }

  String get _otp =>
      _otpControllers.map((c) => c.text).join();

  void _submitOtp() {
    final code = _otp;
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         const Text('Please enter all 4 digits'),
          backgroundColor: Colors.red,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    context.read<AuthBloc>().add(
      VerifyOtpSubmitted(email: widget.email, otp: code),
    );
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {

        if (state is OtpVerifiedSuccess) {
          context.go(AppRoutes.resetPassword, extra: widget.email);
        }

        if (state is ResendLinkSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:         const Text('Reset link sent again!'),
              backgroundColor: Colors.green,
              behavior:        SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }

        if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:         Text(state.message),
              backgroundColor: Colors.red,
              behavior:        SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
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
                    _BackButton(
                      onTap: () => context.go(AppRoutes.forgotPassword),
                    ),
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
                        children: [
                          const SizedBox(height: 44),

                          _CheckEmailCard(
                            email:           widget.email,
                            otpControllers:  _otpControllers,
                            focusNodes:      _focusNodes,
                            onOtpChanged:    _onOtpChanged,
                            onNext:          _submitOtp,
                            onResend:        _resend,
                            canResend:       _canResend,
                            secondsLeft:     _secondsLeft,
                            isLoading:       false,
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
        width:  38,
        height: 38,
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size:  18,
          color: AppColors.primary,
        ),
      ),
    );
  }
}


class _CheckEmailCard extends StatelessWidget {
  final String                        email;
  final List<TextEditingController>   otpControllers;
  final List<FocusNode>               focusNodes;
  final void Function(String, int)    onOtpChanged;
  final VoidCallback                  onNext;
  final VoidCallback                  onResend;
  final bool                          canResend;
  final int                           secondsLeft;
  final bool                          isLoading;

  const _CheckEmailCard({
    required this.email,
    required this.otpControllers,
    required this.focusNodes,
    required this.onOtpChanged,
    required this.onNext,
    required this.onResend,
    required this.canResend,
    required this.secondsLeft,
    required this.isLoading,
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
            offset:     const Offset(1, 4),
          ),
        ],
      ),
      child: Column(
        children: [

          Container(
            width:  72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.buttonColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mail_rounded,
              color: Colors.white,
              size:  34,
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Check Your Email',
            style: TextStyle(
              fontFamily:    'AbhayaLibre',
              fontSize:      28,
              fontWeight:    FontWeight.w700,
              color:         AppColors.primary,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            "We've sent a password reset link to your email address.\nPlease check your inbox and follow the instructions to regain access.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:   12,
              height:     1.3,
              color:      AppColors.secondary.withOpacity(0.75),
              fontFamily: 'AbhayaLibre-ExtraBold',
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              return SizedBox(
                width:  63,
                height: 66,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color:        Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller:   otpControllers[i],
                    focusNode:    focusNodes[i],
                    textAlign:    TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength:    1,
                    style: const TextStyle(
                      fontSize:   24,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.primary,
                      height:     1.0,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      counterText:     '',
                      border:          InputBorder.none,
                      isDense:         true,
                      contentPadding:  EdgeInsets.zero,
                    ),
                    onChanged: (v) => onOtpChanged(v, i),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 28),

          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final loading = state is AuthLoading;
              return SizedBox(
                width:  double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: loading ? null : onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: Colors.white,
                    elevation:       3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    shadowColor: AppColors.buttonColor.withOpacity(0.4),
                  ),
                  child: loading
                      ? const SizedBox(
                    width:  22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                      : const Text(
                    'Next',
                    style: TextStyle(
                      fontFamily:    'AbhayaLibre',
                      fontSize:      22,
                      fontWeight:    FontWeight.w700,
                      color:         Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          Column(
            children: [
              Text(
                "Didn't receive the email?",
                style: TextStyle(
                  fontSize:   13,
                  color:      AppColors.secondary.withOpacity(0.75),
                  fontFamily: 'AbhayaLibre-ExtraBold',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: canResend ? onResend : null,
                child: canResend
                    ? const Text(
                  'Resend Link',
                  style: TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.buttonColor,
                  ),
                )
                    : Text(
                  'Resend in ${secondsLeft}s',
                  style: TextStyle(
                    fontSize: 13,
                    color:    AppColors.secondary.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}