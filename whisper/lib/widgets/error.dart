import 'package:flutter/material.dart';

class MyErrorWidget extends StatelessWidget {
  const MyErrorWidget(this.err, {super.key});
  final String err;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.redAccent,
          size: 50,
        ),
        const SizedBox(
          height: 20,
        ),
        Text(err)
      ],
    ));
  }
}
