import 'package:hugeicons/hugeicons.dart';
import 'package:pikanda/frontend/devinfo_screen.dart';
import 'package:pikanda/frontend/quote_screen.dart';
import 'package:pikanda/test.dart';
import 'package:pikanda/utilities/bg.dart';
import 'package:flutter/cupertino.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Bg(
      leading: HugeIcon(
        icon: HugeIcons.strokeRoundedRefresh,
        color: CupertinoColors.activeBlue,
      ),
      middle: Text(
        'Home..!!',
        style: TextStyle(
          fontFamily: 'Blanka',
          fontSize: global.SizeConfig.screenHeight * 0.025,
          color: CupertinoColors.white,
        ),
      ),
      trailing: HugeIcon(
        icon: HugeIcons.strokeRoundedRefresh,
        color: CupertinoColors.activeBlue,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('####'),
          Text('####'),
          TestButton(),
          Text('####'),
          Text('####'),
          CheckButton(),
          Spacer(),
          Align(alignment: Alignment.bottomCenter, child: Dev()),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _future = Supabase.instance.client.from('profile').select();
  @override
  Widget build(BuildContext context) {
    return Bg(
      child: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CupertinoActivityIndicator(
                color: CupertinoColors.activeBlue,
                radius: 60,
              ),
            );
          }
          final profile = snapshot.data!;
          return ListView.builder(
            itemCount: profile.length,
            itemBuilder: ((context, index) {
              final profiles = profile[index];
              return ListTile(title: Text(profiles['access_code']));
            }),
          );
        },
      ),
    );
  }
}
