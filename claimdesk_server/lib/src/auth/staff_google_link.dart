import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

import '../generated/protocol.dart';

/// Google sign-in is for people already on a desk team, never a way to sign
/// up. A Google account is linked to the staff member whose email account has
/// the same verified address; anyone else is refused before anything is
/// written.
class StaffGoogleLink {
  static const refusal =
      'This Google account is not on a desk team. Ask your supervisor to add you.';

  /// Links [details] to the matching staff member unless it is already
  /// linked. Throws [NotStaffException] for unverified addresses, unknown
  /// addresses and accounts without a venue membership.
  static Future<void> linkIfStaff(
    Session session,
    GoogleAccountDetails details,
  ) async {
    final linked = await GoogleIdpAdmin.findUserByGoogleUserId(
      session,
      userIdentifier: details.userIdentifier,
    );
    if (linked != null) return;
    if (details.verifiedEmail != true) {
      throw NotStaffException(message: refusal);
    }
    final email = details.email.trim().toLowerCase();
    final account = await AuthServices.instance.emailIdp.admin.findAccount(
      session,
      email: email,
    );
    if (account == null) throw NotStaffException(message: refusal);
    final membership = await StaffMembership.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(account.authUserId),
    );
    if (membership == null) throw NotStaffException(message: refusal);
    // The same row the identity provider writes when it links an account.
    await GoogleAccount.db.insertRow(
      session,
      GoogleAccount(
        userIdentifier: details.userIdentifier,
        email: email,
        authUserId: account.authUserId,
      ),
    );
  }

  /// Rolls back any user the identity provider would create on its own: the
  /// link step above runs first, so this only fires if it was bypassed.
  static Future<void> refuseNewUser(
    Session session,
    AuthUserModel authUser,
    GoogleAccount googleAccount, {
    required Transaction? transaction,
  }) async => throw NotStaffException(message: refusal);
}
