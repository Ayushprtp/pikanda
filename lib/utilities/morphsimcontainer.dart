import 'dart:ui';
import 'package:flutter/cupertino.dart';

class MorphedContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  final BorderRadiusGeometry borderRadius;
  final Color? color;
  final Border? border;

  MorphedContainer({
    Key? key,
    required this.child,
    this.height,
    this.width,
    this.border,
    BorderRadiusGeometry? borderRadius,
    this.color,
  })  : borderRadius = borderRadius ?? BorderRadius.circular(25),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
            border: border ??
                Border.all(
                  color: CupertinoColors.black.withAlpha(50),
                  width: 1,
                ),
            color: color ?? CupertinoColors.black.withAlpha(5),
            borderRadius: borderRadius,
          ),
          width: width,
          height: height,
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ),
                child: Container(),
              ),
              if (child != null) child!,
            ],
          ),
        ),
      ),
    );
  }
}