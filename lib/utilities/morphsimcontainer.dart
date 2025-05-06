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
        borderRadius: BorderRadius.circular(45), // Morphed/rounded corners
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur strength
          child: Opacity(
            opacity: 0.1,
            child: Container(
              width: width!,
              height: height!,
              decoration: BoxDecoration(
                color: CupertinoColors.black, // Glass effect
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: CupertinoColors.white, width: 0.5),
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
      ),
    );
  }
}
