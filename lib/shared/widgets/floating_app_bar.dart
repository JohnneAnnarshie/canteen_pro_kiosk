
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class FloatingAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final int? currentIndex;
  final Color? titleBackgroundColor;
  final Color? titleForegroundColor;


  const FloatingAppbar(
      {super.key,
        required this.title,
        this.actions,
        this.currentIndex,
        this.leading,
        this.titleBackgroundColor,
        this.titleForegroundColor
      });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    return SizedBox(
      height: preferredSize.height,
      width: preferredSize.width,
      child: Row(
        children: [
          const SizedBox(width: 8),
          if (leading != null)...[
          _appBarContainer(context, leading!, padding: 8),
          ],
          const SizedBox(width: 10),
         _appBarContainer(
           context,
           Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: titleForegroundColor ?? colorScheme.onSurface,
              ),
            ),
          ),
          const Spacer(),
          ...?actions,
        ],
      )
    );
  }

  Widget _appBarContainer(BuildContext context, Widget child, {double margin = 0, double padding = 16}) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
      margin: EdgeInsets.symmetric(horizontal: margin),
      decoration: BoxDecoration(
          color: titleBackgroundColor ?? (isDarkMode ? colorScheme.surfaceContainer
              : colorScheme.surfaceContainer),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isDarkMode ? colorScheme.onSurface.withAlpha(120)
                :  AppTheme.surfaceVariantLight,
            width: 1,
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: isDarkMode ? colorScheme.onSurface : colorScheme.onSurface,
          //     blurRadius: 0.2,
          //     offset: const Offset(0, 0.5),
          //   )
          // ]
      ),
      child: child,
    );
  }
}

class FloatingAppBarActionButton extends StatelessWidget {
  const FloatingAppBarActionButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.color
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Color? color;


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    return TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: color ?? colorScheme.surfaceContainer,
          side: BorderSide(
              color: isDarkMode ? colorScheme.onSurface.withAlpha(120)
                  :  AppTheme.surfaceVariantLight
          ),
        ),
        icon: Icon(icon, color: colorScheme.onSurface),
        label: Text(label)
    );
  }
}
