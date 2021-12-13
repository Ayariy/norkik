import 'package:flutter/material.dart';

class OutlinedButtonNorkik extends StatelessWidget {
  final String textButton;
  final String? ruta;
  const OutlinedButtonNorkik({
    Key? key,
    required this.textButton,
    this.ruta,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    return OutlinedButton(
      style: ButtonStyle(
          side: MaterialStateProperty.all(BorderSide(
              color: Theme.of(context).textTheme.bodyText1!.color!, width: 2)),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            const Set<MaterialState> interactiveStates = <MaterialState>{
              MaterialState.pressed,
              MaterialState.hovered,
              MaterialState.focused,
            };
            if (states.any(interactiveStates.contains)) {
              return Theme.of(context).scaffoldBackgroundColor;
            }
            return Theme.of(context).textTheme.bodyText1!.color;
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
            return Colors.transparent;
          })),
      onPressed: () {
        Navigator.pushNamed(context, ruta!);
      },
      child: Text(textButton),
    );
  }
}
