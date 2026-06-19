import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String _selectedRole = 'patient';
  bool   _hidePassword = true;
  bool   _rememberMe   = false;

  late final AnimationController _logoCtrl;
  late final AnimationController _welcomeCtrl;
  late final Animation<double>   _logoScale;
  late final Animation<double>   _logoFade;
  late final Animation<Offset>   _welcomeSlide;
  late final Animation<double>   _welcomeFade;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn),
    );

    _welcomeCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 700),
    );
    _welcomeSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _welcomeCtrl, curve: Curves.easeOutCubic));
    _welcomeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _welcomeCtrl, curve: Curves.easeIn),
    );

    _logoCtrl.forward().then((_) => _welcomeCtrl.forward());
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _logoCtrl.dispose();
    _welcomeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(LoginSubmitted(
      email:    _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:         Text(state.message),
            backgroundColor: Colors.red,
          ));
        }
        if (state is AuthSuccess) {
          if (state.role == 'doctor') {
            context.go(AppRoutes.doctorHome);
          } else {
            context.go(AppRoutes.patientHome);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [

            Positioned(
              top: 0, left: 0, right: 0,
              child: _TopWave(width: sw, height: sh * 0.17),
            ),

            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _BottomWaveWithEyeImages(width: sw, height: sh * 0.17),
            ),

            Positioned(
              top:   MediaQuery.of(context).padding.top + 10,
              right: 14,
              child: Image.asset(
                'assets/images/eye_image.png',
                width: 36, height: 36,
                errorBuilder: (_, __, ___) => const _EyeStickerFallback(),
              ),
            ),

            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left:   sw * 0.06,
                  right:  sw * 0.06,
                  top:    0,
                  bottom: sh * 0.20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Center(
                        child: AnimatedBuilder(
                          animation: _logoCtrl,
                          builder: (_, child) => FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: child,
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            width:  sw * 0.52,
                            height: sw * 0.52,
                            fit:    BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                            const _LogoFallback(),
                          ),
                        ),
                      ),


                      AnimatedBuilder(
                        animation: _welcomeCtrl,
                        builder: (_, child) => FadeTransition(
                          opacity: _welcomeFade,
                          child: SlideTransition(
                            position: _welcomeSlide,
                            child: child,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Welcome Back',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Corben',
                                  fontSize:   36,
                                  fontWeight: FontWeight.w500,
                                  color:      AppColors.secondary,
                                  height:     1.0,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Log in to vision care  portal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color:    AppColors.secondary.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),

                      _RoleToggle(
                        selectedRole: _selectedRole,
                        onChanged: (r) => setState(() {
                          _selectedRole = r;
                          _emailCtrl.clear();
                          _passwordCtrl.clear();
                          _formKey.currentState?.reset();
                        }),
                      ),
                      SizedBox(height: 32),

                      _InputField(
                        controller:   _emailCtrl,
                        hint:         '@ Enter your Email',
                        icon:         Icons.mail,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter your email';
                          }
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      _InputField(
                        controller:    _passwordCtrl,
                        hint:          'Enter Your Password',
                        icon:          Icons.lock,
                        obscure:       _hidePassword,
                        toggleObscure: () =>
                            setState(() => _hidePassword = !_hidePassword),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            SizedBox(
                              width: 22, height: 22,
                              child: Checkbox(
                                value:       _rememberMe,
                                onChanged:   (v) =>
                                    setState(() => _rememberMe = v ?? false),
                                shape:       const CircleBorder(),
                                side:        BorderSide(
                                  color: AppColors.secondary.withOpacity(0.5),
                                  width: 1.5,
                                ),
                                activeColor: AppColors.buttonColor,
                                checkColor:  Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Remember me',
                                style: TextStyle(
                                  fontSize: 13,
                                  color:    AppColors.secondary.withOpacity(0.8),
                                )),
                          ]),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.forgotPassword),
                            child: Text('Forgot password ?',
                                style: TextStyle(
                                  fontSize:   13,
                                  fontWeight: FontWeight.w600,
                                  color:      AppColors.buttonColor,
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 33),

                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) => _LoginButton(
                          isLoading: state is AuthLoading,
                          onPressed: _submit,
                        ),
                      ),
                      SizedBox(height: sh * 0.022),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Are you new here? ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color:    AppColors.secondary.withOpacity(0.8),
                                )),
                            GestureDetector(
                              onTap: () => context.go(AppRoutes.register),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Create Account',
                                      style: TextStyle(
                                        fontSize:   13,
                                        fontWeight: FontWeight.w700,
                                        color:      AppColors.buttonColor,
                                      )),
                                  const SizedBox(height: 2),
                                  Container(
                                    height: 1.5,
                                    width:  95,
                                    color:  AppColors.secondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sh * 0.022),

                      Center(
                        child: _PageDots(
                            isPatient: _selectedRole == 'patient'),
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
      ..quadraticBezierTo(size.width * 0.75, size.height * 1.1,
          size.width * 0.5, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.5,
          0, size.height * 0.88)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter o) => false;
}


