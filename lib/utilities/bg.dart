import 'package:flutter/cupertino.dart';

class Bg extends StatelessWidget {
  const Bg({super.key, this.child});
  final Widget? child;
  @override
  // late Widget? child;
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemPurple,
          // image: DecorationImage(
          //   image: AssetImage('assets/images/bg.png'),
          //   fit: BoxFit.cover,
          // ),
        ),
        child: SafeArea(bottom: false, child: child!),
      ),
    );
  }
}
