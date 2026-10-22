import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_screen/common/widgets/async_content.dart';
import 'package:hs_coaching_screen/common/widgets/club_logo.dart';
import 'package:hs_coaching_core/global_settings/display_global_settings.dart';
import 'package:hs_coaching_screen/data/providers/global_settings_provider.dart';
import 'package:hs_coaching_screen/features/text/data/text_repository.dart';
import 'package:hs_coaching_core/text/display_text.dart';

class TextDisplay extends ConsumerWidget {
  const TextDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(textProvider);
    final globalSettings = ref.watch(globalSettingsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2a2b2e),
        border: Border.all(
          color: ColorScheme.of(context).onSurface,
          width: 3,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: ClubLogo(maxHeight: 200, greyscale: true, opacity: 0.25),
          ),
          AsyncContent(
            value: text,
            data: (displayText) => AsyncContent(
              value: globalSettings,
              showErrorBadge: false, // al getoond door DisplayLimits
              data: (settings) => _buildContent(context, displayText, settings),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DisplayText? displayText,
    DisplayGlobalSettings settings,
  ) {
    if (displayText == null || displayText.text.isEmpty) {
      return const SizedBox.shrink();
    }
    final title = displayText.title?.trim();
    return Center(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title.isNotEmpty) ...[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 32,
                      fontFamily: 'Anybody',
                    ),
                  ),
                  const SizedBox(height: 8, width: double.infinity),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      displayText.text,
                      style: const TextStyle(
                        fontSize: 19.5,
                        color: Color(0xFFC8C6C5),
                        fontFamily: 'HankenGrotesk',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