class _BottomWaveWithEyeImages extends StatelessWidget {
  final double width, height;
  const _BottomWaveWithEyeImages({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [

          CustomPaint(
            size: Size(width, height),
            painter: _BottomWavePainter(),
          ),


          Positioned(
            left:   width * 0.01,
            bottom: height * 0.50,
            child: Opacity(
              opacity: 0.55,
              child: Image.asset(
                'assets/images/eye.png',
                width:  45,
                height: 45,
                fit:    BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    _EyeIconFallback(size: 42),
              ),
            ),
          ),

          Positioned(
            left:   width * 0.20,
            top:    height * 0.45,
            child: Opacity(
              opacity: 0.45,
              child: Image.asset(
                'assets/images/eye.png',
                width:  35,
                height: 35,
                fit:    BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    _EyeIconFallback(size: 26),
              ),
            ),
          ),

          Positioned(
            right:  width * 0.06,
            bottom: height * 0.50,
            child: Opacity(
              opacity: 0.55,
              child: Image.asset(
                'assets/images/eye.png',
                width:  42,
                height: 42,
                fit:    BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    _EyeIconFallback(size: 42),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
      ..quadraticBezierTo(size.width * 0.75, size.height * -0.2,
          size.width * 0.5, size.height * 0.15)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.55,
          0, size.height * 0.1)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter o) => false;
}



class _EyeIconFallback extends StatelessWidget {
  final double size;
  const _EyeIconFallback({required this.size});
  @override
  Widget build(BuildContext context) => Icon(
    Icons.remove_red_eye_outlined,
    size:  size * 0.8,
    color: const Color(0xFF415A77).withOpacity(0.4),
  );
}


class _EyeStickerFallback extends StatelessWidget {
  const _EyeStickerFallback();
  @override
  Widget build(BuildContext context) => Container(
    width: 44, height: 44,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.85),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
          blurRadius: 8)],
    ),
    child: const Icon(Icons.remove_red_eye,
        color: Color(0xFF5BC8D8), size: 24),
  );
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();
  @override
  Widget build(BuildContext context) =>
      Icon(Icons.remove_red_eye, color: AppColors.secondary, size: 70);
}

class _RoleToggle extends StatelessWidget {
  final String selectedRole;
  final void Function(String) onChanged;
  const _RoleToggle({required this.selectedRole, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    decoration: BoxDecoration(
      color:        const Color(0xFFF1E9DB).withOpacity(0.8),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(color: Colors.black12,
            blurRadius: 1, offset: const Offset(0, 3)),
      ],
    ),
    child: Row(children: [
      _RoleTab(label: 'Patient', icon: Icons.person_outline,
          selected: selectedRole == 'patient', isLeft: true,
          onTap: () => onChanged('patient')),
      _RoleTab(label: 'Doctor', icon: Icons.medical_services_rounded,
          selected: selectedRole == 'doctor', isLeft: false,
          onTap: () => onChanged('doctor')),
    ]),
  );
}

class _RoleTab extends StatelessWidget {
  final String label; final IconData icon;
  final bool selected, isLeft; final VoidCallback onTap;
  const _RoleTab({required this.label, required this.icon,
    required this.selected, required this.isLeft, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: selected
              ? const LinearGradient(
              colors: [Color(0xFFD4A38C), Color(0xFFD9AE99)],
              begin:  Alignment.centerLeft,
              end:    Alignment.centerRight)
              : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18,
              color: selected ? Colors.white : AppColors.secondary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.secondary,
          )),
        ]),
      ),
    ),
  );
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
  Widget build(BuildContext context) => TextFormField(
    controller: controller, obscureText: obscure,
    keyboardType: keyboardType, validator: validator,
    style: const TextStyle(fontSize: 14, color: AppColors.secondary),
    decoration: InputDecoration(
      hintText:  hint,
      hintStyle: TextStyle(fontSize: 14, color: AppColors.secondary),
      prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
      suffixIcon: toggleObscure != null
          ? IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: AppColors.secondary, size: 20,
          ),
          onPressed: toggleObscure)
          : null,
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: const Color(0xFF415A77).withOpacity(0.4), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: const Color(0xFF415A77).withOpacity(0.4), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.buttonColor, width: 1.8),
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

class _LoginButton extends StatelessWidget {
  final bool isLoading; final VoidCallback onPressed;
  const _LoginButton({required this.isLoading, required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 55,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonColor,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
      ),
      child: isLoading
          ? const SizedBox(width: 22, height: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: Colors.white))
          : Stack(
          alignment: Alignment.center,
          children: [
            const Text('Login', style: TextStyle(
              fontFamily:    'AbhayaLibre',
              fontSize:      27,
              fontWeight:    FontWeight.w700,
              color:         Colors.white,
              letterSpacing: 0.3,
            )),
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.arrow_forward, size: 22, color: Colors.white),
            ),
          ]),
    ),
  );
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
      color: active ? AppColors.secondary
          : AppColors.secondary.withOpacity(0.3),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}