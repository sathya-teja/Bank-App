// Configure your backend base URL here.
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.0.105:4000/api', // 👈 use your laptop IP
  );
}
