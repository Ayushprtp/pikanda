import 'package:flutter/cupertino.dart';

class Website extends StatefulWidget {
  const Website({super.key});

  @override
  State<Website> createState() => _WebsiteState();
}

class _WebsiteState extends State<Website> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: Text('Soon To Be Available'));
  }
}
