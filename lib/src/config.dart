import 'dart:io';

class DbConfig {
  DbConfig({
    required this.host,
    required this.port,
    required this.database,
    required this.user,
    required this.password,
    required this.sslMode,
  });

  final String host;
  final int port;
  final String database;
  final String user;
  final String password;
  final String sslMode;

  factory DbConfig.fromEnv() {
    String requireEnv(String key) {
      final value = Platform.environment[key];
      if (value == null || value.trim().isEmpty) {
        throw StateError('Missing required environment variable: $key');
      }
      return value;
    }

    return DbConfig(
      host: requireEnv('GS_SPONSOR_PULSE_DB_HOST'),
      port: int.tryParse(Platform.environment['GS_SPONSOR_PULSE_DB_PORT'] ?? '') ??
          5432,
      database: Platform.environment['GS_SPONSOR_PULSE_DB_NAME'] ?? 'postgres',
      user: requireEnv('GS_SPONSOR_PULSE_DB_USER'),
      password: requireEnv('GS_SPONSOR_PULSE_DB_PASSWORD'),
      sslMode: Platform.environment['GS_SPONSOR_PULSE_DB_SSLMODE'] ?? 'disable',
    );
  }

  String toConnectionString() {
    final encodedUser = Uri.encodeComponent(user);
    final encodedPassword = Uri.encodeComponent(password);
    final encodedHost = Uri.encodeComponent(host);
    final encodedDb = Uri.encodeComponent(database);
    final encodedSsl = Uri.encodeComponent(sslMode);
    return 'postgresql://$encodedUser:$encodedPassword@$encodedHost:$port/$encodedDb?sslmode=$encodedSsl';
  }
}
