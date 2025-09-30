// Configure your backend base URL here.
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://bank-app-backend-sake.onrender.com/api', // 👈 Render backend
    // defaultValue: 'http://192.168.0.105:4000/api', // 👈 Render backend
  );
}
