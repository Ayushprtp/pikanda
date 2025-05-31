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
  // String fontFamily = global.fontFamilies[1]; // Default font family
  Alignment alignment = global.containerAlignments[4];
  TextAlign textAlign = global.alignments[1]; // Default text alignment


  Color selectedColor = CupertinoColors.black;
  String? genre = 'null';
  int selectedfcard = 1;
  int selectedbcard = 1;
  int fontFamily =1;

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
      leading: Navigator.canPop(context)
          ? CupertinoNavigationBarBackButton(
        previousPageTitle: 'Home',
        onPressed: () {
          Navigator.pop(context);
        },
      )
          : null,
      middle: Text(
        'Quote Upload..!!',
        style: TextStyle(
          fontFamily: 'Ethnocentric',
          fontSize: global.SizeConfig.screenHeight * 0.020,
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
                    image: AssetImage('${global.frontQuoteCards[selectedfcard]}'),
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
                        fontFamily: global.fontFamilies[fontFamily],
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
                    image: AssetImage('${global.backQuoteCards[selectedbcard]}'),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
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
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                              CupertinoColors
                                                  .lightBackgroundGray,
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
                                                  ? HugeIcons
                                                      .strokeRoundedTextBold
                                                  : HugeIcons
                                                      .strokeRoundedTextBold,
                                          color:
                                              CupertinoColors
                                                  .lightBackgroundGray,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _isQuoteTextBold =
                                                !_isQuoteTextBold;
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
                                              CupertinoColors
                                                  .lightBackgroundGray,
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
                                              CupertinoColors
                                                  .lightBackgroundGray,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            showCupertinoModalPopup(
                                              context: context,
                                              builder: (context) {
                                                String selectedFontFamily =
                                                    global.fontFamilies[fontFamily]; // local mutable state

                                                return CupertinoActionSheet(
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
                                                            0.4,
                                                        child: StatefulBuilder(
                                                          builder:
                                                              (
                                                                context,
                                                                modalSetState,
                                                              ) => GridView.builder(
                                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                                                    global.fontFamilies
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
                                                                        global.fontFamilies[index];
                                                                      });
                                                                      // Optionally, update your main state too
                                                                      setState(() {
                                                                        fontFamily =
                                                                        index;
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
                                                                                global.fontFamilies[index]
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
                                                                              global.fontFamilies[index],
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
                                                        isDestructiveAction:
                                                            true,
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: SizedBox(
                                        width:
                                            global.SizeConfig.screenWidth *
                                            0.125,
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
                                              final parsedValue =
                                                  double.tryParse(_FontSize);
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
                                              CupertinoColors
                                                  .lightBackgroundGray,
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
                                                                      3,
                                                                  childAspectRatio:
                                                                      1 / 0.4,
                                                                  mainAxisSpacing:
                                                                      5,
                                                                  crossAxisSpacing:
                                                                      5,
                                                                ),
                                                                itemCount:
                                                                    global.containerAlignments
                                                                        .length,
                                                                itemBuilder: (
                                                                  context,
                                                                  index,
                                                                ) {
                                                                  final itemAlignment =
                                                                  global.containerAlignments[index];
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
                                                                          global.alignmentLabel(
                                                                            itemAlignment,
                                                                          ),
                                                                          textAlign:
                                                                              TextAlign.center,
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
                                                        isDestructiveAction:
                                                            true,
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
                                              CupertinoColors
                                                  .lightBackgroundGray,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            showCupertinoModalPopup(
                                              context: context,
                                              builder:
                                                  (
                                                    context,
                                                  ) => CupertinoActionSheet(
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
                                                                        1 /
                                                                        0.25,
                                                                    mainAxisSpacing:
                                                                        5,
                                                                    crossAxisSpacing:
                                                                        5,
                                                                  ),
                                                                  itemCount:
                                                                  global.alignments
                                                                          .length,
                                                                  itemBuilder: (
                                                                    context,
                                                                    index,
                                                                  ) {
                                                                    final alignment =
                                                                        global.alignments[index];
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
                                                                          color: CupertinoColors.black.withAlpha(
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
                                                                          borderRadius: BorderRadius.circular(
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
                                                          isDestructiveAction:
                                                              true,
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
                                              HugeIcons.strokeRoundedPaintBoard,
                                          color:
                                              CupertinoColors
                                                  .lightBackgroundGray,
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
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFrontCardVisible = !_isFrontCardVisible;
                      });
                    },
                    child: MorphedContainer(
                      border: Border.all(
                        color: CupertinoColors.black,
                        width: 5,
                      ),
                      color: CupertinoColors.systemGrey.withAlpha(300),
                      width: double.maxFinite,
                      child: Column(
                        children: [
                          Row(
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
                                                global.frontQuoteCards[index],
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
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            selectedfcard = index;
                                          });
                                        },
                                      );
                                    },
                                    itemCount: global.frontQuoteCards.length,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBackCardVisible = !_isBackCardVisible;
                      });
                    },
                    child: MorphedContainer(
                      border: Border.all(color: CupertinoColors.black,width: 5),
                      color: CupertinoColors.systemGrey.withAlpha(300),
                      width: double.maxFinite,
                      child: Column(
                        children: [
                          Row(
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
                          Visibility(
                            visible: _isBackCardVisible,
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: MorphedContainer(
                                color: CupertinoColors.black.withAlpha(150),
                                height: global.SizeConfig.screenHeight * 0.086,
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
                                                global.backQuoteCards[index],
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
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            selectedbcard = index;
                                          });
                                        },
                                      );
                                    },
                                    itemCount: global.backQuoteCards.length,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
