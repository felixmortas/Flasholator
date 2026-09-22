# Epic 3 Context: Traduire et organiser son vocabulaire

<!-- Compiled from planning artifacts. Edit freely. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Permettre à l'utilisateur de traduire un mot ou une courte phrase avec DeepL, puis d'enregistrer et corriger la paire de cartes correspondante, tout en conservant les retours visibles existants, l'intégrité des cartes et les protections de l'offre gratuite. Cette tranche migratoire doit rendre les parcours traduction et tables testables et fiables sans introduire de nouvelle fonctionnalité ni de changement UX.

## Stories

- Story 3.1: Traduire une saisie valide sans résultat tardif
- Story 3.2: Enregistrer et corriger une traduction dans les tables
- Story 3.3: Appliquer des limites gratuites configurables

## Requirements & Constraints

- Accepter la saisie ou le collage d'un mot ou d'une courte phrase et n'appeler DeepL que lorsque cette saisie et le couple de langues actif sont valides.
- Présenter les phases de chargement, résultat et erreur de traduction conformément au comportement existant. Une erreur, une réponse tardive ou un chargement ne doit ni effacer une intention plus récente ni modifier une carte de manière inattendue.
- Permettre d'enregistrer le résultat comme une paire réversible de flashcards, puis de retrouver les paires par couple de langues et de corriger une traduction enregistrée.
- Toute écriture de paire doit préserver les deux faces, être atomique et distinguer un succès, une paire absente et un conflit. Après un commit, les tables doivent se rafraîchir depuis la collection cohérente partagée.
- Conserver la limite gratuite de traductions et le parcours premium existants. La valeur par défaut est 200 traductions pour un utilisateur gratuit ; le premium ne doit pas être limité. La limite doit rester configurable ou désactivable par développeur, sans réglage utilisateur.
- Les tests de caractérisation précèdent la migration et couvrent au minimum les erreurs DeepL, les réponses dans un ordre inversé et les changements de session. Les intégrations existantes, la compatibilité iOS/Android et les localisations française, anglaise et espagnole restent préservées.
- Ne pas introduire de synchronisation cloud des cartes, de nouvelle capacité métier, de refonte UX ou de mise à niveau implicite de la stack.

## Technical Decisions

- Implémenter la fonctionnalité dans `features/translation/` et les tables dans `features/data/`, selon le flux vue → ViewModel → cas d'usage facultatif → repository → adaptateur. Les vues ne font que rendre l'état et transmettre les intentions.
- Les ViewModels exposent des états UI immuables et des erreurs applicatives typées. Une traduction est une requête remplaçable : associer l'exécution à un contexte ou `requestId` et n'appliquer son résultat que s'il correspond encore à la dernière saisie, au couple de langues, à la session et à un ViewModel actif. Les dépendances sont des providers Riverpod surchargeables en test.
- `TranslationRepository` masque l'API DeepL ; ses contrats et les modèles consommés par les features restent en Dart pur. Le SDK, le réseau et les DTO restent dans l'adaptateur. Ne pas propager ni déplacer de secret dans une vue, un ViewModel ou le domaine.
- La collection est possédée exclusivement par `FlashcardRepository`. Les actions d'enregistrement et de correction utilisent ses opérations de paire : Drift exécute recherche, précondition et mutation dans une même transaction avec clé canonique tant qu'il n'existe pas de `PairId`, et publie un snapshot versionné ou un flux invalidé après commit.
- La limite freemium est fournie par une configuration développeur centralisée, injectée et surchargeable en test. Les droits et le contexte de session proviennent de leur propriétaire dédié ; les opérations asynchrones capturent `uid` et génération et ignorent tout résultat périmé.
- Les fichiers générés de localisation et de Drift ne sont jamais modifiés directement : modifier leur source puis régénérer. Conserver les versions Flutter et dépendances verrouillées.

## UX & Interaction Patterns

- Le parcours existant reste : saisir ou coller le texte, lancer la traduction quand elle est valide, consulter la proposition, puis décider de l'enregistrer. Une paire enregistrée peut ensuite être sélectionnée dans les tables et corrigée.
- Les phases chargement, erreur et résultat doivent rester lisibles sans masquer une action plus récente. Conserver les messages et retours observables existants plutôt que de les redéfinir pendant la migration.

## Cross-Story Dependencies

- Les Stories 3.2 et 3.3 dépendent de la Story 3.1 pour le contexte de traduction courant, mais l'enregistrement doit rester une commande de paire séparée et atomique.
- Les Stories 3.1 et 3.2 reposent sur le `FlashcardRepository` et la collection cohérente introduits par l'Epic 2 ; les tables, review et statistiques doivent lire cette même source après mutation.
- La validité d'une réponse de traduction et l'application d'un quota doivent être compatibles avec les transitions de session de l'Epic 4 et les droits premium de l'Epic 5 : aucun résultat ou effet d'une ancienne session ne peut atteindre la session courante.
