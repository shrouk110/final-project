import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';

class PasswordUpdatedScreen extends StatelessWidget {
  const PasswordUpdatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width:  100,
                height: 100,
                decoration: BoxDecoration(
                  color:        const Color(0xFFF1E9DB),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size:  60,
                  color: AppColors.buttonColor,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Password Updated!',
                style: TextStyle(
                  fontFamily:  'AbhayaLibre',
                  fontSize:    30,
                  fontWeight:  FontWeight.w700,
                  color:       AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),

              // Subtitle
              Text(
                'Your password has been changed successfully. You can now log in with your new password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize:   13,
                  height:     1.5,
                  color:      AppColors.secondary.withOpacity(0.75),
                  fontFamily: 'AbhayaLibre',
                ),
              ),
              const SizedBox(height: 40),

              // Button
              SizedBox(
                width:  double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: Colors.white,
                    elevation:       3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      fontFamily:  'AbhayaLibre',
                      fontSize:    20,
                      fontWeight:  FontWeight.w700,
                      color:       Colors.white,
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