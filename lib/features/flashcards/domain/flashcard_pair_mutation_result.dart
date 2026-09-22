/// Issue métier d'une mutation de paire, distincte des erreurs techniques.
enum FlashcardPairMutationResult {
  applied,
  notFound,
  conflict,
}
