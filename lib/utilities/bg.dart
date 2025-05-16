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

        transitionBetweenRoutes: true,
        border: Border(

          bottom: BorderSide(
            color: CupertinoColors.black.withValues(alpha: 0.6),
          ),
        ),
        backgroundColor: CupertinoColors.black.withValues(alpha: 0.4),
        automaticallyImplyLeading: false,
        enableBackgroundFilterBlur: true,
        padding:EdgeInsetsDirectional.all(5),
        brightness: Brightness.dark,
        leading: leading,
        middle: middle,
        trailing: trailing,
        automaticBackgroundVisibility: false,
      ),
      resizeToAvoidBottomInset: true,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.black,
          image: DecorationImage(
            image: AssetImage('assets/images/bg_brick.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(bottom: false, child: Stack(children: [
          child!
    ],),),)
    );
  }
}
