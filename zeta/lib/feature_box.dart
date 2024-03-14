import 'package:flutter/material.dart';

class featureBox extends StatelessWidget {
  const featureBox(
      {super.key, required this.clr, required this.txt1, required this.txt2});
  final Color clr;
  final String txt1;
  final String txt2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        color: clr,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              txt1,
              style: const TextStyle(
                color: Colors.black,
                wordSpacing: 3.0,
                letterSpacing: 2.0,
                fontFamily: 'Roboto',
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 3,),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              txt2,
              style: const TextStyle(
                color: Colors.black87,
                wordSpacing: 2.5,
                letterSpacing: 1.5,
                fontFamily: 'Roboto',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }
}
