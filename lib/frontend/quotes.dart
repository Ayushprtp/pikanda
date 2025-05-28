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
  double fontSize = 0.02; // Default font size
  String fontFamily = 'Jasmine'; // Default font family
  Alignment alignment = Alignment.center;
  TextAlign textAlign = TextAlign.center; // Default text alignment

  // List of available font families
  final List<String> _fontFamilies = [
    'SF',
    'Jasmine',
    'Blanka',
    'Ethnocentric',
    'Unitedlovehello',
    'Thisfeelings',
    'Tamalikamerge',
    'Skylight',
    'Qualityoflove',
    'Purplemystery',
    'Pandastudio',
    'Pandalovelybaby',
    'Monkeyact',
    'Feelwithme',
    'Faisaljnnkyaw',
    'Montserrat',
    'kaushanscript',
  ];
  // List of available alignments
  late final List<TextAlign> _alignments = [
    TextAlign.left,
    TextAlign.center,
    TextAlign.right,
    TextAlign.justify,
    TextAlign.end,
    TextAlign.start,
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
  String alignmentLabel(Alignment alignment) {
    if (alignment == Alignment.topLeft) return "Top Left";
    if (alignment == Alignment.topCenter) return "Top Center";
    if (alignment == Alignment.topRight) return "Top Right";
    if (alignment == Alignment.centerLeft) return "Center Left";
    if (alignment == Alignment.center) return "Center";
    if (alignment == Alignment.centerRight) return "Center Right";
    if (alignment == Alignment.bottomLeft) return "Bottom Left";
    if (alignment == Alignment.bottomCenter) return "Bottom Center";
    if (alignment == Alignment.bottomRight) return "Bottom Right";
    return alignment.toString();
  }

  final List<String> _frontquotecrads = [
    'assets/card/1.webp',
    'assets/card/2.webp',
    'assets/card/3.webp',
    'assets/card/4.webp',
    'assets/card/5.webp',
    'assets/card/6.webp',
    'assets/card/7.webp',
    'assets/card/8.webp',
    'assets/card/9.webp',
    'assets/card/10.webp',
    'assets/card/11.webp',
    'assets/card/12.webp',
    'assets/card/13.webp',
    'assets/card/14.webp',
    'assets/card/15.webp',
    'assets/card/16.webp',
    'assets/card/17.webp',
    'assets/card/18.webp',
    'assets/card/19.webp',
    'assets/card/20.webp',
    'assets/card/21.webp',
    'assets/card/22.webp',
    'assets/card/23.webp',
    'assets/card/24.webp',
    'assets/card/25.webp',
    'assets/card/26.webp',
    'assets/card/27.webp',
    'assets/card/28.webp',
    'assets/card/29.webp',
    'assets/card/30.webp',
  ];

  final List<String> _backquotecards = [
    'assets/card/ayu.webp',
    'assets/card/dex.webp',
    'assets/card/pika.webp',
  ];

  Color selectedColor = CupertinoColors.black;
  String? fcard = 'assets/card/2.webp';
  String? selectedcard = 'assets/card/2.webp';
  String? genre = 'null';
  String? bcard = 'assets/card/dex.webp';
  // String? selectedbcard = 'assets/card/dex.webp';
  int selectedfcard = 1;
  int selectedbcard = 1;

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
      barrierDismissible: true,
      barrierColor: CupertinoColors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Material(

                child: ColorPicker(
                  tonalPaletteFixedMinChroma: true,
                  enableOpacity: true,
                  enableShadesSelection: true,
                  enableTonalPalette: true,
                  enableTooltips: true,

                  color: selectedColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  pickersEnabled: <ColorPickerType, bool>{
                    ColorPickerType.wheel: true,
                    ColorPickerType.both: true,
                    ColorPickerType.primary: true,
                    ColorPickerType.custom: true,
                    ColorPickerType.accent: true,
                  },
                ),
              ),
            ],
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
                    image: AssetImage('${_frontquotecrads[selectedfcard]}'),
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
                    image: AssetImage('${_backquotecards[selectedbcard]}'),
                    fit: BoxFit.fitWidth,
                  ),
                  // color: CupertinoColors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
    Expanded(
      child: ListView(
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
                        color: CupertinoColors.black.withAlpha(150),
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
                                  setState(() {
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (context) {
                                        String selectedFontFamily =
                                            fontFamily; // local mutable state

                                        return CupertinoActionSheet(
                                          actions: [
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                5.0,
                                              ),
                                              child: MorphedContainer(
                                                height:
                                                global
                                                    .SizeConfig
                                                    .screenHeight *
                                                    0.4,
                                                child: StatefulBuilder(
                                                  builder:
                                                      (
                                                      context,
                                                      modalSetState,
                                                      ) => GridView.builder(
                                                    gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount:
                                                      3,
                                                      childAspectRatio:
                                                      1 / 0.4,
                                                      mainAxisSpacing:
                                                      5,
                                                      crossAxisSpacing:
                                                      5,
                                                    ),
                                                    itemCount:
                                                    _fontFamilies
                                                        .length,
                                                    itemBuilder: (
                                                        context,
                                                        index,
                                                        ) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          // Update local state to trigger border update in popup
                                                          modalSetState(() {
                                                            selectedFontFamily =
                                                            _fontFamilies[index];
                                                          });
                                                          // Optionally, update your main state too
                                                          setState(() {
                                                            fontFamily =
                                                            _fontFamilies[index];
                                                          });
                                                          // Optionally, dismiss the popup after selection
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: CupertinoColors
                                                                .black
                                                                .withAlpha(
                                                              150,
                                                            ),
                                                            border:
                                                            selectedFontFamily ==
                                                                _fontFamilies[index]
                                                                ? Border.all(
                                                              width:
                                                              2,
                                                              color:
                                                              CupertinoColors.activeBlue,
                                                            )
                                                                : null,
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                              25,
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsets.all(
                                                              5.0,
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                'Font',
                                                                style: TextStyle(
                                                                  fontSize:
                                                                  global.SizeConfig.screenWidth *
                                                                      0.07,
                                                                  fontFamily:
                                                                  _fontFamilies[index],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
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
                                        );
                                      },
                                    );
                                  });
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
                                      .strokeRoundedAlignBoxMiddleCenter,
                                  color:
                                  CupertinoColors.lightBackgroundGray,
                                ),
                                onTap: () {
                                  setState(() {
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (context) {
                                        Alignment selectedAlignment =
                                            alignment;
                                        return CupertinoActionSheet(
                                          actions: [
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                5.0,
                                              ),
                                              child: MorphedContainer(
                                                height:
                                                global
                                                    .SizeConfig
                                                    .screenHeight *
                                                    0.2,
                                                child: StatefulBuilder(
                                                  builder:
                                                      (
                                                      context,
                                                      modalSetState,
                                                      ) => GridView.builder(
                                                    gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount:
                                                      3,
                                                      childAspectRatio:
                                                      1 / 0.4,
                                                      mainAxisSpacing:
                                                      5,
                                                      crossAxisSpacing:
                                                      5,
                                                    ),
                                                    itemCount:
                                                    _containerAlignments
                                                        .length,
                                                    itemBuilder: (
                                                        context,
                                                        index,
                                                        ) {
                                                      final itemAlignment =
                                                      _containerAlignments[index];
                                                      return GestureDetector(
                                                        onTap: () {
                                                          modalSetState(() {
                                                            selectedAlignment =
                                                                itemAlignment;
                                                          });
                                                          setState(() {
                                                            alignment =
                                                                itemAlignment;
                                                          });
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: CupertinoColors
                                                                .black
                                                                .withAlpha(
                                                              150,
                                                            ),
                                                            border:
                                                            selectedAlignment ==
                                                                itemAlignment
                                                                ? Border.all(
                                                              width:
                                                              2,
                                                              color:
                                                              CupertinoColors.activeBlue,
                                                            )
                                                                : null,
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                              25,
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              alignmentLabel(
                                                                itemAlignment,
                                                              ),
                                                              textAlign:
                                                              TextAlign
                                                                  .center,
                                                              style: TextStyle(
                                                                color:
                                                                CupertinoColors.white,
                                                                fontSize:
                                                                global.SizeConfig.screenWidth *
                                                                    0.045,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
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
                                        );
                                      },
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
                                      .strokeRoundedTextAlignCenter,
                                  color:
                                  CupertinoColors.lightBackgroundGray,
                                ),
                                onTap: () {
                                  setState(() {
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder:
                                          (context) => CupertinoActionSheet(
                                        actions: [
                                          Padding(
                                            padding:
                                            const EdgeInsets.all(
                                              5.0,
                                            ),
                                            child: MorphedContainer(
                                              height:
                                              global
                                                  .SizeConfig
                                                  .screenHeight *
                                                  0.2,
                                              child: StatefulBuilder(
                                                builder:
                                                    (
                                                    context,
                                                    modalSetState,
                                                    ) => GridView.builder(
                                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount:
                                                    2,
                                                    childAspectRatio:
                                                    1 / 0.25,
                                                    mainAxisSpacing:
                                                    5,
                                                    crossAxisSpacing:
                                                    5,
                                                  ),
                                                  itemCount:
                                                  _alignments
                                                      .length,
                                                  itemBuilder: (
                                                      context,
                                                      index,
                                                      ) {
                                                    final alignment =
                                                    _alignments[index];
                                                    return GestureDetector(
                                                      onTap: () {
                                                        modalSetState(() {
                                                          textAlign =
                                                              alignment;
                                                        });
                                                        setState(() {
                                                          textAlign =
                                                              alignment;
                                                        });
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: CupertinoColors
                                                              .black
                                                              .withAlpha(
                                                            150,
                                                          ),
                                                          border:
                                                          textAlign ==
                                                              alignment
                                                              ? Border.all(
                                                            width:
                                                            2,
                                                            color:
                                                            CupertinoColors.activeBlue,
                                                          )
                                                              : null,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                            25,
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            alignment
                                                                .toString()
                                                                .split(
                                                              '.',
                                                            )
                                                                .last,
                                                            style: TextStyle(
                                                              color:
                                                              CupertinoColors.white,
                                                              fontSize:
                                                              global.SizeConfig.screenWidth *
                                                                  0.06,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
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
              onTap: _showGenreDialog,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedFaceId,
                size: global.SizeConfig.screenHeight * 0.04,
                color: CupertinoColors.lightBackgroundGray,
              ),
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
                        color: CupertinoColors.black.withAlpha(150),
                        height: global.SizeConfig.screenHeight * 0.15,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: GridView.builder(
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1 / 0.5,
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
                                        _frontquotecrads[index],
                                      ),
                                      fit: BoxFit.fitWidth,
                                    ),
                                    border:
                                    selectedfcard == index
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
                                  setState(() {
                                    selectedfcard = index;
                                  });
                                },
                              );
                            },
                            itemCount: _frontquotecrads.length,
                          ),
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
                        color: CupertinoColors.black.withAlpha(150),
                        height: global.SizeConfig.screenHeight * 0.1,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: GridView.builder(
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1 / 0.55,
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
                                        _backquotecards[index],
                                      ),
                                      fit: BoxFit.fitWidth,
                                    ),
                                    border:
                                    selectedbcard == index
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
                                  setState(() {
                                    selectedbcard = index;
                                  });
                                },
                              );
                            },
                            itemCount: _backquotecards.length,
                          ),
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
                      print(selectedfcard);
                      print(selectedbcard);
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
