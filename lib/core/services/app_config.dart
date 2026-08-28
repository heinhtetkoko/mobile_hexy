enum AppEnvironment { development, staging, production }

abstract final class AppConfig {
  static AppEnvironment environment = AppEnvironment.development;

  static void initialize({required AppEnvironment environment}) {
    AppConfig.environment = environment;
  }

  static bool get isProduction => environment == AppEnvironment.production;
}
