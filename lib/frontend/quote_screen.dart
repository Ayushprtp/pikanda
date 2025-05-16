import 'package:flutter/material.dart';
import 'package:pikanda/utilities/bg.dart';
import 'package:flutter/cupertino.dart';
import 'package:pikanda/frontend/quote_widget.dart';
import 'package:pikanda/frontend/song_widget.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:hugeicons/hugeicons.dart';
import 'package:pikanda/utilities/morphsimcontainer.dart';

class QuoteScreen extends StatefulWidget {
  QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final FocusNode _urlFocusNode = FocusNode();
  String? _currentUrl;
  @override
  Widget build(BuildContext context) {
    return
    // Bg(
    // child:
    Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.black,
            image: DecorationImage(
              image: AssetImage('assets/images/bg_brick.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          appBar: CupertinoNavigationBar(
            leading: CupertinoNavigationBarBackButton(),
            middle: Text(
              'Quotesss..!!',
              style: TextStyle(
                fontFamily: 'Ethnocentric',
                fontSize: global.SizeConfig.screenHeight * 0.025,
                color: CupertinoColors.white,
              ),
            ),
            trailing: GestureDetector(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedBookmark02,
                color: CupertinoColors.systemGrey,
              ),
              onTap: () {},
            ),

            transitionBetweenRoutes: true,
            border: Border(
              bottom: BorderSide(
                color: CupertinoColors.black.withValues(alpha: 0.6),
              ),
            ),
            backgroundColor: CupertinoColors.black.withValues(alpha: 0.4),
            automaticallyImplyLeading: false,
            enableBackgroundFilterBlur: true,
            padding: EdgeInsetsDirectional.all(5),
            brightness: Brightness.dark,
            automaticBackgroundVisibility: false,
          ),
          backgroundColor: CupertinoColors.black.withAlpha(0),
          resizeToAvoidBottomInset: true,
          body: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Align(alignment: Alignment.center, child: QuoteWidget()),
              // Align(alignment: Alignment.bottomCenter,child: Response()),
              Spacer(),
              Response(),

              // Spacer(),
            ],
          ),
          // bottomNavigationBar: Align(alignment: Alignment.bottomCenter, child: SizedBox(child: SongWidget())),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [SongWidget()],
          ),
        ),
      ],
    );

    // ))
  }
}

// void _onUrlFocusChange() {
//   if (_urlFocusNode.hasFocus) {
//     // When the TextField gains focus, scroll it into view.
//     // Using addPostFrameCallback to ensure this runs after the layout has been updated for the keyboard.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && _urlFocusNode.context != null) {
//         Scrollable.ensureVisible(
//           _urlFocusNode.context!,
//           duration: const Duration(milliseconds: 250), // Animation duration
//           curve: Curves.easeOut, // Animation curve
//           alignment: 0.4, // Try to align the field slightly above center (0.0 is top, 1.0 is bottom)
//         );
//       }
//     });
//   }
// }
class Response extends StatefulWidget {
  const Response({super.key});

  @override
  State<Response> createState() => _ResponseState();
}

class _ResponseState extends State<Response> {
  final TextEditingController _response = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: MorphedContainer(
        width: double.maxFinite,
        // height: double.maxFinite,
        child: Column(
          children: [
            CupertinoTextField(
              onTapOutside: (value) {
                setState(() {});
                FocusManager.instance.primaryFocus?.unfocus();
              },
              prefix: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedHugeicons,
                    color: CupertinoColors.white,
                  ),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedHugeicons,
                    color: CupertinoColors.white,
                  ),
                ],
              ),
              suffixMode: OverlayVisibilityMode.editing,
              suffix: Row(
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedHugeicons,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
              style: TextStyle(
                fontFamily: 'SF',
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              autocorrect: true,
              minLines: 2,
              onChanged: (value) => setState(() {}),
              placeholder: "Express Your Feelingsss..!!",
              decoration: BoxDecoration(
                color: CupertinoColors.darkBackgroundGray.withValues(
                  alpha: 0.5,
                ),
                border: Border.all(
                  color: CupertinoColors.systemGrey,
                ), // Customize the border
                borderRadius: BorderRadius.circular(
                  25,
                ), // Customize the border radius
              ),
              controller: _response,
              maxLines: 8,
            ),
          ],
        ),
      ),
    );
  }
}

//it will show
// -Quotesflipcard
// -song plays
// -reply leave your feeling
// - love ur unoved the quote
