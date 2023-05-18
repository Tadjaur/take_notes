import 'package:hive/hive.dart';

class DriveCredentials extends HiveObject {
  final String accessTokenType;
  final String accessTokenData;
  final String accessTokenExpiry;
  final String? idToken;
  final String? refreshToken;
  final List<String> scopes;

  DriveCredentials(
      {required this.accessTokenType,
      required this.accessTokenData,
      required this.accessTokenExpiry,
      this.idToken,
      this.refreshToken,
      required this.scopes});

  DriveCredentials._internal(this.accessTokenType, this.accessTokenData,
      this.accessTokenExpiry, String idToken, String refreshToken, this.scopes)
      : refreshToken = refreshToken.isEmpty ? null : refreshToken,
        idToken = idToken.isEmpty ? null : idToken;
}

class DriveCredentialsAdapter extends TypeAdapter<DriveCredentials> {
  @override
  DriveCredentials read(BinaryReader reader) {
    return DriveCredentials._internal(
        reader.readString(),
        reader.readString(),
        reader.readString(),
        reader.readString(),
        reader.readString(),
        reader.readStringList());
  }

  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, DriveCredentials obj) {
    writer
      ..writeString(obj.accessTokenType)
      ..writeString(obj.accessTokenData)
      ..writeString(obj.accessTokenExpiry)
      ..writeString(obj.idToken ?? '')
      ..writeString(obj.refreshToken ?? '')
      ..writeStringList(obj.scopes);
  }
}
