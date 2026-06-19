import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase        _registerUseCase;
  final LoginUseCase           _loginUseCase;
  final AuthRemoteDataSource   _authDataSource;

  AuthBloc({
    required RegisterUseCase      registerUseCase,
    required LoginUseCase         loginUseCase,
    required AuthRemoteDataSource authDataSource,
  })  : _registerUseCase = registerUseCase,
        _loginUseCase    = loginUseCase,
        _authDataSource  = authDataSource,
        super(AuthInitial()) {

    on<CheckSavedSession>((event, emit) async {
      emit(AuthLoading());
      try {
        final savedRole = await _authDataSource.getSavedRole();
        if (savedRole != null) {
          emit(AuthSessionRestored(role: savedRole));
        } else {
          emit(AuthNoSession());
        }
      } catch (_) {
        emit(AuthNoSession());
      }
    });

    on<RegisterSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final role = await _registerUseCase(
          event.fullName,
          event.email,
          event.password,
          event.role,
        );
        emit(AuthSuccess(role: role));
      } catch (e) {
        emit(AuthFailureState(_friendlyError(e.toString())));
      }
    });

    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final role = await _loginUseCase(event.email, event.password);
        emit(AuthSuccess(role: role));
      } catch (e) {
        emit(AuthFailureState(_friendlyError(e.toString())));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authDataSource.logout();
        emit(AuthLoggedOut());
      } catch (e) {
        emit(AuthFailureState(e.toString()));
      }
    });


    on<ForgotPasswordSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authDataSource.sendOtp(event.email);
        emit(ForgotPasswordEmailSent(email: event.email));
      } catch (e) {
        // عرض الـ error الحقيقي مؤقتاً للـ debugging
        emit(AuthFailureState(e.toString()));
      }
    });

    on<ResendResetLink>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authDataSource.sendOtp(event.email);
        emit(ResendLinkSuccess());
      } catch (e) {
        emit(AuthFailureState(_friendlyForgotError(e.toString())));
      }
    });

    on<VerifyOtpSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authDataSource.verifyOtp(event.email, event.otp);
        emit(OtpVerifiedSuccess());
      } catch (e) {
        emit(AuthFailureState(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<ResetPasswordSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authDataSource.resetPassword(event.email, event.newPassword);
        emit(PasswordUpdatedSuccess());
      } catch (e) {
        emit(AuthFailureState(e.toString()));
      }
    });
  }

  String _friendlyError(String raw) {
    if (raw.contains('email-already-in-use')) {
      return 'This email is already registered.';
    }
    if (raw.contains('wrong-password') || raw.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    }
    if (raw.contains('user-not-found')) {
      return 'No account found with this email.';
    }
    if (raw.contains('network-request-failed')) {
      return 'No internet connection.';
    }
    return 'Something went wrong. Please try again.';
  }

  String _friendlyForgotError(String raw) {
    if (raw.contains('user-not-found')) {
      return 'No account found with this email address.';
    }
    if (raw.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    if (raw.contains('network-request-failed')) {
      return 'No internet connection.';
    }
    if (raw.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    return 'Failed to send reset link. Please try again.';
  }
}