import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

String errorMessage(Object error) {
  if (error is NotAMemberException) return error.message;
  if (error is MatchStateException) return error.message;
  if (error is EmailAccountLoginException) {
    return 'Check your email and password, or try again later.';
  }
  if (error is AuthUserBlockedException) {
    return 'This account is blocked. Ask your supervisor for help.';
  }
  if (error is SignInWhileAuthenticatedException) {
    return 'Sign out before using another account.';
  }
  if (error is ServerpodClientException) {
    return 'Server unavailable. Check the connection and try again.';
  }
  return error.toString().replaceFirst('Exception: ', '');
}

Future<T?> runGuarded<T>(
  BuildContext context,
  Future<T> Function() action, {
  VoidCallback? onDenied,
}) async {
  try {
    return await action();
  } catch (error) {
    if (!context.mounted) return null;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage(error))));
    if (error is NotAMemberException) onDenied?.call();
    return null;
  }
}
