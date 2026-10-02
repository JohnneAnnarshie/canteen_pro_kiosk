import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

/// A smooth swipe-to-perform action button.
///
/// The user drags the handle to the end of the track to trigger [onSwipeComplete].
/// If released before reaching the threshold, it snaps back with a spring-like curve.
/// On success, the handle animates to the end and the track fills, then optionally
/// calls [onSwipeComplete] once.
///
/// Usage:
/// ```dart
/// SwipeActionButton(
///   text: 'Swipe to confirm',
///   onSwipeComplete: () async {
///     await Future.delayed(const Duration(seconds: 1)); // e.g. an API call
///   },
/// )
/// ```
class SwipeActionButton extends StatefulWidget {
  const SwipeActionButton({
    super.key,
    required this.onSwipeComplete,
    this.text = 'Swipe to perform',
    this.completedText = 'Done!',
    this.height = 60,
    this.width,
    this.trackTrimWidth = 11,
    this.backgroundColor,
    this.trackFillColor,
    this.handleColor,
    this.textColor,
    this.icon = Icons.arrow_forward_rounded,
    this.successIcon = Icons.check_rounded,
    this.borderRadius = 30,
    this.swipeThreshold = 0.75,
    this.enabled = true,
  });

  /// Called when the user completes the swipe. Can be async (e.g. a network call);
  /// the handle will show a loading state until it resolves, then animate to success.
  final Future<bool> Function() onSwipeComplete;

  final String text;
  final String completedText;
  final double height;
  final double? width;
  final double trackTrimWidth;
  final Color? backgroundColor;
  final Color? trackFillColor;
  final Color? handleColor;
  final Color? textColor;
  final IconData icon;
  final IconData successIcon;
  final double borderRadius;

  /// Fraction (0-1) of the track the handle must cross to trigger completion.
  final double swipeThreshold;

  final bool enabled;

  @override
  State<SwipeActionButton> createState() => _SwipeActionButtonState();
}

enum _SwipeState { idle, dragging, loading, success }

class _SwipeActionButtonState extends State<SwipeActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _dragExtent = 0; // 0.0 -> 1.0, position of handle along the track
  _SwipeState _state = _SwipeState.idle;
  double _trackWidth = 0;
  final double _handleSize = 52;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
      setState(() => _dragExtent = _controller.value);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _maxDrag => (_trackWidth - (_handleSize + widget.trackTrimWidth)).clamp(0, double.infinity);

  void _onDragUpdate(DragUpdateDetails details) {
    if (_state != _SwipeState.idle && _state != _SwipeState.dragging) return;
    if (_maxDrag <= 0) return;
    setState(() {
      _state = _SwipeState.dragging;
      final delta = details.primaryDelta! / _maxDrag;
      _dragExtent = (_dragExtent + delta).clamp(0.0, 1.0);
    });
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    if (_state != _SwipeState.dragging) return;

    if (_dragExtent >= widget.swipeThreshold) {
      // Snap to end, enter loading, run the callback, then show success.
      HapticFeedback.mediumImpact();
      _controller.value = _dragExtent;
      await _animateTo(1.0);
      setState(() => _state = _SwipeState.loading);

      try {
        final actionSuccessful = await widget.onSwipeComplete();
        if (!mounted) return;
        HapticFeedback.lightImpact();
        if (actionSuccessful) {
          setState(() => _state = _SwipeState.success);
          await Future.delayed(const Duration(milliseconds: 1500), () async {
            if (!mounted) return;
            _controller.value = 1.0;
            await _animateTo(0.0);
            setState(() => _state = _SwipeState.idle);
          });
          return;
        }
        _controller.value - 1.0;
        await _animateTo(0.0);
        setState(() => _state = _SwipeState.idle);
        return;
      } catch (_) {
        if (!mounted) return;
        // Reset on failure so the user can try again.
        setState(() => _state = _SwipeState.dragging);
        _controller.value = 1.0;
        await _animateTo(0.0);
        setState(() => _state = _SwipeState.idle);
      }
    } else {
      // Snap back.
      _controller.value = _dragExtent;
      await _animateTo(0.0);
      if (!mounted) return;
      setState(() => _state = _SwipeState.idle);
    }
  }

  Future<void> _animateTo(double target) {
    return _controller.animateTo(
      target,
      curve: Curves.easeOutCubic,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ?? theme.colorScheme.surfaceVariant;
    final fillColor = widget.trackFillColor ?? theme.colorScheme.primary;
    final handleColor = widget.handleColor ?? theme.colorScheme.primary;
    final textColor = widget.textColor ?? theme.colorScheme.onSurfaceVariant;

    final isDone = _state == _SwipeState.success;
    final isLoading = _state == _SwipeState.loading;

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !widget.enabled || isLoading || isDone,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _trackWidth = widget.width ?? constraints.maxWidth;
            final handleTravel = _maxDrag * _dragExtent;

            return SizedBox(
              width: _trackWidth,
              height: widget.height,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Track background
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _trackWidth - widget.trackTrimWidth,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: isDone ? fillColor : bgColor,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: Border.all(
                        color: isDone ? fillColor : isDarkMode ? colorScheme.onSurface.withAlpha(120)
                            : AppTheme.surfaceVariantLight,
                        width: 1,
                      )
                    ),
                  ),
                  // Fill that grows as the handle moves
                  Container(
                    width: _handleSize + handleTravel,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: _state == _SwipeState.idle ? Colors.transparent :
                      fillColor.withOpacity(isDone ? 1.0 : 0.25),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                  ),
                  // Label, fades as handle covers it
                  Positioned.fill(
                    child: Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: isDone
                            ? 0.0
                            : (1.0 - (_dragExtent * 1.4)).clamp(0.0, 1.0),
                        child: Text(
                          widget.text,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: widget.enabled ? textColor : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Success label
                  if (isDone)
                    Positioned.fill(
                      child: Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: isDone ? 1.0 : 0.0,
                          child: Text(
                            widget.completedText,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Draggable handle
                  Positioned(
                    left: isDone ? _trackWidth - _handleSize - 10 : handleTravel,
                    child: GestureDetector(
                      onHorizontalDragUpdate: _onDragUpdate,
                      onHorizontalDragEnd: _onDragEnd,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _handleSize + 8,
                        height: _handleSize + 8,
                        //margin: const EdgeInsets.symmetric(horizontal: 0),
                        decoration: BoxDecoration(
                          color: widget.enabled ? isDone
                              ? theme.colorScheme.onPrimary
                              : handleColor : Colors.grey,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isLoading
                              ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                              : Icon(
                            isDone ? widget.successIcon : widget.icon,
                            color: isDone ? fillColor : theme.colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
