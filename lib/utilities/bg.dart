import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      resizeToAvoidBottomInset: false,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.black,
          image: DecorationImage(
            image: AssetImage('assets/images/bg_brick.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(bottom: true, child: Stack(children: [
          child!
    ],),),)
    );
  }
}

class BgMaterial extends StatelessWidget {
  const BgMaterial({super.key, this.child, this.leading, this.middle, this.trailing,this.bottomWidget});
  final Widget? child;
  final Widget? leading;
  final Widget? middle;
  final Widget? trailing;
  final Widget? bottomWidget;
  @override
  Widget build(BuildContext context) {
    return
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

              // transitionBetweenRoutes: true,
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
            backgroundColor: CupertinoColors.black.withAlpha(0),
            resizeToAvoidBottomInset: true,
            body: child!,
            bottomNavigationBar: bottomWidget
          ),
        ],
      );
  }
}

