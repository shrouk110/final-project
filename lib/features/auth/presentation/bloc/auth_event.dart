abstract class AuthEvent {}

class RegisterSubmitted extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String role;

  RegisterSubmitted({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
  });
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  LoginSubmitted({
    required this.email,
    required this.password,
  });
}

class CheckSavedSession extends AuthEvent {}

class LogoutRequested extends AuthEvent {}


class ForgotPasswordSubmitted extends AuthEvent {
  final String email;
  ForgotPasswordSubmitted({required this.email});
}

class VerifyOtpSubmitted extends AuthEvent {
  final String email;
  final String otp;
  VerifyOtpSubmitted({required this.email, required this.otp});
}

class ResendResetLink extends AuthEvent {
  final String email;
  ResendResetLink({required this.email});
}

class ResetPasswordSubmitted extends AuthEvent {
  final String email;
  final String newPassword;
  ResetPasswordSubmitted({required this.email, required this.newPassword});
}