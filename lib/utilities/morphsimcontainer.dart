import 'dart:ui';
import 'package:flutter/cupertino.dart';

class MorphedContainer extends StatelessWidget {
  late double? width;
  late double? height;
  final Widget? child;

  MorphedContainer({Key? key, required this.child, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25), // Morphed/rounded corners
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Blur strength
          child: Container(
            width: width!,
            height: height!,
            decoration: BoxDecoration(
              color: CupertinoColors.systemRed.withValues(
                alpha: 0.2,
              ), // Glass effect
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: CupertinoColors.black, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.white,
                  blurRadius: 10,
                  offset: Offset(0, 4),
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
