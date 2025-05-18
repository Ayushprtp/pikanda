import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pikanda/utilities/bg.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:pikanda/utilities/morphsimcontainer.dart';

class QuoteInsertScreen extends StatefulWidget {
  const QuoteInsertScreen({super.key});

  @override
  State<QuoteInsertScreen> createState() => _QuoteInsertScreenState();
}

class _QuoteInsertScreenState extends State<QuoteInsertScreen> {
  final TextEditingController _QuoteInput = TextEditingController();
  final TextEditingController _SongInput = TextEditingController();
  final TextEditingController _FontSize = TextEditingController();
  bool _isFrontCardVisible = false;
  bool _isBackCardVisible = false;
  bool _isQuoteFormatVisible = false;
  bool _isQuoteTextItalic = false;
  bool _isQuoteTextBold = false;
  bool _isQuoteTextUnderLined = false;
  double fontSize = 0.025; // Default font size
  String fontFamily = 'Jasmine'; // Default font family
  Alignment alignment = Alignment.center;
  TextAlign textAlign = TextAlign.center; // Default text alignment

  // List of available font families
  final List<String> _fontFamilies = [
    'SF',
    'Jasmine',
    'Blanka',
    'Ethnocentric',
  ];
  // List of available alignments
  final List<TextAlign> _alignments = [
    TextAlign.left,
    TextAlign.center,
    TextAlign.right,
    TextAlign.justify,
  ];

  final List<Alignment> _containerAlignments = [
    // List of Alignment for container
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.centerLeft,
    Alignment.center,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.bottomRight,
  ];

  Color selectedColor = CupertinoColors.black;
  String? fcard = 'assets/card/2.webp';
  String? selectedcard = 'assets/card/2.webp';
  String? genre = 'null';
  String? bcard = 'assets/card/dex.webp';
  String? selectedbcard = 'assets/card/dex.webp';

