import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _fullNameCtrl    = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  String _selectedRole = 'patient';
  bool   _hidePassword = true;
  bool   _hideConfirm  = true;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }


  void _clearFields() {
    _fullNameCtrl.clear();
    _emailCtrl.clear();
    _passwordCtrl.clear();
    _confirmPassCtrl.clear();
    _formKey.currentState?.reset();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      RegisterSubmitted(
        fullName: _fullNameCtrl.text.trim(),
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role:     _selectedRole,
      ),
    );
  }


  Future<void> _signInWithGoogle() async {
    try {
      // TODO: استبدلي بـ Google Sign-In حقيقي لما الـ datasource يتعمل
      // final googleUser = await GoogleSignIn().signIn();
      // if (googleUser == null) return;
      // final googleAuth = await googleUser.authentication;
      // context.read<AuthBloc>().add(GoogleSignInSubmitted(
      //   idToken:     googleAuth.idToken!,
      //   accessToken: googleAuth.accessToken!,
      // ));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign-in — wire datasource first'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:         Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state is AuthSuccess) {
          // TODO: context.go(AppRoutes.home)
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [

            Positioned(
              top: 0, left: 0, right: 0,
              child: _TopWave(width: sw, height: sh * 0.18),
            ),


            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _BottomWave(width: sw, height: sh * 0.18),
            ),


            Positioned(
              top:   MediaQuery.of(context).padding.top + 10,
              right: 14,
              child: Image.asset(
                'assets/images/eye_image.png',
                width: 48, height: 48,
                errorBuilder: (_, __, ___) => const _EyeFallback(),
              ),
            ),


            SafeArea(
              bottom: false,
              child: SingleChildScrollView(

                padding: EdgeInsets.only(
                  left:   sw * 0.06,
                  right:  sw * 0.06,
                  top:    12,
                  bottom: sh * 0.20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: sh * 0.025),


                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontFamily: 'Copse',
                          fontSize:   43,
                          fontWeight: FontWeight.w400,
                          color:      AppColors.secondary,
                          height:     1.1,
                        ),
                      ),
                      const SizedBox(height: 15),

                      const Text(
                        'Who Are You ?',
                        style: TextStyle(
                          fontSize:   14,
                          fontWeight: FontWeight.w500,
                          color:      AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 35),


                      _RoleToggle(
                        selectedRole: _selectedRole,
                        onChanged: (r) {
                          _clearFields();
                          setState(() => _selectedRole = r);
                        },
                      ),


                      const SizedBox(height: 35),

                      _InputField(
                        controller: _fullNameCtrl,
                        hint:       'Full Name',
                        icon:       Icons.person,
                        validator:  (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter your full name' : null,
                      ),
                      const SizedBox(height: 12),

                      _InputField(
                        controller:   _emailCtrl,
                        hint:         '@ Email Address',
                        icon:         Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter your email';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      _InputField(
                        controller:    _passwordCtrl,
                        hint:          'Password',
                        icon:          Icons.lock,
                        obscure:       _hidePassword,
                        toggleObscure: () =>
                            setState(() => _hidePassword = !_hidePassword),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter a password';
                          if (v.length < 8) return 'At least 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      _InputField(
                        controller:    _confirmPassCtrl,
                        hint:          'Confirm Password',
                        icon:          Icons.password,
                        obscure:       _hideConfirm,
                        toggleObscure: () =>
                            setState(() => _hideConfirm = !_hideConfirm),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirm your password';
                          if (v != _passwordCtrl.text) return 'Passwords do not match';
                          return null;
                        },
                      ),


                      const SizedBox(height: 26),
                      _PageDots(isPatient: _selectedRole == 'patient'),


                      const SizedBox(height: 26),


                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) => _RegistrationButton(
                          isLoading: state is AuthLoading,
                          onPressed: _submit,
                        ),
                      ),
                      const SizedBox(height: 16),


                      _OrDivider(),
                      const SizedBox(height: 14),


                      _GoogleButton(onPressed: _signInWithGoogle),
                      const SizedBox(height: 18),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already a member ? ',
                            style: TextStyle(
                              fontSize: 13,
                              color:    AppColors.secondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.login),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Log in',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.buttonColor,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                Container(
                                  width: 38,
                                  height: 1.5,
                                  color: AppColors.secondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _TopWave extends StatelessWidget {
  final double width, height;
  const _TopWave({required this.width, required this.height});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(width, height), painter: _TopWavePainter());
}

class _TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1E9DB).withOpacity(0.4)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.55)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 1.1,
          size.width * 0.5,  size.height * 0.8)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.5,
          0,                 size.height * 0.88)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter o) => false;
}

class _BottomWave extends StatelessWidget {
  final double width, height;
  const _BottomWave({required this.width, required this.height});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(width, height), painter: _BottomWavePainter());
}

