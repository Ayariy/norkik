import 'package:flutter/material.dart';

class ElevatedButtonNorkik extends StatelessWidget {
  final String textButton;
  final Function? functionButton;

  ElevatedButtonNorkik({
    Key? key,
    required this.textButton,
    this.functionButton,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    return ElevatedButton(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            const Set<MaterialState> interactiveStates = <MaterialState>{
              MaterialState.pressed,
              MaterialState.hovered,
              MaterialState.focused,
            };
            if (states.any(interactiveStates.contains)) {
              return Theme.of(context).scaffoldBackgroundColor;
            }
            return Theme.of(context).appBarTheme.foregroundColor;
            ;
          }),
          fixedSize: MaterialStateProperty.all(Size.fromHeight(50)),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            const Set<MaterialState> interactiveStates = <MaterialState>{
              MaterialState.pressed,
              MaterialState.hovered,
              MaterialState.focused,
            };
            if (states.any(interactiveStates.contains)) {
              return Theme.of(context).textTheme.bodyText1!.color;
            }
            return Theme.of(context).primaryColor;
          })),
      onPressed: () {
        functionButton!();
      },
      child: Text(textButton),
      // Theme.of(context).primaryColor,
    );
  }
}
