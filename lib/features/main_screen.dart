import 'package:flutter/material.dart';
import 'package:hs_coaching_screen/features/background.dart';
import 'package:hs_coaching_screen/features/content_switcher.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
    required this.contentWidth,
    required this.contentHeight,
  });
  final double contentWidth;
  final double contentHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Background(),

        // Content
        Padding(
          padding: EdgeInsets.only(top: 12, bottom: 42, left: 12, right: 12),
          child: Center(
            child: SizedBox(
              width: contentWidth,
              height: contentHeight,
              child: ContentSwitcher(),
            ),
          ),
        ),
      ],
    );
  }
}
