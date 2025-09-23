import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthEvent {}

class AuthAppStarted extends AuthEvent {}
class AuthSignInWithGoogleRequested extends AuthEvent {}
class AuthSignInWithOAuthRequested extends AuthEvent {}
class AuthSignOutRequested extends AuthEvent {}
// This event is used internally by the BLoC
class AuthUserChanged extends AuthEvent {
  final User? user;
  AuthUserChanged(this.user);
}