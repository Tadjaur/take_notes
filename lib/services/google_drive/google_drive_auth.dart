import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import '../database/models/drive_credential.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleDriveAuth {
  GoogleSignIn? _googleSignInVar;
  final _scopes = [
    drive.DriveApi.driveAppdataScope,
  ];
  GoogleDriveAuth() {
    _googleSignIn.onCurrentUserChanged.listen((account) async {
      bool isAuthorized = account != null;
      print('__________________________');
      print('Account Changed! $isAuthorized');
      print('__________________________');
      if (kIsWeb && account != null) {
        isAuthorized = await _googleSignIn.canAccessScopes(_scopes);
      }
    });
  }
  GoogleSignIn get _googleSignIn =>
      _googleSignInVar ??= GoogleSignIn.standard(scopes: _scopes);
  Future<bool> get _isSign => _googleSignIn.isSignedIn();

  Future<void> _sign() async {
    try {
      final response = await _googleSignIn.signInSilently();
      if (response == null) {
        final freshSign = await _googleSignIn.signIn();
        print('\n\nUSER ACCOUNT: $freshSign');
      }
    } on Exception catch (e) {
      print(
          'GOOGLE_DRIVE_ATUH:REFRESH ERROR:: ${e}\n StackTrace:${StackTrace.current}');
      rethrow;
    }
  }

  Future<AuthClient> getHttpclient(DriveCredentials credentials) {
    return _obtainCredentials();
  }

  /// Use the oauth2 code grant server flow functionality to
  /// get an authenticated and auto refreshing client.
  Future<AuthClient> _obtainCredentials() async {
    if (!(await _isSign)) {
      await _sign();
    }
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) {
      throw Exception('Authenticated client missing!');
    }

    return client;
  }

  Future<DriveCredentials> authenticate() async {
    final response = await _obtainCredentials();
    return DriveCredentials(
      accessTokenType: response.credentials.accessToken.type,
      accessTokenData: response.credentials.accessToken.data,
      accessTokenExpiry:
          response.credentials.accessToken.expiry.toUtc().toIso8601String(),
      refreshToken: response.credentials.refreshToken,
      scopes: response.credentials.scopes,
      idToken: response.credentials.idToken,
    );
  }
}
