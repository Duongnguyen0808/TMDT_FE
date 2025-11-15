import 'package:flutter/material.dart';

class ReusableText extends StatelessWidget {
  const ReusableText({
    super.key,
    required this.text,
    required this.style,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  final String text;
  final TextStyle style;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines ?? 1,
      style: style,
      softWrap: softWrap ?? true,
      overflow: overflow ?? TextOverflow.ellipsis,
      textAlign: TextAlign.left,
    );
  }
}
