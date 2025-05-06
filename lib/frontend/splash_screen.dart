import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase/supabase.dart';
import 'package:pikanda/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> checkAuthAndNavigate() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    final response =
        await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single();

    final role = response['role'];
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/adminHome');
    } else {
      Navigator.pushReplacementNamed(context, '/userHome');
    }
  }

  // video controller
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        VideoPlayerController.asset('assets/videos/splash.mp4')
          ..initialize().then((_) {
            setState(() {});
          })
          ..setVolume(0.1);

    _playVideo();
  }

  void _playVideo() async {
    // playing video
    _controller.play();

    //add delay till video is complite
    await Future.delayed(const Duration(seconds: 3));

    // navigating to home screen
    Navigator.pushNamed(context, '/');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          child: Center(
            child:
                _controller.value.isInitialized
                    ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                    : Container(),
          ),
        ),
      ),
    );
  }
}
