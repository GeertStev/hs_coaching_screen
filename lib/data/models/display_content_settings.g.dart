// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_content_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DisplayContentSettings _$DisplayContentSettingsFromJson(
  Map<String, dynamic> json,
) => _DisplayContentSettings(
  contentType:
      $enumDecodeNullable(
        _$DisplayContentTypeEnumMap,
        json['contentType'],
        unknownValue: DisplayContentType.main,
      ) ??
      DisplayContentType.main,
);

Map<String, dynamic> _$DisplayContentSettingsToJson(
  _DisplayContentSettings instance,
) => <String, dynamic>{
  'contentType': _$DisplayContentTypeEnumMap[instance.contentType]!,
};

const _$DisplayContentTypeEnumMap = {
  DisplayContentType.main: 'main',
  DisplayContentType.game: 'game',
  DisplayContentType.image: 'image',
  DisplayContentType.sketch: 'sketch',
  DisplayContentType.team: 'team',
  DisplayContentType.text: 'text',
  DisplayContentType.chrono: 'chrono',
  DisplayContentType.tabata: 'tabata',
  DisplayContentType.training: 'training',
};
