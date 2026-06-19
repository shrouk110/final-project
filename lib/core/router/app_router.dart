import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:graduate_data_set/features/auth/presentation/screens/splash_screen.dart';
import 'package:graduate_data_set/features/auth/presentation/screens/login_screen.dart';
import 'package:graduate_data_set/features/auth/presentation/screens/register_screen.dart';
import 'package:graduate_data_set/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:graduate_data_set/features/auth/presentation/screens/check_email_screen.dart';
import 'package:graduate_data_set/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:graduate_data_set/features/auth/presentation/screens/password_updated_screen.dart';
import 'package:graduate_data_set/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:graduate_data_set/features/auth/presentation/bloc/auth_event.dart';
import 'package:graduate_data_set/features/auth/presentation/bloc/auth_state.dart';
import 'package:graduate_data_set/injection_container.dart';

class AppRoutes {
  static const String splash          = '/';
  static const String register        = '/register';
  static const String login           = '/login';
  static const String forgotPassword  = '/forgot-password';
  static const String checkEmail      = '/check-email';
  static const String resetPassword   = '/reset-password';
  static const String passwordUpdated = '/password-updated';
  static const String patientHome     = '/patient-home';
  static const String doctorHome      = '/doctor-home';
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,

    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.path}')),
    ),

    routes: [

      // ── Splash ────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splash,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthBloc>()..add(CheckSavedSession()),
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {
              if (authState is AuthSessionRestored) {
                authState.role == 'doctor'
                    ? context.go(AppRoutes.doctorHome)
                    : context.go(AppRoutes.patientHome);
              } else if (authState is AuthNoSession) {
                context.go(AppRoutes.login);   // ← الـ splash بتوجه للـ login
              }
            },
            child: const SplashScreen(),
          ),
        ),
      ),

      // ── Login ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthBloc>(),
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {
              if (authState is AuthSuccess) {
                authState.role == 'doctor'
                    ? context.go(AppRoutes.doctorHome)
                    : context.go(AppRoutes.patientHome);
              }
            },
            child: const LoginScreen(),
          ),
        ),
      ),

      // ── Register ──────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.register,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthBloc>(),
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {
              if (authState is AuthSuccess) {
                authState.role == 'doctor'
                    ? context.go(AppRoutes.doctorHome)
                    : context.go(AppRoutes.patientHome);
              }
            },
            child: const RegisterScreen(),
          ),
        ),
      ),

      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPassword,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthBloc>(),
          child: const ForgotPasswordScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.checkEmail,
        name: AppRoutes.checkEmail,
        builder: (context, state) {
          final email = state.extra as String;

          return BlocProvider(
            create: (_) => sl<AuthBloc>(),
            child: CheckEmailScreen(email: email),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.resetPassword,
        name: AppRoutes.resetPassword,
        builder: (context, state) {
          final email = state.extra as String;
          return BlocProvider(
            create: (_) => sl<AuthBloc>(),
            child: ResetPasswordScreen(email: email),
          );
        },
      ),



      GoRoute(
        path: AppRoutes.passwordUpdated,
        name: AppRoutes.passwordUpdated,
        builder: (context, state) => const PasswordUpdatedScreen(),
      ),
      // ── Doctor Home (placeholder) ─────────────────────────────
      GoRoute(
        path: AppRoutes.doctorHome,
        name: AppRoutes.doctorHome,
        builder: (context, state) => _PlaceholderScreen(
          title: 'Doctor Home',
          color: const Color(0xFF415A77),
        ),
      ),
    ],
  );
}

// ── Placeholder مؤقت ──────────────────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final Color  color;
  const _PlaceholderScreen({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: color, size: 80),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            const Text('Coming soon...', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                await prefs.remove('uid');
                await prefs.remove('role');
                await FirebaseAuth.instance.signOut();
                if (context.mounted) context.go(AppRoutes.login);
              },
              icon:  const Icon(Icons.logout, color: Colors.white),
              label: const Text('Logout',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}