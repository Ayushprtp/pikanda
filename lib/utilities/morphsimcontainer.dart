import 'dart:ui';
import 'package:flutter/cupertino.dart';

class MorphedContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  final BorderRadiusGeometry borderRadius;
  final Color? Colors;

  MorphedContainer({Key? key, required this.child, this.height, this.width, BorderRadius? borderRadius,Color? Colors}):Colors= Colors ?? CupertinoColors.black.withAlpha(5),borderRadius = borderRadius ?? BorderRadius.circular(25);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: ClipRRect(
        borderRadius: borderRadius, // Morphed/rounded corners
        child: Container(
          width: width,
          height: height,
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ), // Blur strength
                child: Container(),
              ),
              Container(
                decoration: BoxDecoration(
                  border:Border.all(color: CupertinoColors.black.withAlpha(50),width: 1),
                  color: Colors,
                  borderRadius: borderRadius,
                ),
              ),
              child!,
            ],
          ),
        ),
      ),
    );
  }
}
