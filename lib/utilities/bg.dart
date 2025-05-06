import 'package:flutter/cupertino.dart';

class Bg extends StatelessWidget {
  const Bg({super.key, this.child, this.leading, this.middle, this.trailing});
  final Widget? child;
  final Widget? leading;
  final Widget? middle;
  final Widget? trailing;
  @override
  // late Widget? child;
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.darkBackgroundGray.withOpacity(0.8),
          ),
        ),
        backgroundColor: CupertinoColors.white.withOpacity(0.25),
        leading: leading!,
        middle: middle!,
        trailing: trailing!,
        automaticBackgroundVisibility: true,
      ),
      resizeToAvoidBottomInset: false,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.activeGreen,
          image: DecorationImage(
            image: AssetImage('assets/images/bg_brick.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(bottom: false, child: child!),
      ),
    );
  }
}
