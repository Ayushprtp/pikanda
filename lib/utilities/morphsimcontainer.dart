import 'dart:ui';
import 'package:flutter/cupertino.dart';

class MorphedContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  final BorderRadiusGeometry borderRadius;
  final Color? Colors;
  final Border? Borders;


  MorphedContainer({Key? key, required this.child, this.height, this.width, Border? border,BorderRadius? borderRadius,Color? Colors}):Borders=Border.all(color: CupertinoColors.black.withAlpha(50),width: 1),Colors= Colors ?? CupertinoColors.black.withAlpha(5),borderRadius = borderRadius ?? BorderRadius.circular(25);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: ClipRRect(
        borderRadius: borderRadius, // Morphed/rounded corners
        child: Container(
          decoration: BoxDecoration(
          border: Borders,),
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
