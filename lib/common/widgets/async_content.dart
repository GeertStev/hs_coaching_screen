import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/errors/user_message.dart';
import 'package:hs_coaching_screen/common/web/page_reload.dart';

/// Toont een [AsyncValue] op het scherm zonder ooit een ruwe fout te tonen.
///
/// - Data: [data].
/// - Fout ná eerdere data: de laatst goede inhoud blijft staan, met een klein
///   foutsymbool in de hoek.
/// - Fout zonder data: een rustige melding via core's `userMessage`.
///
/// Zolang een fout zichtbaar is, herlaadt [ScreenErrorIndicator] na een
/// tijdje de pagina, zodat de kiosk zichzelf herstelt.
class AsyncContent<T> extends StatelessWidget {
  const AsyncContent({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.skipLoadingOnRefresh = true,
    this.showErrorBadge = true,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final bool skipLoadingOnRefresh;

  /// Zet op `false` als een buitenliggende widget dezelfde provider al met
  /// een foutsymbool toont (bv. `globalSettingsProvider` in `DisplayLimits`),
  /// zodat er niet overal hetzelfde symbool verschijnt.
  final bool showErrorBadge;

  @override
  Widget build(BuildContext context) {
    final showData =
        value.hasValue && (skipLoadingOnRefresh || !value.isLoading);
    if (showData) {
      final child = data(value.requireValue);
      if (!value.hasError || !showErrorBadge) return child;
      return Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          const Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: ScreenErrorIndicator(),
            ),
          ),
        ],
      );
    }
    if (value.hasError) {
      return Center(child: ScreenErrorIndicator(error: value.error));
    }
    return loading?.call() ?? const Center(child: CircularProgressIndicator());
  }
}

/// Foutsymbool, met de melding erbij als [error] gegeven is. Blijft het
/// [reloadAfter] lang zichtbaar, dan wordt [onReload] aangeroepen (standaard:
/// de pagina herladen).
class ScreenErrorIndicator extends StatefulWidget {
  const ScreenErrorIndicator({
    super.key,
    this.error,
    this.reloadAfter = const Duration(minutes: 5),
    this.onReload = reloadPage,
  });

  final Object? error;
  final Duration reloadAfter;
  final VoidCallback onReload;

  @override
  State<ScreenErrorIndicator> createState() => _ScreenErrorIndicatorState();
}

class _ScreenErrorIndicatorState extends State<ScreenErrorIndicator> {
  late final Timer _reloadTimer;

  @override
  void initState() {
    super.initState();
    _reloadTimer = Timer(widget.reloadAfter, widget.onReload);
  }

  @override
  void dispose() {
    _reloadTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    if (widget.error == null) {
      return Icon(Icons.error_outline, color: color, size: 20);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, color: color, size: 48),
        const SizedBox(height: 8),
        Text(
          userMessage(widget.error),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
