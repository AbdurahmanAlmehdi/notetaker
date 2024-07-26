import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notetaker/constants/routes.dart';
import 'package:notetaker/helper/loading/loading_screen.dart';
import 'package:notetaker/services/auth/auth_service.dart';
import 'package:notetaker/services/auth/bloc/auth_bloc.dart';
import 'package:notetaker/services/auth/bloc/auth_event.dart';
import 'package:notetaker/services/auth/bloc/auth_state.dart';
import 'package:notetaker/views/notes/create_update_notes_view.dart';
import 'package:notetaker/views/notes/notes_view.dart';
import 'package:notetaker/views/verifyemail_view.dart';
import 'views/register_view.dart';
import 'package:flutter/material.dart';
import 'views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 99, 25, 134)),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => AuthBloc(AuthService.firebase()),
        child: const HomePage(),
      ),
      routes: {
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading == true) {
          LoadingScreen()
              .show(context: context, text: state.isLoadingText as String);
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailPage();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );

    // return FutureBuilder(
    //   future: AuthService.firebase().initialize(),
    //   builder: (context, snapshot) {
    //     switch (snapshot.connectionState) {
    //       case ConnectionState.done:
    //         final user = AuthService.firebase().currentuser;
    //         if (user != null) {
    //           if (user.isEmailVerified) {
    //             return const NotesView();
    //           } else {
    //             return const VerifyEmailPage();
    //           }
    //         } else {
    //           return const LoginView();
    //         }

    //       default:
    //         return const CircularProgressIndicator();
    //     }
    //   },
    // );
  }
}
