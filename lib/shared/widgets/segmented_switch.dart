import 'package:flutter/material.dart';

/// A segmented control that behaves like a switch, with a sliding
/// thumb that animates between options.
///
/// Usage:
/// ```dart
/// SegmentedSwitch(
///   options: const ['Day', 'Week', 'Month'],
///   initialIndex: 0,
///   onChanged: (index, value) => print('Selected: $value'),
/// )
/// ```
class SegmentedSwitch extends StatefulWidget {
  const SegmentedSwitch({
    super.key,
    required this.options,
    this.initialIndex = 0,
    this.onChanged,
    this.height = 40,
    this.trackColor,
    this.thumbColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  });

  final List<String> options;
  final int initialIndex;
  final void Function(int index, String value)? onChanged;
  final double height;
  final Color? trackColor;
  final Color? thumbColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  @override
  State<SegmentedSwitch> createState() => _SegmentedSwitchState();
}

class _SegmentedSwitchState extends State<SegmentedSwitch> {
  late int _selectedIndex = widget.initialIndex;

  void _select(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    widget.onChanged?.call(index, widget.options[index]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final trackColor =
        widget.trackColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.6);
    final thumbColor = widget.thumbColor ?? theme.colorScheme.surface;
    final selectedTextColor =
        widget.selectedTextColor ?? theme.colorScheme.onSurface;
    final unselectedTextColor = widget.unselectedTextColor ??
        theme.colorScheme.onSurface;
            //.withOpacity(0.65);

    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(widget.height),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth =
              (constraints.maxWidth - 2) / widget.options.length;

          return Stack(
            children: [
              // Sliding thumb
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: segmentWidth * _selectedIndex,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: thumbColor,
                    borderRadius: BorderRadius.circular(widget.height),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),

              // Labels / tap targets
              Row(
                children: List.generate(widget.options.length, (index) {
                  final isSelected = index == _selectedIndex;
                  return SizedBox(
                    width: segmentWidth,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _select(index),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: textTheme.titleMedium!.copyWith(
                            fontSize: 14,
                            fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? selectedTextColor
                                : unselectedTextColor,
                          ),
                          child: Text(widget.options[index]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- Example usage ---
//
// class ExampleScreen extends StatelessWidget {
//   const ExampleScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: SegmentedSwitch(
//             options: const ['Day', 'Week', 'Month'],
//             onChanged: (index, value) {
//               debugPrint('Selected: $value');
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }