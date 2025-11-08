// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter/cupertino.dart';

class TabWidget extends StatelessWidget {
  const TabWidget({
    Key? key,
    required this.text,
  }) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      width: MediaQuery.of(context).size.width * width,
      height: 15,
      child: Center(
        child: Text(text),
      ),
    );
  }
}
