/// Idioma de la interfaz. Español por defecto; inglés para la exposición.
enum AppLanguage { es, en }

extension AppLanguageX on AppLanguage {
  String get label => this == AppLanguage.es ? 'Español' : 'English';
  String get code => this == AppLanguage.es ? 'es' : 'en';
  bool get isEn => this == AppLanguage.en;
}
