import 'dart:ui';
import 'package:flutter/cupertino.dart';

class MorphedContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  MorphedContainer({Key? key, required this.child, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25), // Morphed/rounded corners
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
                  color: CupertinoColors.black.withAlpha(5),
                  borderRadius: BorderRadius.circular(25),
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
