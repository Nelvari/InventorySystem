import 'package:flutter/material.dart';

var primaryColor = Colors.blue;
var warningColor = const Color(0xFFE9C46A);
var dangerColor = const Color(0xFFE76F51);
var successColor = const Color(0xFF2A9D8F);
var greyColor = const Color(0xFFAFAFAF);

TextStyle headerStyle({int level = 1, bool dark = true}) {
  List<double> levelSize = [30, 24, 20, 14, 12];

  return TextStyle(
      fontSize: levelSize[level-1],
      fontWeight: FontWeight.bold,
      color: dark ? Colors.black : Colors.white);
}
TextStyle textStyle({int level = 1, bool bold = false, bool dark = true}) {
  List<double> levelSize = [30, 24, 20, 14, 12];
  return TextStyle(
      fontSize: levelSize[level-1],
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: dark ? Colors.black : Colors.white);
}

var buttonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
    backgroundColor: primaryColor);

InputDecoration boxInputDecoration(String label) {
  return InputDecoration(
      label: Text(label, style: headerStyle(level: 3)),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)));
}
InputDecoration customInputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: textStyle(level: 4, dark: true),
    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: greyColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
  );
}
class InputLayout extends StatelessWidget {
  final String label;
  final Widget child;

  const InputLayout(this.label, this.child, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: headerStyle(level: 3),
          ),
          SizedBox(height: 5),
          child,
        ],
      ),
    );
  }
}