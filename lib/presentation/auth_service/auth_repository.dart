import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabaseClient;

  // Use the singleton instance provided by the package
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  AuthRepository({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  // A helper to initialize GoogleSignIn only once
  Future<void> _initializeGoogleSignIn() async {
    if (_isGoogleSignInInitialized) return;

    // Your webClientId from Google Cloud Console
    await _googleSignIn.initialize(
      serverClientId:
          '620314944174-9sd3ahcsgrsbb39b9g6urf77h9e7s4g1.apps.googleusercontent.com',
    );
    _isGoogleSignInInitialized = true;
  }

  /// Stream of authentication state changes.
  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;

  /// Gets the current authenticated user, if any.
  User? get currentUser => _supabaseClient.auth.currentUser;

  /// Signs in with Google and exchanges the token with Supabase.
  Future<void> signInWithGoogle() async {
    try {
      await _initializeGoogleSignIn();

      // Start with a silent sign-in attempt
      GoogleSignInAccount? googleUser = await _googleSignIn
          .attemptLightweightAuthentication();

      // If silent sign-in fails, trigger the interactive sign-in.
      // authenticate() will throw an exception if the user cancels.
      googleUser ??= await _googleSignIn.authenticate();

      // The 'if (googleUser == null)' check is removed as it's unreachable.

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      const scopes = ['email', 'profile'];
      // authorizeScopes() will also throw on failure.
      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
          await googleUser.authorizationClient.authorizeScopes(scopes);

      final accessToken = authorization.accessToken;

      // The 'if (accessToken == null)' check is removed as it's unreachable.

      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw 'Sign in failed with Supabase.';
      }
    } on AuthException catch (e) {
      print('Supabase Auth Error: ${e.message}');
      throw 'Authentication failed. Please try again.';
    } catch (e) {
      // This block will now catch cancellations from googleUser.authenticate()
      print('Generic Sign-In Error: $e');
      throw 'An unexpected error occurred during sign-in.';
    }
  }

  Future<void> signInWithOAuth() async {
    await _supabaseClient.auth.signInWithOAuth(OAuthProvider.google);
  }

  /// Signs out from both Supabase and Google.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabaseClient.auth.signOut();
    } catch (e) {
      print('Sign Out Error: $e');
      throw 'An error occurred during sign-out.';
    }
  }
}
