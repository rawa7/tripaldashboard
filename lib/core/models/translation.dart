/// Translation field class to manage content in multiple languages
class TranslationField {
  final String en;
  final String ar;
  final String ku;
  final String bad;

  const TranslationField({
    required this.en,
    this.ar = '',
    this.ku = '',
    this.bad = '',
  });

  factory TranslationField.empty() {
    return const TranslationField(
      en: '',
      ar: '',
      ku: '',
      bad: '',
    );
  }

  factory TranslationField.fromJson(Map<String, dynamic> json) {
    return TranslationField(
      en: json['en'] ?? '',
      ar: json['ar'] ?? '',
      ku: json['ku'] ?? '',
      bad: json['bad'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'ar': ar,
      'ku': ku,
      'bad': bad,
    };
  }

  /// Get translation for a specific language code
  String getByLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return ar;
      case 'ku':
        return ku;
      case 'bad':
        return bad;
      default:
        return en;
    }
  }

  /// Check if any of the translations are not empty
  bool get hasAnyTranslation => 
      en.isNotEmpty || ar.isNotEmpty || ku.isNotEmpty || bad.isNotEmpty;

  /// Check if all translations are available
  bool get hasAllTranslations =>
      en.isNotEmpty && ar.isNotEmpty && ku.isNotEmpty && bad.isNotEmpty;

  /// Create a copy with updated values
  TranslationField copyWith({
    String? en,
    String? ar,
    String? ku,
    String? bad,
  }) {
    return TranslationField(
      en: en ?? this.en,
      ar: ar ?? this.ar,
      ku: ku ?? this.ku,
      bad: bad ?? this.bad,
    );
  }

  @override
  String toString() {
    return 'TranslationField(en: $en, ar: $ar, ku: $ku, bad: $bad)';
  }
} 