import 'package:flutter/cupertino.dart';
import 'package:pikanda/utilities/morphsimcontainer.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;

class BdayCuntDown extends StatefulWidget {
  const BdayCuntDown({super.key});

  @override
  State<BdayCuntDown> createState() => _BdayCuntDownState();
}

class _BdayCuntDownState extends State<BdayCuntDown> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}



class LifeCountDown extends StatefulWidget {
  const LifeCountDown({super.key});

  @override
  State<LifeCountDown> createState() => _LifeCountDownState();
}

class _LifeCountDownState extends State<LifeCountDown> {
  void _showDeathCountdown() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoPopupSurface(
            isSurfacePainted: true,
            blurSigma: 3,
            child: Container(
              height: global.SizeConfig.screenHeight*0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SlideCountdownSeparated(
                            duration: Duration(days: 20000),
                          ),
                ],
              ),
            ));
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
          child: Text('DCount'),
      onTap: _showDeathCountdown,
      );
  }
}
