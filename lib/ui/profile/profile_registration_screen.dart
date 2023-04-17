import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:page_transition/page_transition.dart';

import '../../models/main_application.dart';
import '../../models/profile.dart';
import '../splash/splash_screen.dart';
import '../widgets/gradient_button.dart';
import 'profile_login_screen.dart';

class ProfileRegistrationScreen extends StatefulWidget {
  final Widget background;

  ProfileRegistrationScreen({required this.background});
  @override
  _ProfileRegistrationScreenState createState() => _ProfileRegistrationScreenState();
}

class _ProfileRegistrationScreenState extends State<ProfileRegistrationScreen> with TickerProviderStateMixin {
  String errorText = "Введите полученный код";
  Color errorColor = const Color(0xFF999A9A);
  final MaskedTextController controller = MaskedTextController(mask: '0000');
  Animation<double>? _logoMoveAnimationBottom, _logoMoveAnimationLeft;
  AnimationController? _logoMoveAnimationControllerBottom, _logoMoveAnimationControllerLeft;
  bool formVisible = true;

  @override
  void initState() {
    super.initState();
    int moveDuration = 500;
    _logoMoveAnimationControllerBottom = AnimationController(vsync: this, duration: Duration(milliseconds: moveDuration));
    Tween _logoMoveTweenBottom = Tween<double>(begin: 1 - 1 / 3, end: 1 / 3);
    _logoMoveAnimationBottom = _logoMoveTweenBottom.animate(_logoMoveAnimationControllerBottom!) as Animation<double>?;
    _logoMoveAnimationBottom?.addListener(() {
      setState(() {});
    });

    _logoMoveAnimationControllerLeft = AnimationController(vsync: this, duration: Duration(milliseconds: moveDuration));
    Tween _logoMoveTweenLeft = Tween<double>(begin: 1 / 2.5, end: 1 / 4);
    _logoMoveAnimationLeft = _logoMoveTweenLeft.animate(_logoMoveAnimationControllerLeft!) as Animation<double>?;
    _logoMoveAnimationLeft?.addListener(() {
      setState(() {});
    });

    _logoMoveAnimationControllerLeft?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: SplashScreen()));
        // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: ProfileRegistrationScreen(background: background),duration: Duration(seconds: 2)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          widget.background,
          Positioned(
            bottom: MediaQuery.of(context).size.height * _logoMoveAnimationBottom!.value,
            left: MediaQuery.of(context).size.width * _logoMoveAnimationLeft!.value,
            child: Image.asset(
              "assets/images/splash_logo.png",
              width: MediaQuery.of(context).size.width / 2,
            ),
          ),
          AnimatedOpacity(
            opacity: formVisible ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.3),
                ),
                Column(
                  children: <Widget>[
                    ///holds email header and inputField
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 40, bottom: 10),
                          child: Text(
                            errorText,
                            style: TextStyle(fontSize: 16, color: errorColor),
                          ),
                        ),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 40, bottom: 30),
                              child: Container(
                                width: MediaQuery.of(context).size.width - 40,
                                child: Material(
                                  elevation: 10,
                                  color: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(30), topRight: Radius.circular(0))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 40, right: 20, top: 10, bottom: 10),
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      controller: controller,
                                      onChanged: (value) => Profile().code = value,
                                      decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                            color: Color(0xFFE1E1E1),
                                            fontSize: 14,
                                          )),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(right: 50),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 40),
                                        child: Text(
                                          'На номер телефона ' + Profile().phone + ' отправлен код подтверждения ...',
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(
                                            color: Color(0xFFA0A0A0),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const ShapeDecoration(
                                        shape: CircleBorder(),
                                        gradient: LinearGradient(colors: signInGradients, begin: Alignment.topLeft, end: Alignment.bottomRight),
                                      ),
                                      child: InkWell(
                                        onTap: () => FocusScope.of(context).unfocus(),
                                        child: const Icon(
                                          Icons.message,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 1.7,
                      child: GradientButton(
                        text: "Подтвердить",
                        onPressed: _onLoginPressed,
                        gradient: signUpGradients,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 1.7,
                      child: GradientButton(
                        text: "Отправить код еще раз",
                        onPressed: _onBackPressed,
                        gradient: signUpGradients,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logoMoveAnimationControllerBottom?.dispose();
    _logoMoveAnimationControllerLeft?.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    MainApplication().showProgress(context);
    String res = await Profile().registration();
    MainApplication().hideProgress(context);
    if (res == 'OK') {
      setState(() {
        formVisible = false;
      });
      _logoMoveAnimationControllerBottom?.forward();
      _logoMoveAnimationControllerLeft?.forward();
    } else {
      setState(() {
        errorText = res;
        errorColor = Colors.deepOrange;
      });
    }
  }

  void _onBackPressed() {
    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.fade, child: ProfileLoginScreen(background: widget.background), duration: const Duration(seconds: 1)));
  }
}

const List<Color> signInGradients = [
  Color(0xFF0EDED2),
  Color(0xFF03A0FE),
];

const List<Color> signUpGradients = [
  Color(0xFFFF9945),
  Color(0xFFFc6076),
];
