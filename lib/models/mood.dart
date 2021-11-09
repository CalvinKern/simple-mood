import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';

part 'mood.g.dart';

@BuiltValueEnum(wireName: 'mood_rating')
class MoodRating extends EnumClass {
  const MoodRating._(String name) : super(name);

  /// For only user rated moods
  static BuiltSet<MoodRating> get ratings => values.difference(BuiltSet.of([MoodRating.missing]));

  // All possible states a mood could be rated (includes missing)
  static BuiltSet<MoodRating> get values => _$moodRatingValues;

  static MoodRating valueOf(String name) => _$moodRatingValueOf(name);

  static Serializer<MoodRating> get serializer => _$moodRatingSerializer;

  static const MoodRating miserable = _$moodTypeMiserable;

  static const MoodRating unhappy = _$moodTypeUnhappy;

  static const MoodRating plain = _$moodTypePlain;

  static const MoodRating happy = _$moodTypeHappy;

  static const MoodRating ecstatic = _$moodTypeEcstatic;

  static const MoodRating missing = _$moodTypeMissing;
}

/// To have built_value generate the part files, run this command:
/// flutter pub run build_runner build
abstract class Mood implements Built<Mood, MoodBuilder> {
  Mood._();

  factory Mood([void Function(MoodBuilder) updates]) = _$Mood;

  static Serializer<Mood> get serializer => _$moodSerializer;

  int get id;

  DateTime get date;

  MoodRating get rating;
}