  void _showGenreDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Select Genre'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                setState(() {
                  genre = 'Happy';
                });
                Navigator.of(context).pop();
              },
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedSmile,
                color: CupertinoColors.systemYellow,
                size: global.SizeConfig.screenHeight * 0.035,
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                setState(() {
                  genre = 'Neutral';
                });
                Navigator.of(context).pop();
              },
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedNeutral,
                color: CupertinoColors.white,
                size: global.SizeConfig.screenHeight * 0.035,
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                setState(() {
                  genre = 'Sad';
                });
                Navigator.of(context).pop();
              },
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedSad01,
                color: CupertinoColors.activeBlue,
                size: global.SizeConfig.screenHeight * 0.035,
              ),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCancel02,
                color: CupertinoColors.destructiveRed,
                size: global.SizeConfig.screenHeight * 0.035,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showColorPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return MorphedContainer(
          height: global.SizeConfig.screenHeight * 0.5,
          Colors: CupertinoColors.destructiveRed,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Container(
                  //use a Material widget here, as the color picker from the package is a Material widget.
                  child: Material(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: ColorPicker(
                        color: selectedColor,
                        onColorChanged: (Color color) {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        pickersEnabled: <ColorPickerType, bool>{
                          ColorPickerType.both: true,
                          ColorPickerType.primary: true,
                          ColorPickerType.accent: true,
                          ColorPickerType.wheel: true,
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Bg(
      leading: CupertinoNavigationBarBackButton(),
      middle: Text(
        'Quote Upload..!!',
        style: TextStyle(
          fontFamily: 'Ethnocentric',
          fontSize: global.SizeConfig.screenHeight * 0.025,
          color: CupertinoColors.white,
        ),
      ),
      trailing: HugeIcon(
        icon: HugeIcons.strokeRoundedAccountSetting03,
        color: CupertinoColors.systemGrey,
      ),
      child: Column(
        children: [
          Padding(
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
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: MorphedContainer(
                  child: Column(
                    children: [
                      CupertinoTextField(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 10.0,
                        ),
                        suffix: GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedAiEditing,
                              color: CupertinoColors.white,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _isQuoteFormatVisible = !_isQuoteFormatVisible;
                            });
                          },
                        ),
                        style: TextStyle(
                          fontFamily: 'SF',
                          fontSize: 16,
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
                        autocorrect: true,
                        minLines: 1,
                        onChanged: (value) => setState(() {}),
                        placeholder: "Enter Quote",
                        decoration: BoxDecoration(
                          // color: CupertinoColors.activeGreen,
                          border: Border.all(
                            color: CupertinoColors.systemGrey,
                          ), // Customize the border
                          borderRadius: BorderRadius.circular(
                            25,
                          ), // Customize the border radius
                        ),
                        controller: _QuoteInput,
                        maxLines: 16,
                      ),
                      Visibility(
                        visible: _isQuoteFormatVisible,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: MorphedContainer(
                            Colors: CupertinoColors.black.withAlpha(150),
                            height: global.SizeConfig.screenHeight * 0.04,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: GestureDetector(
                                    child: HugeIcon(
                                      icon:
                                          _isQuoteTextItalic
                                              ? HugeIcons
                                                  .strokeRoundedTextItalicSlash
                                              : HugeIcons
                                                  .strokeRoundedTextItalic,
                                      color:
                                          CupertinoColors.lightBackgroundGray,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isQuoteTextItalic =
                                            !_isQuoteTextItalic;
                                      });
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: GestureDetector(
                                    child: HugeIcon(
                                      icon:
                                          _isQuoteTextBold
                                              ? HugeIcons.strokeRoundedTextBold
                                              : HugeIcons.strokeRoundedTextBold,
                                      color:
                                          CupertinoColors.lightBackgroundGray,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isQuoteTextBold = !_isQuoteTextBold;
                                      });
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: GestureDetector(
                                    child: HugeIcon(
                                      icon:
                                          _isQuoteTextUnderLined
                                              ? HugeIcons
                                                  .strokeRoundedTextUnderline
                                              : HugeIcons
                                                  .strokeRoundedTextUnderline,
                                      color:
                                          CupertinoColors.lightBackgroundGray,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isQuoteTextUnderLined =
                                            !_isQuoteTextUnderLined;
                                      });
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: GestureDetector(
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedTextFont,
                                      color:
                                          CupertinoColors.lightBackgroundGray,
                                    ),
                                    onTap: () {
                                      showCupertinoModalPopup(
                                        context: context,
                                        builder:
                                            (context) => CupertinoActionSheet(
                                              actions:
                                                  _fontFamilies.map((
                                                    String family,
                                                  ) {
                                                    return CupertinoActionSheetAction(
                                                      onPressed: () {
                                                        setState(() {
                                                          fontFamily = family;
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        });
                                                      },
                                                      child: Text(
                                                        family,
                                                        style: TextStyle(
                                                          fontFamily: family,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                              cancelButton:
                                                  CupertinoActionSheetAction(
                                                    isDestructiveAction: true,
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                    child: Text('Cancel'),
                                                  ),
                                            ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: SizedBox(
                                    width:
                                        global.SizeConfig.screenWidth * 0.125,
                                    child: CupertinoTextField(
                                      placeholder: "Size",
                                      controller: _FontSize,
                                      keyboardType: TextInputType.number,
                                      maxLength: 5,
                                      minLines: 1,
                                      maxLines: 1,
                                      decoration: BoxDecoration(
                                        // color: CupertinoColors.activeGreen,
                                        border: Border.all(
                                          color: CupertinoColors.systemGrey,
                                        ), // Customize the border
                                        borderRadius: BorderRadius.circular(
                                          25,
                                        ), // Customize the border radius
                                      ),
                                      onChanged: (_FontSize) {
                                        setState(() {
                                          final parsedValue = double.tryParse(
                                            _FontSize,
                                          );
                                          if (parsedValue != null &&
                                              parsedValue > 0) {
                                            fontSize = parsedValue;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: GestureDetector(
                                    child: HugeIcon(
                                      icon:
                                          HugeIcons
                                              .strokeRoundedAlignBoxTopCenter,
                                      color:
                                          CupertinoColors.lightBackgroundGray,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        showCupertinoModalPopup(
                                          context: context,
                                          builder:
                                              (context) => CupertinoActionSheet(
                                                actions:
                                                    _containerAlignments.map((
                                                      Alignment alignment,
                                                    ) {
                                                      return CupertinoActionSheetAction(
                                                        onPressed: () {
                                                          setState(() {
                                                            this.alignment =
                                                                alignment;
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                          });
                                                        },
                                                        child: Text(
                                                          alignment
                                                              .toString()
                                                              .split('.')
                                                              .last,
                                                        ),
                                                      );
                                                    }).toList(),
                                                cancelButton:
                                                    CupertinoActionSheetAction(
                                                      isDestructiveAction: true,
                                                      onPressed: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                              ),
                                        );
                                      });
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: GestureDetector(
                                    child: HugeIcon(
                                      icon:
                                          HugeIcons
                                              .strokeRoundedTextAlignRight01,
                                      color:
                                          CupertinoColors.lightBackgroundGray,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        showCupertinoModalPopup(
                                          context: context,
                                          builder:
                                              (context) => CupertinoActionSheet(
                                                actions:
                                                    _alignments.map((
                                                      TextAlign alignment,
                                                    ) {
                                                      return CupertinoActionSheetAction(
                                                        onPressed: () {
                                                          setState(() {
                                                            textAlign =
                                                                alignment;
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                          });
                                                        },
                                                        child: Text(
                                                          alignment
                                                              .toString()
                                                              .split('.')
                                                              .last,
                                                        ), // Show alignment name
                                                      );
                                                    }).toList(),
                                                cancelButton:
                                                    CupertinoActionSheetAction(
                                                      isDestructiveAction: true,
                                                      onPressed: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                              ),
                                        );
                                      });
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: GestureDetector(
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedPaintBoard,
                                      color:
                                          CupertinoColors.lightBackgroundGray,
                                    ),
                                    onTap: () {
                                      _showColorPicker(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedFaceId,
                    size: global.SizeConfig.screenHeight * 0.04,
                    color: CupertinoColors.lightBackgroundGray,
                  ),
                  onTap: _showGenreDialog,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: MorphedContainer(
                  child: CupertinoTextField(
                    autocorrect: false,

                    padding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 10.0,
                    ),
                    placeholder: "Enter Song Url From YT",
                    decoration: BoxDecoration(
                      // color: CupertinoColors.activeGreen,
                      border: Border.all(
                        color: CupertinoColors.systemGrey,
                      ), // Customize the border
                      borderRadius: BorderRadius.circular(
                        25,
                      ), // Customize the border radius
                    ),
                    controller: _SongInput,
                    minLines: 1,
                    maxLines: 1000,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: MorphedContainer(
                  // color: CupertinoColors.black,
                  width: double.maxFinite,
                  child: Column(
                    children: [
                      GestureDetector(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'Front Quote Card',
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                            Spacer(),
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowTurnDown,
                              color: CupertinoColors.white,
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _isFrontCardVisible = !_isFrontCardVisible;
                          });
                        },
                      ),
                      Visibility(
                        visible: _isFrontCardVisible,
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: MorphedContainer(
                            Colors: CupertinoColors.black.withAlpha(150),
                            height: global.SizeConfig.screenHeight * 0.15,
                            child: GridView(
                              padding: EdgeInsetsDirectional.all(10),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent:
                                        global.SizeConfig.screenWidth *
                                        0.39, // cell width
                                    mainAxisExtent:
                                        global.SizeConfig.screenHeight * 0.075,
                                    mainAxisSpacing:
                                        5, // vertical space between cells
                                    crossAxisSpacing: 5, // cell height
                                  ),
                              children: [
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage('assets/card/1.webp'),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/1.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/1.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage('assets/card/2.webp'),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/2.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/2.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage('assets/card/3.webp'),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/3.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/3.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage('assets/card/4.webp'),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/4.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/4.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage('assets/card/5.webp'),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/5.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/5.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage('assets/card/6.webp'),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/6.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/6.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage('assets/card/7.webp'),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/7.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/7.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage('assets/card/8.webp'),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/8.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/8.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage('assets/card/9.webp'),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/9.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/9.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/card/10.webp',
                                        ),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/10.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/10.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/card/11.webp',
                                        ),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/11.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/11.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/card/12.webp',
                                        ),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/12.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/12.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/card/13.webp',
                                        ),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/13.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/13.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/card/14.webp',
                                        ),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/14.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/14.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/card/15.webp',
                                        ),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/15.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/15.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/card/16.webp',
                                        ),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/16.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/16.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/card/17.webp',
                                        ),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/17.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/17.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/card/18.webp',
                                        ),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedcard == 'assets/card/18.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      fcard = 'assets/card/18.webp';
                                      selectedcard = fcard;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: MorphedContainer(
                  width: double.maxFinite,
                  child: Column(
                    children: [
                      GestureDetector(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'Back Quote Card',
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                            Spacer(),
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowTurnDown,
                              color: CupertinoColors.white,
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _isBackCardVisible = !_isBackCardVisible;
                          });
                        },
                      ),
                      Visibility(
                        visible: _isBackCardVisible,
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: MorphedContainer(
                            Colors: CupertinoColors.black.withAlpha(150),
                            height: global.SizeConfig.screenHeight * 0.1,
                            child: GridView(
                              padding: EdgeInsetsDirectional.all(10),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent:
                                        global.SizeConfig.screenWidth *
                                        0.39, // cell width
                                    mainAxisExtent:
                                        global.SizeConfig.screenHeight * 0.075,
                                    mainAxisSpacing:
                                        5, // vertical space between cells
                                    crossAxisSpacing: 5, // cell height
                                  ),
                              children: [
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/card/ayu.webp',
                                        ),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedbcard == 'assets/card/ayu.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      bcard = 'assets/card/ayu.webp';
                                      selectedbcard = bcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/card/dex.webp',
                                        ),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedbcard == 'assets/card/dex.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      bcard = 'assets/card/dex.webp';
                                      selectedbcard = bcard;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    //
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.transparent,

                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/card/pika.webp',
                                        ),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      border:
                                          selectedbcard ==
                                                  'assets/card/pika.webp'
                                              ? Border.all(
                                                width: 2,
                                                color:
                                                    CupertinoColors.activeBlue,
                                              )
                                              : null,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      bcard = 'assets/card/pika.webp';
                                      selectedbcard = bcard;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ],
              ),
              // ),
              // ),
              // Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CupertinoButton.filled(
                        child: HugeIcon(
                          size: global.SizeConfig.screenHeight * 0.03,
                          icon: HugeIcons.strokeRoundedCancel02,
                          color: CupertinoColors.destructiveRed,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      CupertinoButton.filled(
                        child: HugeIcon(
                          size: global.SizeConfig.screenHeight * 0.03,
                          icon: HugeIcons.strokeRoundedSent02,
                          color: CupertinoColors.activeGreen,
                        ),
                        onPressed: () {
                          print(fcard);
                          print(bcard);
                          print(genre);
                          print(_QuoteInput.text);
                          print(_SongInput.text);
                          print(_isQuoteTextUnderLined);
                          print(_isQuoteTextItalic);
                          print(_isQuoteTextBold);
                          print(fontSize);
                          print(fontFamily);
                          print(textAlign);
                          print(alignment);
                          print(selectedColor);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EditQuote extends StatefulWidget {
  const EditQuote({super.key});

  @override
  State<EditQuote> createState() => _EditQuoteState();
}

class _EditQuoteState extends State<EditQuote> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class RecentsQuotes extends StatefulWidget {
  const RecentsQuotes({super.key});

  @override
  State<RecentsQuotes> createState() => _RecentsQuotesState();
}

class _RecentsQuotesState extends State<RecentsQuotes> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class QuoteList extends StatefulWidget {
  const QuoteList({super.key});

  @override
  State<QuoteList> createState() => _QuoteListState();
}

class _QuoteListState extends State<QuoteList> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
