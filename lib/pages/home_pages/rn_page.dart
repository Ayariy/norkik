import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/pages/home_pages/recordatorio_page.dart';
import 'package:provider/provider.dart';

import '../../providers/norkikdb_providers/user_providers.dart';

class RnPage extends StatelessWidget {
  List<double> listResponseRN;
  RnPage({Key? key, required this.listResponseRN}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Norkik App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            FadeInImage(
                fit: BoxFit.contain,
                // width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.width * 0.5,
                placeholder: AssetImage('assets/loadingDos.gif'),
                image: AssetImage('assets/robot1.png')),
            listResponseRN.where((element) => element > 0.4).toList().length > 0
                ? Column(children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 0),
                        child: AnimatedTextKit(
                            totalRepeatCount: 1,
                            animatedTexts: [
                              TypewriterAnimatedText(
                                '¡Hola ${userProvider.userGlobal.nombre}!, he notado que habitualmente creas uno o más eventos para hoy dia. ¿Te gustaría hacerlo nuevamente?',
                                textAlign: TextAlign.justify,
                                // textStyle: TextStyle(fontSize: 20),
                                speed: const Duration(milliseconds: 25),
                              ),
                            ]),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      width: double.infinity,
                      height: 0.5,
                      color: Theme.of(context).textTheme.bodyText1!.color,
                    ),
                    listResponseRN[0] > 0.4
                        ? MaterialButton(
                            minWidth: double.infinity,
                            color: Theme.of(context).primaryColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.menu_book_sharp),
                                SizedBox(
                                  width: 15,
                                ),
                                Text('ver Notas'),
                              ],
                            ),
                            textColor:
                                Theme.of(context).appBarTheme.foregroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            onPressed: () async {
                              Navigator.pushNamed(context, 'notas');
                            })
                        : const SizedBox(),
                    listResponseRN[1] > 0.4
                        ? MaterialButton(
                            minWidth: double.infinity,
                            color: Theme.of(context).primaryColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.home_work_outlined),
                                SizedBox(
                                  width: 15,
                                ),
                                Text('ver Tareas'),
                              ],
                            ),
                            textColor:
                                Theme.of(context).appBarTheme.foregroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            onPressed: () async {
                              Navigator.pushNamed(context, 'tareas');
                            })
                        : SizedBox(),
                    listResponseRN[2] > 0.4
                        ? MaterialButton(
                            minWidth: double.infinity,
                            color: Theme.of(context).primaryColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.notifications_rounded),
                                SizedBox(
                                  width: 15,
                                ),
                                Text('Ver Recordatorios'),
                              ],
                            ),
                            textColor:
                                Theme.of(context).appBarTheme.foregroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            onPressed: () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => RecordatorioPage()));
                            })
                        : SizedBox(),
                  ])
                : Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 0),
                          child: AnimatedTextKit(
                              totalRepeatCount: 1,
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  '¡Hola ${userProvider.userGlobal.nombre}! Recuerda registrar tus actividades (tareas, recordatorios o notas) el día de hoy. Para mejorar la predicción y asistirte de mejor manera',
                                  textAlign: TextAlign.justify,
                                  // textStyle: TextStyle(fontSize: 20),
                                  speed: const Duration(milliseconds: 25),
                                ),
                              ]),
                        ),
                      )
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
