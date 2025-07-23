import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../config/constants.dart';

extension LocalizedLanguageName on AppLocalizations {
  String getTranslatedLanguageName(String code) {
    final key = LANGUAGE_KEYS[code.toUpperCase()];
    if (key == null) return code;

    switch (key) {
      case 'lang_ar':
        return lang_ar;
      case 'lang_bg':
        return lang_bg;
      case 'lang_cs':
        return lang_cs;
      case 'lang_da':
        return lang_da;
      case 'lang_de':
        return lang_de;
      case 'lang_el':
        return lang_el;
      case 'lang_en':
        return lang_en;
      case 'lang_es':
        return lang_es;
      case 'lang_et':
        return lang_et;
      case 'lang_fi':
        return lang_fi;
      case 'lang_fr':
        return lang_fr;
      case 'lang_he':
        return lang_he;
      case 'lang_hu':
        return lang_hu;
      case 'lang_id':
        return lang_id;
      case 'lang_it':
        return lang_it;
      case 'lang_ja':
        return lang_ja;
      case 'lang_ko':
        return lang_ko;
      case 'lang_lt':
        return lang_lt;
      case 'lang_lv':
        return lang_lv;
      case 'lang_nb':
        return lang_nb;
      case 'lang_nl':
        return lang_nl;
      case 'lang_pl':
        return lang_pl;
      case 'lang_pt':
        return lang_pt;
      case 'lang_ro':
        return lang_ro;
      case 'lang_ru':
        return lang_ru;
      case 'lang_sk':
        return lang_sk;
      case 'lang_sl':
        return lang_sl;
      case 'lang_sv':
        return lang_sv;
      case 'lang_th':
        return lang_th;
      case 'lang_tr':
        return lang_tr;
      case 'lang_uk':
        return lang_uk;
      case 'lang_vi':
        return lang_vi;
      case 'lang_zh':
        return lang_zh;
      default:
        return code;
    }
  }
}
