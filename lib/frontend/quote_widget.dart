import 'package:flutter/cupertino.dart';
import 'package:pikanda/frontend/quotes.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:flip_card/flip_card.dart';


class QuoteWidget extends StatefulWidget {
  const QuoteWidget({super.key});

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {

  bool _isQuoteTextItalic = false;
  bool _isQuoteTextBold = false;
  bool _isQuoteTextUnderLined = false;
  double fontSize = 0.025; // Default font size
  String fontFamily = 'Jasmine'; // Default font family
  Alignment alignment = Alignment.center;
  TextAlign textAlign = TextAlign.center;
  Color selectedColor = CupertinoColors.black;
  String? fcard = 'assets/card/2.webp';
  String? genre = 'null';
  final TextEditingController _QuoteInput = TextEditingController();
  String? bcard = 'assets/card/dex.webp';
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
            height: global.SizeConfig.screenHeight * 0.247,
            width: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('$fcard'),
                fit: BoxFit.fitWidth,
              ),
              color: CupertinoColors.black,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Align(
              alignment: alignment,
              child: Text(
                textAlign: textAlign,
                '${_QuoteInput.text}',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: global.SizeConfig.screenHeight * fontSize,
                  color: selectedColor,
                  fontStyle:
                  _isQuoteTextItalic
                      ? FontStyle.italic
                      : FontStyle.normal,
                  decoration:
                  _isQuoteTextUnderLined
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  fontWeight:
                  _isQuoteTextBold
                      ? FontWeight.normal
                      : FontWeight.normal,
                ),
              ),
            ),
          ),

          back: Container(
            height: global.SizeConfig.screenHeight * 0.25,
            width: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('$bcard'),
                fit: BoxFit.fitWidth,
              ),
              // color: CupertinoColors.black,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      );
  }
}
