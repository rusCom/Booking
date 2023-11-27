import 'package:flutter/material.dart';

import '../utils/core.dart';
import 'arc_clipper.dart';

class MainBackground extends StatelessWidget {
  final showLogo;

  MainBackground({this.showLogo = false});

  Widget topHalf(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return Flexible(
      flex: 2,
      child: ClipPath(
        clipper: ArcClipper(),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: Const.kitGradients,
              )),
            ),
            showLogo
                ? Center(
                    child: SizedBox(
                        height: deviceSize.height / 6,
                        width: deviceSize.width / 2,
                        child: Image.asset(
                          "assets/images/splash_logo.png",
                          fit: BoxFit.cover,
                          height: deviceSize.height / 6,
                        )),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  final bottomHalf = Flexible(
    flex: 3,
    child: Container(),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[topHalf(context), bottomHalf],
    );
  }
}
