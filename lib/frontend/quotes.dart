import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
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
  bool _isFrontCardVisible = false;
  bool _isBackCardVisible = false;
  bool _isQuoteFontBold = false;
  bool _isQuoteFontItalic = false;
  String? fcard = 'assets/card/1.webp';

  String? genre = 'null';
  String? bcard = 'assets/images/icon.png';
  Color _isBackCardSelcted1 = CupertinoColors.black;
  Color _isBackCardSelcted2 = CupertinoColors.black;
  Color _isBackCardSelcted3 = CupertinoColors.black;
  Color _isFrontCardSelcted1 = CupertinoColors.black;
  Color _isFrontCardSelcted2 = CupertinoColors.black;
  Color _isFrontCardSelcted3 = CupertinoColors.black;
  Color _isFrontCardSelcted4 = CupertinoColors.black;
  Color _isFrontCardSelcted5 = CupertinoColors.black;
  Color _isFrontCardSelcted6 = CupertinoColors.black;
  Color _isFrontCardSelcted7 = CupertinoColors.black;
  Color _isFrontCardSelcted8 = CupertinoColors.black;
  Color _isFrontCardSelcted9 = CupertinoColors.black;
  Color _isFrontCardSelcted10 = CupertinoColors.black;
  Color _isFrontCardSelcted11 = CupertinoColors.black;
  Color _isFrontCardSelcted12 = CupertinoColors.black;
  Color _isFrontCardSelcted13 = CupertinoColors.black;
  Color _isFrontCardSelcted14 = CupertinoColors.black;
  Color _isFrontCardSelcted15 = CupertinoColors.black;
  Color _isFrontCardSelcted16 = CupertinoColors.black;
  Color _isFrontCardSelcted17 = CupertinoColors.black;
  Color _isFrontCardSelcted18 = CupertinoColors.black;
  Widget build(BuildContext context) {
    return Bg(
      leading: null,
      middle: Text(
        'Quote Insert..!!',
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
                child: Center(
                  child: Text(
                    '${_QuoteInput.text}',
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 16,
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
          SingleChildScrollView(

            // scrollbarOrientation: ScrollbarOrientation.top,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: MorphedContainer(
                    child: CupertinoTextField(
                      autocorrect: true,
                      minLines: 1,
                      onChanged: (value) => setState(() {

                      }),
                      // suffix: HugeIcon(
                      //   icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      //   color: Colors.black,
                      //   size: 24.0,
                      // ),
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: MorphedContainer(
                    child: CupertinoTextField(
                      autocorrect: false,
                      // suffix: HugeIcon(
                      //   icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      //   color: Colors.black,
                      //   size: 24.0,
                      // ),
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
                      maxLines: 10,
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
                                child: Center(
                                  child: Text(
                                    'Front Quote Card',
                                    style: TextStyle(fontSize: 25),
                                  ),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/1.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted1,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted1 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/1.webp';
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/2.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted2,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted2 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/2.webp';
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/3.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted3,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted3 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/3.webp';
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/4.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted4,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted4 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/4.webp';
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/5.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted5,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted5 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/5.webp';
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/6.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted6,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted6 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/6.webp';
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/7.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted7,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted7 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/7.webp';
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/8.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted8,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted3 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/8.webp';
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/9.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted9,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted9 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/9.webp';
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/10.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted10,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted10 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/10.webp';
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/11.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted11,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted11 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/11.webp';
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/12.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted12,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted12 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/12.webp';
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/13.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted13,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted13 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/13.webp';
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/14.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted14,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted3 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/14.webp';
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/15.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted15,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted15 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/15.webp';
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/16.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted16,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted16 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/16.webp';
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/17.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted17,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted17 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/17.webp';
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/18.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isFrontCardSelcted18,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isFrontCardSelcted18 =
                                            CupertinoColors.systemRed;
                                        fcard = 'assets/card/18.webp';
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
                                child: Center(
                                  child: Text(
                                    'Back Quote Card',
                                    style: TextStyle(fontSize: 25),
                                  ),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/ayu.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isBackCardSelcted1,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isBackCardSelcted1 =
                                            CupertinoColors.systemRed;
                                        bcard = 'assets/card/ayu.webp';
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/dex.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isBackCardSelcted2,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isBackCardSelcted2 =
                                            CupertinoColors.systemRed;
                                        bcard = 'assets/card/dex.webp';
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      // child: Text(''),
                                      // child: ,
                                      height:
                                          global.SizeConfig.screenWidth * 0.17,
                                      width:
                                          global.SizeConfig.screenWidth * 0.28,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.black,

                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/card/pika.webp',
                                          ),
                                          fit: BoxFit.fitWidth,
                                        ),
                                        border: Border.all(
                                          width: 2,
                                          color: _isBackCardSelcted3,
                                        ),
                                        // color: CupertinoColors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _isBackCardSelcted3 =
                                            CupertinoColors.systemRed;
                                        bcard = 'assets/card/pika.webp';
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
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
