[
  {
    "location": "prd.md:56",
    "trigger_condition": "La saisie contient seulement des espaces ou dépasse la limite DeepL.",
    "guard_snippet": "if (input.trim().isEmpty || input.length > maxDeepLChars) return InvalidInput;",
    "potential_consequence": "Une requête invalide consomme le quota ou échoue sans comportement défini."
  },
  {
    "location": "prd.md:57-60",
    "trigger_condition": "Deux traductions gratuites démarrent simultanément au dernier quota disponible.",
    "guard_snippet": "await quotaStore.reserveTranslationAtomically(limit);",
    "potential_consequence": "Le quota de 200 peut être dépassé."
  },
  {
    "location": "prd.md:64",
    "trigger_condition": "Le lien de vérification est expiré, déjà utilisé ou ouvert sur un autre appareil.",
    "guard_snippet": "if (!verified) offerResendVerificationAndRefreshSession();",
    "potential_consequence": "L'utilisateur ne peut pas terminer l'inscription."
  },
  {
    "location": "prd.md:74",
    "trigger_condition": "L'achat est annulé, reste en attente ou ne restaure aucun entitlement.",
    "guard_snippet": "switch (purchaseResult) { case pending: showPending(); case cancelled: keepFree(); case noEntitlement: showRestoreError(); }",
    "potential_consequence": "Les droits affichés après un achat inabouti sont indéterminés."
  },
  {
    "location": "prd.md:75-76",
    "trigger_condition": "Le compte premium expire alors que plusieurs couples et plus de 20 cartes existent.",
    "guard_snippet": "onPremiumRevoked() => retainDataAndDefineAccessibleDefaultLanguagePair();",
    "potential_consequence": "L'accès aux cartes et au couple actif devient ambigu."
  },
  {
    "location": "prd.md:75",
    "trigger_condition": "L'utilisateur crée une paire lorsque le plafond de 20 est atteint.",
    "guard_snippet": "if (storedCardCount >= cardLimit) return StorageLimitReached;",
    "potential_consequence": "La création peut dépasser le plafond ou produire une paire partielle."
  },
  {
    "location": "prd.md:76",
    "trigger_condition": "La réponse saisie diffère seulement par casse, accents, ponctuation ou espaces.",
    "guard_snippet": "isCorrect = normalize(answer) == normalize(expectedTranslation);",
    "potential_consequence": "Des réponses équivalentes peuvent être comptées comme fausses."
  },
  {
    "location": "prd.md:78",
    "trigger_condition": "Le consentement est refusé, indisponible ou échoue à se charger.",
    "guard_snippet": "if (!consent.canRequestAds) disableAdsForSession();",
    "potential_consequence": "Une annonce peut être demandée sans base de consentement définie."
  }
]
