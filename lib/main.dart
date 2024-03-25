import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'data.dart';

class Scene extends StatefulWidget {
  const Scene({super.key});

  @override
  State<Scene> createState() => _SceneState();
}

class _SceneState extends State<Scene> {
  final petal = 64;

  // var scale = [];
  // var sample = [];

  int sampleIndex = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        if (sampleIndex > data['A']!.length - 1) {
          sampleIndex = 0;
        } else {
          sampleIndex++;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (p0, constraint) {
        final List<double> pole = [constraint.maxWidth / 2, constraint.maxHeight / 2];

        final radius = constraint.maxWidth / 2 * 0.5625;

        List<Circle> circle = [
          Circle(
            color: Color.fromRGBO(241, 240, 237, 0.1),
            pole: pole,
            petal: petal,
            radius: radius,
            alpha: 0,
            blurSigma: 0,
            size: constraint.biggest,
          ),
          Circle(
            color: Color.fromRGBO(241, 240, 237, 0.1),
            pole: pole,
            petal: petal,
            radius: 1.2 * radius,
            alpha: pi * 2 / 3,
            blurSigma: 0,
            size: constraint.biggest,
          ),
          Circle(
            color: Color.fromRGBO(241, 240, 237, 0.1),
            pole: pole,
            petal: petal,
            radius: 1.5 * radius,
            alpha: pi * 4 / 3,
            blurSigma: 7,
            size: constraint.biggest,
          )
        ];

        for (int i = 0; i < circle.length; i++) {
          if (sampleIndex < data['A']!.length) {
            switch (i) {
              case 0:
                circle[i].update(data['A']![sampleIndex]);
                break;
              case 1:
                circle[i].update(data['B']![sampleIndex]);
                break;
              case 2:
                circle[i].update(data['C']![sampleIndex]);
                break;
              default:
            }
          }
        }

        // List<Widget> widgets = [
        //   Align(
        //     alignment: Alignment.center,
        //     child: Container(
        //       decoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(241, 240, 237, 0.1)),
        //     ),
        //   )
        // ];

        // widgets.addAll(circle
        //     .map((e) => Align(
        //           alignment: Alignment.center,
        //           child: e,
        //         ))
        //     .toList());

        // return Container(
        //   child: Stack(fit: StackFit.expand, children: widgets),
        // );

        return Container(
          child: Stack(
              children: circle
                  .map((e) => Align(
                        alignment: Alignment.center,
                        child: e,
                      ))
                  .toList()),
        );
      },
    );
  }

  // _downsampling({n=32}){
  //   var length=
  // }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          child: Center(
            child: Container(
              width: 200,
              height: 200,
              // color: Colors.grey,
              child: Scene(),
            ),
          ),
        )),
  ));
}

class Circle extends StatelessWidget {
  final List<double> pole;

  final int petal;

  final double radius;

  final double alpha;

  final Color color;

  final double blurSigma;

  final Size size;

  var buffer = [];

  var data = [];

  var length;

  //  Circle({super.key, required this.color, required this.pole, required this.petal, required this.radius, required this.alpha,this.buffer=const []});

  Circle({
    super.key,
    required this.pole,
    required this.petal,
    required this.radius,
    required this.alpha,
    required this.color,
    required this.blurSigma,
    required this.size,
  }) {
    length = petal * 3;

    //init
    var theta = 2 * pi / petal;
    var cosTheta = cos(theta);
    var sinTheta = sin(theta);
    var h = radius * (4 * (1 - cos(theta / 2))) / (3 * sin(theta / 2));
    List<double> A = [radius, 0];
    List<double> B = [radius, h];
    List<double> C = [radius * cosTheta + h * sinTheta, radius * sinTheta - h * cosTheta];
    for (int i = 0, idx = 0; i < petal; ++i, idx += 3) {
      var cosNTheta = cos(i * theta + alpha);
      var sinNTheta = sin(i * theta + alpha);
      data.add(_rotate(A, cosNTheta, sinNTheta));
      data.add(_rotate(B, cosNTheta, sinNTheta));
      data.add(_rotate(C, cosNTheta, sinNTheta));
      // data[idx] = _rotate(A, cosNTheta, sinNTheta);
      // data[idx + 1] = _rotate(B, cosNTheta, sinNTheta);
      // data[idx + 2] = _rotate(C, cosNTheta, sinNTheta);
    }

    for (int i = 0; i < data.length; i++) {
      var v = data[i];
      buffer.add([v[0] + pole[0], v[1] + pole[1]]);
      // buffer[i] = [v[0] + pole[0], v[1] + pole[1]];
    }
    // buffer[buffer.length] = buffer[0];
    buffer.add(buffer[0]);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _Circle(pole: pole, petal: petal, radius: radius, color: color, alpha: alpha, buffer: buffer, blurSigma: blurSigma),
    );
  }

  void update(var scale) {
    // print('=====');
    // print(scale);
    for (int i = data.length - 1; i >= 0; i--) {
      buffer[i][0] = data[i][0] * scale[i] + pole[0];
      buffer[i][1] = data[i][1] * scale[i] + pole[1];
    }
  }

  List<double> _rotate(List<double> p, double cosalpha, double sinalpha) {
    return [p[0] * cosalpha - p[1] * sinalpha, p[1] * cosalpha + p[0] * sinalpha];
  }
}

class _Circle extends CustomPainter {
  final pole;

  final petal;

  final radius;

  final alpha;

  final length;

  List<dynamic>? buffer;

  final double blurSigma;

  final data = [];

  final Color color;

  _Circle({this.pole, this.petal, this.radius, this.alpha, this.length, required this.color, this.buffer = const [], required this.blurSigma});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = _createGradientShader(size)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma
          // _calculateBlurSigma(Size(200, 200)),
          )
      ..color = Colors.black.withOpacity(0.34);

    final Path path = Path();

    // path.moveTo(buffer![0][0], buffer![0][1]);
    path.moveTo(0, 0);
    for (int i = 0, idx = 0; i < petal; ++i, idx += 3) {
      var A = buffer![idx];
      var B = buffer![idx + 1];
      var C = buffer![idx + 2];
      var D = buffer![idx + 3];
      path.lineTo(A[0], A[1]);
      path.cubicTo(B[0], B[1], C[0], C[1], D[0], D[1]);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _Circle oldDelegate) {
    return buffer != oldDelegate.buffer || color != oldDelegate.color || petal != oldDelegate.petal || blurSigma != oldDelegate.blurSigma;
  }

  Shader _createGradientShader(Size size) {
    return LinearGradient(
      colors: [Color.fromRGBO(135, 109, 255, 1), Color.fromRGBO(121, 134, 247, 1), Color.fromRGBO(95, 0, 221, 1)],
      stops: [0, 0.4, 1],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  double _calculateBlurSigma(Size size) {
    // print(Size(200, 200));
    // 根据大小动态调整模糊半径
    return blurSigma * size.shortestSide / 100;
  }
}
