import 'package:flutter/cupertino.dart';

class RectangleClip extends CustomClipper<Path> {
  Offset tl, tr, bl, br;
  RectangleClip(
      {required this.tl, required this.tr, required this.bl, required this.br});
  @override
  Path getClip(
    Size size,
  ) {
    Path path = Path();
    path.moveTo(tl.dx, tl.dy);
    path.lineTo(tr.dx, tr.dy);
    path.lineTo(br.dx, br.dy);
    path.lineTo(bl.dx, bl.dy);
    // path.lineTo(size.width * 0.75, size.height);
    return path;
  }

  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
