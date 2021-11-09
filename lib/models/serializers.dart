import 'package:built_collection/built_collection.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'mood.dart';

part 'serializers.g.dart';

/// To have built_value generate the part files, run this command:
/// flutter pub run build_runner build
/// Alternatively add `watch` to the end of the command to have it continually watch for changes.
@SerializersFor([
  Mood,
])
final Serializers _serializers = _$_serializers;

Serializers jsonSerializers = (_serializers.toBuilder()
      ..addPlugin(StandardJsonPlugin())
      ..add(Iso8601DateTimeSerializer())
      ..addBuilderFactory(FullType(BuiltList, [FullType(String)]), () => ListBuilder<String>()))
    .build();

T? deserialize<T>(dynamic value) => jsonSerializers.deserializeWith<T>(jsonSerializers.serializerForType(T) as Serializer<T>, value);

dynamic serialize<T>(T value) => jsonSerializers.serializeWith(jsonSerializers.serializerForType(T) as Serializer<T>, value);

List<T> deserializeList<T>(dynamic value) => List.from(value?.map((value) => deserialize<T>(value))?.toList() ?? []);
