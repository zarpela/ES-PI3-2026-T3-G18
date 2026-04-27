// feito por marcelo
class AppSettings {
  static const String _defaultBaseUrl =
      "https://southamerica-east1-projetointegrador3-grupo18.cloudfunctions.net/api/";
  static const String baseUrl = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: _defaultBaseUrl,
  );
  static const String appName = "MesclaInvest";
  static const int timeout = 10000; // ms
}
