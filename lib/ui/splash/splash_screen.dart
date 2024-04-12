import 'package:booking/data/main_application.dart';
import 'package:booking/data/profile.dart';
import 'package:booking/services/debug_print.dart';
import 'package:booking/services/map_markers_service.dart';
import 'package:booking/ui/main_screen.dart';
import 'package:booking/ui/profile/profile_login_screen.dart';
import 'package:booking/ui/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final String TAG = (SplashScreen).toString(); // ignore: non_constant_identifier_names
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String state = "init";
  double posLogoBottom = 0;
  double posLogoLeft = 0;
  final Widget background = const Background();

  late Animation<double> _logoScaleAnimation;
  late AnimationController _logoScaleAnimationController;

  late Animation<double> _logoMoveAnimationBottom, _logoMoveAnimationLeft;
  late AnimationController _logoMoveAnimationControllerBottom, _logoMoveAnimationControllerLeft;

  startTime() async {
    DebugPrint().log(TAG, "startTime", "start init");
    await MainApplication().init(context);

    await Permission.notification.isDenied.then((value) async => {
      if (value) {await Permission.notification.request()}
    });

    try{
      await MapMarkersService().init();
    }catch (exception, stackTrace){
      DebugPrint().log("sys", exception.toString(), stackTrace.toString());
    }

    await profileAuth();

    DebugPrint().log(TAG, "startTime", "complete init");
  }

  profileAuth() async {
    String isAuth = await Profile().auth();
    if (isAuth == "OK") {
      DebugPrint().log(TAG, "profileAuth", "success");
      // MainApplication().nearbyRoutePoint = (await GeoService().nearby())!;
      setState(() {
        state = "main";
      });
    } else if (isAuth == "Unauthorized") {
      setState(() {
        state = "login";
      });
    } else {
      setState(() {
        state = "error";
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _logoScaleAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    Tween logoScaleTween = Tween<double>(begin: 1, end: 0.8);
    _logoScaleAnimation = logoScaleTween.animate(_logoScaleAnimationController) as Animation<double>;
    _logoScaleAnimationController.forward();
    _logoScaleAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        // DebugPrint().log(TAG, "logoScaleAnimationController.StatusListener", "AnimationStatus.completed state = $state");
        if (state == "init") {
          _logoScaleAnimationController.forward();
        } else if (state == "main") {
          Navigator.pushAndRemoveUntil(
            context,
            PageTransition(type: PageTransitionType.fade, child: const MainScreen(), duration: const Duration(seconds: 2)),
            (Route<dynamic> route) => false,
          );
          // MainApplication().startTimer();
        } else if (state == "login") {
          _logoMoveAnimationControllerBottom.forward();
          _logoMoveAnimationControllerLeft.forward();
        } else {
          _showMyDialog();
        }
      } else if (status == AnimationStatus.completed) _logoScaleAnimationController.reverse();
    });

    startTime();
    initLogoMove();
  }

  initLogoMove() {
    int moveDuration = 500;
    _logoMoveAnimationControllerBottom = AnimationController(vsync: this, duration: Duration(milliseconds: moveDuration));
    Tween logoMoveTweenBottom = Tween<double>(begin: 1 / 3, end: 1 - 1 / 3);
    _logoMoveAnimationBottom = logoMoveTweenBottom.animate(_logoMoveAnimationControllerBottom) as Animation<double>;
    _logoMoveAnimationBottom.addListener(() {
      setState(() {});
    });

    _logoMoveAnimationControllerLeft = AnimationController(vsync: this, duration: Duration(milliseconds: moveDuration));
    Tween logoMoveTweenLeft = Tween<double>(begin: 1 / 4, end: 1 / 2.5);
    _logoMoveAnimationLeft = logoMoveTweenLeft.animate(_logoMoveAnimationControllerLeft) as Animation<double>;
    _logoMoveAnimationLeft.addListener(() {
      setState(() {});
    });

    _logoMoveAnimationControllerLeft.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(context,
            PageTransition(type: PageTransitionType.fade, child: ProfileLoginScreen(background: background), duration: const Duration(seconds: 1)));
        // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: ProfileRegistrationScreen(background: background),duration: Duration(seconds: 2)));
      }
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Ошибка связи с сервером'),
                Text('Попробуйте немного попозже'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Хорошо'),
              onPressed: () {
                Navigator.of(context).pop();
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _logoMoveAnimationControllerBottom.dispose();
    _logoMoveAnimationControllerLeft.dispose();
    _logoScaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          background,
          Positioned(
            bottom: MediaQuery.of(context).size.height * _logoMoveAnimationBottom.value,
            left: MediaQuery.of(context).size.width * _logoMoveAnimationLeft.value,
            child: ScaleTransition(
              scale: _logoScaleAnimation,
              child: Image.asset(
                "assets/images/splash_logo.png",
                width: MediaQuery.of(context).size.width / 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
