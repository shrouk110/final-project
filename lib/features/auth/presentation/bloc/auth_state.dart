abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String role;
  AuthSuccess({required this.role});
}

class AuthSessionRestored extends AuthState {
  final String role;
  AuthSessionRestored({required this.role});
}

class AuthNoSession extends AuthState {}

class AuthFailureState extends AuthState {
  final String message;
  AuthFailureState(this.message);
}

class AuthLoggedOut extends AuthState {}


class ForgotPasswordEmailSent extends AuthState {
  final String email;
  ForgotPasswordEmailSent({required this.email});
}

class OtpVerifiedSuccess extends AuthState {}

class ResendLinkSuccess extends AuthState {}

class PasswordUpdatedSuccess extends AuthState {}