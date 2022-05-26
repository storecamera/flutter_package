import 'package:flutter/material.dart';

class SelluryText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Gradient? gradient;

  const SelluryText(this.text, {Key? key, this.fontSize, this.fontWeight, this.gradient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
        shaderCallback: (Rect bounds) {
          return (gradient ?? selluryGradient).createShader(Offset.zero & bounds.size);
        },
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ));
  }
}

const LinearGradient selluryGradient = LinearGradient(
  colors: [
    Color.fromARGB(0xff, 137, 128, 255),
    Color.fromARGB(0xff, 0, 239, 209)
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