class _BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1E9DB).withOpacity(0.4)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height * 0.3)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * -0.2,
          size.width * 0.5,  size.height * 0.15)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.55,
          0,                 size.height * 0.1)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter o) => false;
}

class _EyeFallback extends StatelessWidget {
  const _EyeFallback();
  @override
  Widget build(BuildContext context) => Container(
    width: 48, height: 48,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.85),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
    ),
    child: const Icon(Icons.remove_red_eye_outlined,
        color: Color(0xFF5BC8D8), size: 26),
  );
}


class _RoleToggle extends StatelessWidget {
  final String selectedRole;
  final void Function(String) onChanged;
  const _RoleToggle({required this.selectedRole, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color:const Color(0xFFF1E9DB).withOpacity(0.8),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color:Colors.black12,
            blurRadius: 1,
            offset:const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _RoleTab(
            label:    'Patient',
            icon:     Icons.person_outline,
            selected: selectedRole == 'patient',
            isLeft:   true,
            onTap:    () => onChanged('patient'),
          ),
          _RoleTab(
            label:    'Doctor',
            icon:     Icons.medical_services_rounded,
            selected: selectedRole == 'doctor',
            isLeft:   false,
            onTap:    () => onChanged('doctor'),
          ),
        ],
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  final String label; final IconData icon;
  final bool selected, isLeft; final VoidCallback onTap;
  const _RoleTab({
    required this.label, required this.icon,
    required this.selected, required this.isLeft, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 50,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: selected
                ? const LinearGradient(
              colors: [Color(0xFFD4A38C), Color(0xFFD9AE99)],
              begin:  Alignment.centerLeft,
              end:    Alignment.centerRight,

            )
                : null,
            color: selected ? null : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20,
                  color: selected ? Colors.white : AppColors.secondary),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontSize:   17,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.secondary,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}


class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint; final IconData icon;
  final bool obscure; final VoidCallback? toggleObscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller, required this.hint, required this.icon,
    this.obscure = false, this.toggleObscure,
    this.keyboardType = TextInputType.text, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:   controller,
      obscureText:  obscure,
      keyboardType: keyboardType,
      validator:    validator,
      style: const TextStyle(fontSize: 14, color: AppColors.secondary),
      decoration: InputDecoration(
        hintText:  hint,
        hintStyle: TextStyle(
          fontSize: 14,
          color:    AppColors.secondary.withOpacity(0.6),
        ),

        prefixIcon: Icon(icon,
            color: AppColors.secondary, size: 20),
        suffixIcon: toggleObscure != null
            ? IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off
                : Icons.visibility,
            color: AppColors.secondary,
            size:  20,
          ),
          onPressed: toggleObscure,
        )
            : null,
        filled:    true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF415A77).withOpacity(0.4),
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF415A77).withOpacity(0.4),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: AppColors.buttonColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.8),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final bool isPatient;
  const _PageDots({required this.isPatient});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _Dot(active: isPatient),
      const SizedBox(width: 6),
      _Dot(active: !isPatient),
    ],
  );
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 220),
    width: active ? 18 : 8, height: 8,
    decoration: BoxDecoration(
      color: active
          ? AppColors.secondary
          : AppColors.secondary.withOpacity(0.3),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}


class _RegistrationButton extends StatelessWidget {
  final bool isLoading; final VoidCallback onPressed;
  const _RegistrationButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 56,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonColor,
        foregroundColor: Colors.white,
        elevation:       3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
      ),
      child: isLoading
          ? const SizedBox(
          width: 22, height: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: Colors.white))
          : Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Registration',
            style: TextStyle(
              fontSize:      27,
              fontWeight:    FontWeight.w700,
              fontFamily:    'AbhayaLibre',
              color:         Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.arrow_forward, size: 22, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Divider(
        color: AppColors.secondary.withOpacity(0.25), thickness: 1)),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text('OR Continue With',
          style: TextStyle(
              fontSize: 12,
              color:    AppColors.secondary.withOpacity(0.6))),
    ),
    Expanded(child: Divider(
        color: AppColors.secondary.withOpacity(0.25), thickness: 1)),
  ]);
}


class _GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GoogleButton({required this.onPressed});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onPressed,
    child: Container(
      width:  double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset:     const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Image.asset(
            'assets/icons/google.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          const Text(
            'Google',
            style: TextStyle(
              fontSize:   20,
              fontWeight: FontWeight.w600,
              color:      AppColors.buttonColor,
            ),
          ),
        ],
      ),
    ),
  );
}


class _GoogleLogoFallback extends StatelessWidget {
  const _GoogleLogoFallback();
  @override
  Widget build(BuildContext context) => const Text(
    'G',
    style: TextStyle(
      fontSize:   20,
      fontWeight: FontWeight.bold,
    ),
  );
}