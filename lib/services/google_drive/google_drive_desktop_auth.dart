import 'package:googleapis_auth/auth_io.dart';
import 'package:take_notes/services/database/models/drive_credential.dart';
import 'package:take_notes/services/google_drive/google_drive_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleDriveDesktopAuth implements GoogleDriveAuth {
  final clientId = ClientId(
      '1089824253950-1vfmpakoqd61ikuqg21dbs572rplrrkv.apps.googleusercontent.com',
      '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');

  /// Use the oauth2 code grant server flow functionality to
  /// get an authenticated and auto refreshing client.
  Future<AuthClient> obtainCredentials() async => await clientViaUserConsent(
        clientId,
        [
          drive.DriveApi.driveAppdataScope,
        ],
        _prompt,
      );

  void _prompt(String url) {
    print('Please go to the following URL and grant access:');
    print('  => $url');
    print('');
    _launchUrl(Uri.parse(url));
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Future<DriveCredentials> authenticate() async {
    final response = await obtainCredentials();
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

  @override
  Future<AuthClient> getHttpclient(DriveCredentials credentials) async {
    return autoRefreshingClient(
      clientId,
      AccessCredentials(
        AccessToken(
          credentials.accessTokenType,
          credentials.accessTokenData,
          DateTime.parse(credentials.accessTokenExpiry),
        ),
        credentials.refreshToken,
        credentials.scopes,
        idToken: credentials.idToken,
      ),
      http.Client(),
    );
  }
}
