import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:norkik_app/widget/logo_theme_util.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class AcercaSettingPage extends StatelessWidget {
  const AcercaSettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          scrollDirection: Axis.vertical,
          physics: BouncingScrollPhysics(),
          children: [NorkikAboutPage(), NosotrosAboutPage(), LogosAboutPage()],
        ),
      ),
    );
  }
}

class NorkikAboutPage extends StatelessWidget {
  const NorkikAboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedTextKit(totalRepeatCount: 1, animatedTexts: [
            TypewriterAnimatedText(
              'Norkik App',
              speed: Duration(milliseconds: 75),
              textStyle: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 30,
              ),
            ),
          ]),
          AnimatedTextKit(totalRepeatCount: 1, animatedTexts: [
            TypewriterAnimatedText(
              'Versión 1.0.0',
              textStyle: TextStyle(fontSize: 20),
              speed: Duration(milliseconds: 100),
            ),
          ]),
          getLogoNorkikWithTheme(
              context, MediaQuery.of(context).size.height * 0.45),
          AnimatedTextKit(totalRepeatCount: 1, animatedTexts: [
            TypewriterAnimatedText(
              '2021 - 2022',
              textStyle: TextStyle(fontSize: 20),
              speed: Duration(milliseconds: 100),
            ),
          ]),
          SizedBox(
            height: 50,
          ),
          AnimatedTextKit(repeatForever: true, animatedTexts: [
            WavyAnimatedText(
              'Ver más',
              textStyle: TextStyle(fontSize: 20),
              speed: Duration(milliseconds: 100),
            ),
          ]),
          Icon(
            FontAwesomeIcons.chevronDown,
            color: Theme.of(context).disabledColor,
          )
        ],
      ),
    );
  }
}

class NosotrosAboutPage extends StatelessWidget {
  const NosotrosAboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedTextKit(totalRepeatCount: 1, animatedTexts: [
            TypewriterAnimatedText(
              '¿Qué es Norkik App?',
              textStyle: TextStyle(fontSize: 20),
              speed: Duration(milliseconds: 50),
            ),
          ]),
          Divider(),
          AnimatedTextKit(totalRepeatCount: 1, animatedTexts: [
            TypewriterAnimatedText(
                'Norkik App es una agenda educativa desarrollada por estudiantes para estudiantes.',
                textAlign: TextAlign.justify
                // speed: Duration(milliseconds: 50),
                ),
          ]),
          Divider(),
          AnimatedTextKit(totalRepeatCount: 1, animatedTexts: [
            TypewriterAnimatedText(
              '¿Quiénes somos?',
              textStyle: TextStyle(fontSize: 20),
              speed: Duration(milliseconds: 50),
            ),
          ]),
          Divider(),
          AnimatedTextKit(totalRepeatCount: 1, animatedTexts: [
            TypewriterAnimatedText(
                'Somos estudiantes de Ingeniería en Ciencias de la Computación. \n\nSabemos que cada producto que desarrollamos requiere de capacidades, dedicación y una actitud audaz que nos hemos ganado a pulso.',
                textAlign: TextAlign.justify
                // speed: Duration(milliseconds: 50),
                ),
          ]),
          Divider(),
          Wrap(
            alignment: WrapAlignment.spaceAround,
            children: [
              _getItemSocial(Icons.whatsapp, 'WhatsApp', '+593 97 951 2702'),
              _getItemSocial(Icons.facebook, 'Facebook', 'Malkik Ayariy'),
              _getItemSocial(Icons.email, 'Email', 'salvadormalkik@gmail.com'),
              _getItemSocial(Icons.whatsapp, 'WhatsApp', '+593 99 994 8125'),
              _getItemSocial(Icons.facebook, 'Facebook', 'Odalys Noreen'),
              _getItemSocial(Icons.email, 'Email', 'odalysnoreen@gmail.com')
            ],
          )
        ],
      ),
    );
  }

  _getItemSocial(IconData icon, String nameSocial, String description) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 45,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nameSocial,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(description)
            ],
          )
        ],
      ),
    );
  }
}

class LogosAboutPage extends StatelessWidget {
  const LogosAboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInImage(
            height: MediaQuery.of(context).size.height * 0.27,
            placeholder: AssetImage('assets/loadingDos.gif'),
            image: AssetImage('assets/upec.png'),
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: 30,
          ),
          FadeInImage(
            height: MediaQuery.of(context).size.height * 0.27,
            placeholder: AssetImage('assets/loadingDos.gif'),
            image: AssetImage('assets/compu.png'),
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
