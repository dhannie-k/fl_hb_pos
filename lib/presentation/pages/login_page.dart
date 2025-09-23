import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthenState>(
      // Listen for errors to show a SnackBar
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: BlocBuilder<AuthBloc, AuthenState>(
            builder: (context, state) {
              // Show a loading indicator when signing in
              if (state is AuthLoading) {
                return const CircularProgressIndicator();
              }
              
              return ElevatedButton.icon(
                icon: const Icon(Icons.login), // Or a Google logo
                label: const Text('Sign in with Google'),
                onPressed: () {
                  // Dispatch the sign-in event to the BLoC
                  if(!kIsWeb && (
                    Platform.isAndroid || Platform.isIOS
                  )){
                  context.read<AuthBloc>().add(AuthSignInWithGoogleRequested());
                  }else{
                    context.read<AuthBloc>().add(AuthSignInWithOAuthRequested());
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}