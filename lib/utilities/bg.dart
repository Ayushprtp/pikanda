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
        leading: leading!,
        middle: middle!,
        trailing: trailing!,
        automaticBackgroundVisibility: true,
      ),
      resizeToAvoidBottomInset: false,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemYellow,
          image: DecorationImage(
            image: AssetImage('assets/images/bg.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(bottom: false, child: child!),
      ),
    );
  }
}
