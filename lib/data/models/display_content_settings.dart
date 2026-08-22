import 'package:freezed_annotation/freezed_annotation.dart';

part 'display_content_settings.freezed.dart';
part 'display_content_settings.g.dart';

/// The type of content to be displayed on the screen.
enum DisplayContentType {
  main,
  game,
  image,
  sketch,
  team,
  text,
  chrono,
  tabata,
  training,
}

/// Represents the content settings for a display.
///
/// Path: /clubs/{clubId}/displays/{displayDeviceId}/settings/content
@freezed
abstract class DisplayContentSettings with _$DisplayContentSettings {
  const factory DisplayContentSettings({
    @Default(DisplayContentType.main)
    @JsonKey(unknownEnumValue: DisplayContentType.main)
    DisplayContentType contentType,
  }) = _DisplayContentSettings;

  factory DisplayContentSettings.fromJson(Map<String, dynamic> json) =>
      _$DisplayContentSettingsFromJson(json);
}
