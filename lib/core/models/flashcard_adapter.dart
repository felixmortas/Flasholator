import 'package:hive/hive.dart';
import 'flashcard.dart'; // Ajustez le chemin si nécessaire

class FlashcardAdapter extends TypeAdapter<Flashcard> {
  @override
  final typeId = 0; // Assignez un ID unique (0-223)

  @override
  Flashcard read(BinaryReader reader) {
    // Lire les champs dans l'ordre où ils sont écrits
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()
    };

    // Utiliser fromMap pour la construction
    // Assurez-vous que les clés correspondent à celles de toMap()
    // Cela nécessite une légère modification de fromMap pour gérer les nulls potentiels correctement
    // ou utilisez directement le constructeur avec les champs lus.
    // Méthode directe (plus performante, mais plus verbeuse) :
    return Flashcard(
      // Utiliser les index des champs pour l'ordre de lecture
      front: fields[1] as String,
      back: fields[2] as String,
      sourceLang: fields[3] as String,
      targetLang: fields[4] as String,
      id: fields[0] as int?, // ID peut être null
      quality: fields[5] as int?,
      easiness: fields[6] as num, // Hive gère num
      interval: fields[7] as int,
      repetitions: fields[8] as int,
      timesReviewed: fields[9] as int,
      lastReviewDate: fields[10] as String?,
      nextReviewDate: fields[11] as String?,
      addedDate: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Flashcard obj) {
     // Écrire les champs dans un ordre fixe
    // Utiliser des indices numériques pour identifier les champs
    writer
      ..writeByte(13) // Nombre total de champs
      ..writeByte(0) // Index pour id
      ..write(obj.id)
      ..writeByte(1) // Index pour front
      ..write(obj.front)
      ..writeByte(2) // Index pour back
      ..write(obj.back)
      ..writeByte(3) // Index pour sourceLang
      ..write(obj.sourceLang)
      ..writeByte(4) // Index pour targetLang
      ..write(obj.targetLang)
      ..writeByte(5) // Index pour quality
      ..write(obj.quality)
      ..writeByte(6) // Index pour easiness
      ..write(obj.easiness)
      ..writeByte(7) // Index pour interval
      ..write(obj.interval)
      ..writeByte(8) // Index pour repetitions
      ..write(obj.repetitions)
      ..writeByte(9) // Index pour timesReviewed
      ..write(obj.timesReviewed)
      ..writeByte(10) // Index pour lastReviewDate
      ..write(obj.lastReviewDate)
      ..writeByte(11) // Index pour nextReviewDate
      ..write(obj.nextReviewDate)
      ..writeByte(12) // Index pour addedDate
      ..write(obj.addedDate);
  }
}