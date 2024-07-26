import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:notetaker/services/auth/bloc/auth_bloc.dart';
import 'package:notetaker/services/auth/bloc/auth_event.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
                "We've Sent You a Verification Email, Please Verify to Continue"),
            TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventSendVerification());
              },
              child: const Text("Click Here if you have not received an email"),
            ),
            TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              },
              child: const Text("Restart"),
            )
          ],
        ),
      ),
    );
  }
}
