import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final double blur;
  final BoxConstraints boxConstraints;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Gradient? gradient;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  final BoxShape boxShape;
  final AlignmentGeometry gradientStart;
  final AlignmentGeometry gradientEnd;
  final Color backgroundColor;


  const GlassContainer({
    super.key,
    this.child,
    this.borderRadius = 20,
    this.boxConstraints = const BoxConstraints(maxWidth: 500),
    this.blur = 15,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.gradient,
    this.borderColor = const Color(0x33FFFFFF),
    this.borderWidth = 1,
    this.boxShadow,
    this.width,
    this.height,
    this.boxShape = BoxShape.rectangle,
    this.gradientStart = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      constraints: boxConstraints,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: boxShape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        shape: boxShape
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: boxShape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
              shape: boxShape,
              gradient: gradient ??
                  LinearGradient(
                    begin: gradientStart,
                    end: gradientEnd,
                    colors: [
                      backgroundColor.withOpacity(0.25),
                      backgroundColor.withOpacity(0.05),
                    ],
                  ),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),

              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}