import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Pikanda/utilities/globalvar.dart' as global;

class QuoteWidget extends StatefulWidget {
  const QuoteWidget({super.key});

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        // decoration: BoxDecoration(image: DecorationImage(image: global.svg1)),
        child: Center(child: Text('####')),
        // height: global.SizeConfig.screenWidth * 0.6,
      ),
    );
  }
}
