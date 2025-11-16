import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @passwordFormatError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password format.'**
  String get passwordFormatError;

  /// No description provided for @congratulationsOnYourWork.
  ///
  /// In en, this message translates to:
  /// **'Great job on your work!'**
  String get congratulationsOnYourWork;

  /// No description provided for @noCardsToReview.
  ///
  /// In en, this message translates to:
  /// **'You have no more cards to review at the moment.'**
  String get noCardsToReview;

  /// No description provided for @keepProgressing.
  ///
  /// In en, this message translates to:
  /// **'Keep progressing: translate and add new words!'**
  String get keepProgressing;

  /// No description provided for @coolAIFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Cool AI feature coming soon...'**
  String get coolAIFeatureComingSoon;

  /// No description provided for @chooseYourLanguagePair.
  ///
  /// In en, this message translates to:
  /// **'Choose your language pair'**
  String get chooseYourLanguagePair;

  /// No description provided for @sourceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Source language'**
  String get sourceLanguage;

  /// No description provided for @targetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Target language'**
  String get targetLanguage;

  /// No description provided for @subscriptionWarningForLanguageChange.
  ///
  /// In en, this message translates to:
  /// **'⚠️ You will need to subscribe to change this choice later.'**
  String get subscriptionWarningForLanguageChange;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @freeSubscriptionLimitsExceeded.
  ///
  /// In en, this message translates to:
  /// **'Free subscription limits exceeded'**
  String get freeSubscriptionLimitsExceeded;

  /// No description provided for @reactivateSubscription.
  ///
  /// In en, this message translates to:
  /// **'Reactivate subscription'**
  String get reactivateSubscription;

  /// No description provided for @unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get unsubscribe;

  /// No description provided for @reconsiderMessage.
  ///
  /// In en, this message translates to:
  /// **'Think again, we would be delighted to continue this journey with you!'**
  String get reconsiderMessage;

  /// No description provided for @premiumBenefits.
  ///
  /// In en, this message translates to:
  /// **'With Flasholator Premium, you benefit from a unique learning experience:'**
  String get premiumBenefits;

  /// No description provided for @benefit1.
  ///
  /// In en, this message translates to:
  /// **'No advertisements'**
  String get benefit1;

  /// No description provided for @benefit2.
  ///
  /// In en, this message translates to:
  /// **'No translation limits'**
  String get benefit2;

  /// No description provided for @benefit3.
  ///
  /// In en, this message translates to:
  /// **'No limit on cards in your game'**
  String get benefit3;

  /// No description provided for @benefit4.
  ///
  /// In en, this message translates to:
  /// **'No limit on language pairs'**
  String get benefit4;

  /// No description provided for @benefit5.
  ///
  /// In en, this message translates to:
  /// **'Written reviews'**
  String get benefit5;

  /// No description provided for @benefit6.
  ///
  /// In en, this message translates to:
  /// **'Group words by category'**
  String get benefit6;

  /// No description provided for @benefit7.
  ///
  /// In en, this message translates to:
  /// **'Regular data synchronization on your Google Drive'**
  String get benefit7;

  /// No description provided for @unsubscribeAction.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get unsubscribeAction;

  /// No description provided for @sorryToSeeYouGo.
  ///
  /// In en, this message translates to:
  /// **'We are really sorry to see you go! Before you leave, could you tell us what is driving you to leave? Your feedback is valuable for us to improve.'**
  String get sorryToSeeYouGo;

  /// No description provided for @selectReason.
  ///
  /// In en, this message translates to:
  /// **'Select a reason'**
  String get selectReason;

  /// No description provided for @reason1.
  ///
  /// In en, this message translates to:
  /// **'Too expensive'**
  String get reason1;

  /// No description provided for @reason2.
  ///
  /// In en, this message translates to:
  /// **'I don\'t use it enough'**
  String get reason2;

  /// No description provided for @reason3.
  ///
  /// In en, this message translates to:
  /// **'Technical problems'**
  String get reason3;

  /// No description provided for @reason4.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reason4;

  /// No description provided for @additionalFeedback.
  ///
  /// In en, this message translates to:
  /// **'Additional feedback'**
  String get additionalFeedback;

  /// No description provided for @feedbackPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your feedback here...'**
  String get feedbackPlaceholder;

  /// No description provided for @allFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'All fields are required.'**
  String get allFieldsRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get accountCreated;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least 6 characters, 1 uppercase letter, 1 lowercase letter, and 1 special character.'**
  String get passwordRequirements;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @modifyPrivacyPreferences.
  ///
  /// In en, this message translates to:
  /// **'Modify privacy preferences'**
  String get modifyPrivacyPreferences;

  /// No description provided for @subscriptionActivated.
  ///
  /// In en, this message translates to:
  /// **'Subscription activated.'**
  String get subscriptionActivated;

  /// No description provided for @confirmCancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Do you want to cancel your subscription? You will keep access until the end of the period.'**
  String get confirmCancelSubscription;

  /// No description provided for @subscriptionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Subscription cancelled. Valid until'**
  String get subscriptionCancelled;

  /// No description provided for @subscriptionReactivated.
  ///
  /// In en, this message translates to:
  /// **'Subscription reactivated.'**
  String get subscriptionReactivated;

  /// No description provided for @userNotConnected.
  ///
  /// In en, this message translates to:
  /// **'User not connected'**
  String get userNotConnected;

  /// No description provided for @invalidDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid date'**
  String get invalidDate;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to log out?'**
  String get confirmLogout;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get passwordUpdated;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm deletion.'**
  String get confirmDeleteAccount;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get incorrectPassword;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @autoRenewal.
  ///
  /// In en, this message translates to:
  /// **'Auto renewal'**
  String get autoRenewal;

  /// No description provided for @cancelledUntil.
  ///
  /// In en, this message translates to:
  /// **'Cancelled (Premium until'**
  String get cancelledUntil;

  /// No description provided for @subscriptionExpired.
  ///
  /// In en, this message translates to:
  /// **'Subscription expired'**
  String get subscriptionExpired;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @undefined.
  ///
  /// In en, this message translates to:
  /// **'Undefined'**
  String get undefined;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @renewal.
  ///
  /// In en, this message translates to:
  /// **'Renewal'**
  String get renewal;

  /// No description provided for @activateSubscription.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get activateSubscription;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

  /// No description provided for @forgotYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotYourPassword;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get logOut;

  /// No description provided for @iHaveConfirmedMyEmail.
  ///
  /// In en, this message translates to:
  /// **'I have confirmed my email address.'**
  String get iHaveConfirmedMyEmail;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend the email'**
  String get resendEmail;

  /// No description provided for @aVerificationEmailHasBeenSentTo.
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent to:'**
  String get aVerificationEmailHasBeenSentTo;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email verification'**
  String get emailVerification;

  /// No description provided for @yourEmail.
  ///
  /// In en, this message translates to:
  /// **'Your email'**
  String get yourEmail;

  /// No description provided for @yourAddressHasNotYetBeenVerified.
  ///
  /// In en, this message translates to:
  /// **'Your address has not yet been verified.'**
  String get yourAddressHasNotYetBeenVerified;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent!'**
  String get verificationEmailSent;

  /// No description provided for @addAWord.
  ///
  /// In en, this message translates to:
  /// **'Add a word'**
  String get addAWord;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @word.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get word;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @editTheRow.
  ///
  /// In en, this message translates to:
  /// **'Edit the row'**
  String get editTheRow;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @displayAnswer.
  ///
  /// In en, this message translates to:
  /// **'Display answer'**
  String get displayAnswer;

  /// No description provided for @again.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get again;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @mostReviewed.
  ///
  /// In en, this message translates to:
  /// **'Most reviewed'**
  String get mostReviewed;

  /// No description provided for @consecutiveSuccesses.
  ///
  /// In en, this message translates to:
  /// **'Consecutive successes'**
  String get consecutiveSuccesses;

  /// No description provided for @easiestWords.
  ///
  /// In en, this message translates to:
  /// **'Easiest words'**
  String get easiestWords;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @addedWords.
  ///
  /// In en, this message translates to:
  /// **'Added words'**
  String get addedWords;

  /// No description provided for @languagePairs.
  ///
  /// In en, this message translates to:
  /// **'Language pairs'**
  String get languagePairs;

  /// No description provided for @averagePerDay.
  ///
  /// In en, this message translates to:
  /// **'Average/day'**
  String get averagePerDay;

  /// No description provided for @averagePerWeek.
  ///
  /// In en, this message translates to:
  /// **'Average/week'**
  String get averagePerWeek;

  /// No description provided for @averagePerMonth.
  ///
  /// In en, this message translates to:
  /// **'Average/month'**
  String get averagePerMonth;

  /// No description provided for @averagePerYear.
  ///
  /// In en, this message translates to:
  /// **'Average/year'**
  String get averagePerYear;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// No description provided for @cardAdded.
  ///
  /// In en, this message translates to:
  /// **'Card added'**
  String get cardAdded;

  /// No description provided for @cardAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'Card already added'**
  String get cardAlreadyAdded;

  /// No description provided for @writeOrPasteYourTextHereForTranslation.
  ///
  /// In en, this message translates to:
  /// **'Write or paste your text here for translation...'**
  String get writeOrPasteYourTextHereForTranslation;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @giveAFeedback.
  ///
  /// In en, this message translates to:
  /// **'Give a feedback'**
  String get giveAFeedback;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @writeYourResponseHere.
  ///
  /// In en, this message translates to:
  /// **'Write your response here...'**
  String get writeYourResponseHere;

  /// No description provided for @lang_ar.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get lang_ar;

  /// No description provided for @lang_bg.
  ///
  /// In en, this message translates to:
  /// **'Bulgarian'**
  String get lang_bg;

  /// No description provided for @lang_cs.
  ///
  /// In en, this message translates to:
  /// **'Czech'**
  String get lang_cs;

  /// No description provided for @lang_da.
  ///
  /// In en, this message translates to:
  /// **'Danish'**
  String get lang_da;

  /// No description provided for @lang_de.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get lang_de;

  /// No description provided for @lang_el.
  ///
  /// In en, this message translates to:
  /// **'Greek'**
  String get lang_el;

  /// No description provided for @lang_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get lang_en;

  /// No description provided for @lang_es.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get lang_es;

  /// No description provided for @lang_et.
  ///
  /// In en, this message translates to:
  /// **'Estonian'**
  String get lang_et;

  /// No description provided for @lang_fi.
  ///
  /// In en, this message translates to:
  /// **'Finnish'**
  String get lang_fi;

  /// No description provided for @lang_fr.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get lang_fr;

  /// No description provided for @lang_he.
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get lang_he;

  /// No description provided for @lang_hu.
  ///
  /// In en, this message translates to:
  /// **'Hungarian'**
  String get lang_hu;

  /// No description provided for @lang_id.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get lang_id;

  /// No description provided for @lang_it.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get lang_it;

  /// No description provided for @lang_ja.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get lang_ja;

  /// No description provided for @lang_ko.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get lang_ko;

  /// No description provided for @lang_lt.
  ///
  /// In en, this message translates to:
  /// **'Lithuanian'**
  String get lang_lt;

  /// No description provided for @lang_lv.
  ///
  /// In en, this message translates to:
  /// **'Latvian'**
  String get lang_lv;

  /// No description provided for @lang_nb.
  ///
  /// In en, this message translates to:
  /// **'Norwegian Bokmål'**
  String get lang_nb;

  /// No description provided for @lang_nl.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get lang_nl;

  /// No description provided for @lang_pl.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get lang_pl;

  /// No description provided for @lang_pt.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get lang_pt;

  /// No description provided for @lang_ro.
  ///
  /// In en, this message translates to:
  /// **'Romanian'**
  String get lang_ro;

  /// No description provided for @lang_ru.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get lang_ru;

  /// No description provided for @lang_sk.
  ///
  /// In en, this message translates to:
  /// **'Slovak'**
  String get lang_sk;

  /// No description provided for @lang_sl.
  ///
  /// In en, this message translates to:
  /// **'Slovenian'**
  String get lang_sl;

  /// No description provided for @lang_sv.
  ///
  /// In en, this message translates to:
  /// **'Swedish'**
  String get lang_sv;

  /// No description provided for @lang_th.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get lang_th;

  /// No description provided for @lang_tr.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get lang_tr;

  /// No description provided for @lang_uk.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get lang_uk;

  /// No description provided for @lang_vi.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get lang_vi;

  /// No description provided for @lang_zh.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get lang_zh;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
