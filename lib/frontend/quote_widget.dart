import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:flip_card/flip_card.dart';


class QuoteWidget extends StatefulWidget {
  const QuoteWidget({super.key});

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FlipCard(
        fill: Fill.fillBack,
        flipOnTouch: true,

        direction: FlipDirection.HORIZONTAL,
        speed: 500,
        front: Container(
          height: global.SizeConfig.screenHeight*0.247,
          width: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/card/10.webp'),fit: BoxFit.fitWidth),
            color: CupertinoColors.black,
            borderRadius: BorderRadius.circular(25),
          ),
          child:Center(
            child: Text('हेल्लो ',style: TextStyle(color: CupertinoColors.black,fontSize: 16),),
          ),),

        back: Container(
          height: global.SizeConfig.screenHeight*0.25,
          width: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/card/dex.webp'),fit: BoxFit.fitWidth),
            // color: CupertinoColors.black,
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }
}
