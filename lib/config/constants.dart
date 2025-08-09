/// Free plan limits

const int INTERSTITIAL_FREQUENCY = 5;
const int MAX_TRANSLATIONS = 100;
const int MAX_CARDS = 20;

/// Code → clé de traduction
const Map<String, String> LANGUAGE_KEYS = {
  'AR': 'lang_ar',
  'BG': 'lang_bg',
  'CS': 'lang_cs',
  'DA': 'lang_da',
  'DE': 'lang_de',
  'EL': 'lang_el',
  'EN': 'lang_en',
  'ES': 'lang_es',
  'ET': 'lang_et',
  'FI': 'lang_fi',
  'FR': 'lang_fr',
  'HE': 'lang_he',
  'HU': 'lang_hu',
  'ID': 'lang_id',
  'IT': 'lang_it',
  'JA': 'lang_ja',
  'KO': 'lang_ko',
  'LT': 'lang_lt',
  'LV': 'lang_lv',
  'NB': 'lang_nb',
  'NL': 'lang_nl',
  'PL': 'lang_pl',
  'PT': 'lang_pt',
  'RO': 'lang_ro',
  'RU': 'lang_ru',
  'SK': 'lang_sk',
  'SL': 'lang_sl',
  'SV': 'lang_sv',
  'TH': 'lang_th',
  'TR': 'lang_tr',
  'UK': 'lang_uk',
  'VI': 'lang_vi',
  'ZH': 'lang_zh',
};

const String INITIAL_SOURCE_LANGUAGE = 'EN';
const String INITIAL_TARGET_LANGUAGE = 'FR';
