import 'package:crypto/src/digest.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:take_notes/services/database/models/drive_credential.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class GoogleDriveService extends GetxService {
  final _clientId = ClientId(
      '402904080028-sd6bt3l5dief26o01mjvn27tii05jc5u.apps.googleusercontent.com',
      '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');

  /// Use the oauth2 code grant server flow functionality to
  /// get an authenticated and auto refreshing client.
  Future<AuthClient> _obtainCredentials() async => await clientViaUserConsent(
        _clientId,
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

  drive.DriveApi getDriveApi(DriveCredentials credentials) {
    return drive.DriveApi(autoRefreshingClient(
      _clientId,
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
    ));
  }

  Future<DriveFileState> searchFile(
      {required String id,
      required DateTime localUpdatedTime,
      required DriveCredentials credentials}) async {
    final api = getDriveApi(credentials);
    try {
      final response = await api.files
          .get(id, downloadOptions: drive.DownloadOptions.metadata);
      if (response is drive.File) {
        print('Found a file => ${response.toJson()}');
        final msUpdateDate = response.appProperties?['dbUpdatedAt'];
        if (msUpdateDate == null) {
          return DriveFileState.existWithOutdatedData;
        }
        final remoteUpdateTimestamp =
            DateTime.parse(msUpdateDate).millisecondsSinceEpoch;
        final localUpdateTimestamp = localUpdatedTime.millisecondsSinceEpoch;
        if (remoteUpdateTimestamp > localUpdateTimestamp) {
          return DriveFileState.existWithFutureData;
        }
        if (remoteUpdateTimestamp == localUpdateTimestamp) {
          return DriveFileState.existWithUpdatedData;
        }
        return DriveFileState.existWithOutdatedData;
      }
    } on drive.DetailedApiRequestError catch (error) {
      print('KNOWED ERROR => ${error}');

      if (error.status == 404) {
        return DriveFileState.missingFile;
      }
    }
    return DriveFileState.unknown;
  }

  Future<String?> createFile(
      {required DriveCredentials credentials,
      required List<int> raw,
      required DateTime updatedAt}) async {
    final api = getDriveApi(credentials);
    final media = drive.Media(Future.value(raw).asStream(), raw.length);
    final file = drive.File(
      appProperties: {'dbUpdatedAt': updatedAt.toUtc().toIso8601String()},
      parents: ['appDataFolder'],
    );

    try {
      // if (update) {
      // return (await api.files.update(file, id, uploadMedia: media)).id;
      // } else {
      return (await api.files.create(file, uploadMedia: media)).id;
      // }
    } on drive.DetailedApiRequestError catch (error) {
      print('ERROR => ${error}');
      rethrow;
    }
  }

  Future<String?> updateFile(
      {required DriveCredentials credentials,
      required List<int> raw,
      required String id,
      required DateTime updatedAt}) async {
    final api = getDriveApi(credentials);
    final media = drive.Media(Future.value(raw).asStream(), raw.length);
    final file = drive.File(
      appProperties: {'dbUpdatedAt': updatedAt.toUtc().toIso8601String()},
    );

    try {
      return (await api.files.update(file, id, uploadMedia: media)).id;
    } on drive.DetailedApiRequestError catch (error) {
      print('ERROR => ${error}');
      rethrow;
    }
  }

  Future<void> deleteFile(
      {required DriveCredentials credentials, required String id}) async {
    final api = getDriveApi(credentials);
    try {
      return await api.files.delete(id);
    } on drive.DetailedApiRequestError catch (error) {
      /// Todo: - Retry on delete error
      /// - store file id inside the local database and try again later.
      print('ERROR => ${error}');
      rethrow;
    }
  }

  Future<String> getMedia(
      {required DriveCredentials credentials, required String id}) async {
    return ((await getDriveApi(credentials).files.get(id,
            downloadOptions: drive.DownloadOptions.fullMedia)) as drive.Media)
        .stream
        .join();
  }

  Future<void> retrieveNewFile(
      {required credentials,
      required Iterable<String> localFileIds,
      required Future<void> Function(
              String noteId, Stream<List<int>> noteStream)
          transform}) async {
    final api = getDriveApi(credentials);
    final fileList = await api.files.list(
      spaces: 'appDataFolder',
      pageSize: 100,
    );
    final files = fileList.files;
    if (files == null) {
      print('DRIVE_SYNC: WARN NO FILE FOUND IN REMOTE DRIVE');
      return;
    }
    final newFiles =
        files.where((element) => !localFileIds.contains(element.id));
    print('DRIVE_SYNC: New file found');
    for (var newFile in newFiles) {
      final newFileId = newFile.id;
      if (newFileId == null) {
        print('DRIVE_SYNC: retrieveNewFile::Err file id must not be null');
        continue;
      }
      transform(
          newFileId,
          ((await api.files.get(newFileId,
                      downloadOptions: drive.DownloadOptions.fullMedia))
                  as drive.Media)
              .stream);
    }
  }
}

enum DriveFileState {
  missingFile,
  existWithUpdatedData,
  existWithFutureData,
  unknown,
  existWithOutdatedData,
}
