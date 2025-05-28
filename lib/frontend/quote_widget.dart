import 'package:flutter/cupertino.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:flip_card/flip_card.dart';
import 'package:pikanda/utilities/morphsimcontainer.dart';

class QuoteWidget extends StatefulWidget {
  const QuoteWidget({super.key});

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  bool _isQuoteTextItalic = false;
  bool _isQuoteTextBold = false;
  bool _isQuoteTextUnderLined = false;
  int? reacted =null;
  double fontSize = 0.025; // Default font size
  String fontFamily = 'Jasmine'; // Default font family
  Alignment alignment = Alignment.center;
  TextAlign textAlign = TextAlign.center;
  Color selectedColor = CupertinoColors.black;
  String? fcard = 'assets/card/2.webp';
  String? genre = 'null';
  final TextEditingController _QuoteInput = TextEditingController();
  String? bcard = 'assets/card/dex.webp';
  final List<String> _ios = [
    'assets/ios/smiling.webp',
    'assets/ios/upsidedownsmiling.webp',
    'assets/ios/crying.webp',
    'assets/ios/shocked.webp',
    'assets/ios/joker.webp',
    'assets/ios/sunglass.webp',
    // 'assets/ios/rightpointing.webp',
    // 'assets/ios/leftpointing.webp',
    'assets/ios/pleading.webp',
    'assets/ios/faceholdingtears.webp',
    'assets/ios/heartonfire.webp',
    'assets/ios/bandagedheart.webp',
  ];
  @override
  Widget build(BuildContext context) {
    return CupertinoContextMenu.builder(
      enableHapticFeedback: true,
      builder:
          (context, child) => Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              child: FlipCard(
                fill: Fill.fillBack,
                flipOnTouch: true,
                // controller: _flipCardController,
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
            ),
          ),
      // child:
      actions: [
        StatefulBuilder(
    builder: (context, setLocalState) {
      return MorphedContainer(
        height: global.SizeConfig.screenHeight*0.105,
        child: GridView.builder(
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1 /1,
            mainAxisSpacing:
            5, // vertical space between cells
            crossAxisSpacing: 5,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      _ios[index],
                    ),
                    fit: BoxFit.cover,
                  ),
                  border:
                  reacted == index
                      ? Border.all(
                    width: 2,
                    color:
                    CupertinoColors
                        .activeBlue,
                  )
                      : null,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                setLocalState(() {
                  reacted = index;
                });
                setState(() {
                  reacted = index;
                });
              },
            );
          },
          itemCount: _ios.length,
        ),
      );

    },
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
          },
          isDefaultAction: true,
          trailingIcon: CupertinoIcons.doc_on_clipboard_fill,
          child: const Text('Copy'),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
          },
          trailingIcon: CupertinoIcons.share,
          child: const Text('Share'),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
          },
          trailingIcon: CupertinoIcons.heart,
          child: const Text('Favorite'),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
          },
          isDestructiveAction: true,
          trailingIcon: CupertinoIcons.delete,
          child: const Text('Delete'),
        ),
          ],
        );
  }
}
