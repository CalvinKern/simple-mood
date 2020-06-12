import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';

part 'mood.g.dart';

/// To have built_value generate the part files, run this command:
/// flutter pub run build_runner build
abstract class Mood implements Built<Mood, MoodBuilder> {
  Mood._();
  factory Mood([void Function(MoodBuilder) updates]) = _$Mood;

  static Serializer<Mood> get serializer => _$moodSerializer;

  int get id;

  DateTime get date;

  MoodType get type;
}

@BuiltValueEnum(wireName: 'mood_type')
class MoodType extends EnumClass {
  const MoodType._(String name) : super(name);

  static BuiltSet<MoodType> get values => _$moodTypeValues;

  static MoodType valueOf(String name) => _$moodTypeValueOf(name);

  static Serializer<MoodType> get serializer => _$moodTypeSerializer;

  @BuiltValueEnumConst()
  static const MoodType miserable = _$moodTypeMiserable;

  @BuiltValueEnumConst()
  static const MoodType unhappy = _$moodTypeUnhappy;

  @BuiltValueEnumConst()
  static const MoodType plain = _$moodTypePlain;

  @BuiltValueEnumConst()
  static const MoodType happy = _$moodTypeHappy;

  @BuiltValueEnumConst()
  static const MoodType ecstatic = _$moodTypeEcstatic;
}