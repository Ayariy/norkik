import 'dart:async';
import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/models/asignatura_model.dart';
import 'package:norkik_app/models/nota_model.dart';

import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/nota_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/providers/sound.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';

class CrearNotaSonido extends StatefulWidget {
  CrearNotaSonido({Key? key}) : super(key: key);

  @override
  State<CrearNotaSonido> createState() => _CrearNotaSonidoState();
}

class _CrearNotaSonidoState extends State<CrearNotaSonido> {
  final recorder = SoundRecorder();
  final player = SoundPlaying();

  static const countDownDuration = Duration(minutes: 10);
  Duration duration = Duration();

  bool isCountDown = false;

  Timer? timer;

  bool enableBackButton = true;

  SoundPlaying? _soundPlaying;

  TextEditingController _tituloController = TextEditingController();

  NotaProvider notaProvider = NotaProvider();
  AsignaturaProvider asignaturaProvider = AsignaturaProvider();
  AsignaturaModel? asignatura;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  String? nameAudio;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    resetTime();
    nameAudio = DateTime.now().toString() + ".aac";
    recorder.init(nameAudio!);
    player.init(
      nameAudio!,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    recorder.dispose();
    player.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    asignatura = ModalRoute.of(context)!.settings.arguments as AsignaturaModel;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return enableBackButton;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Crear audio'),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(10),
              child: asignatura == null || nameAudio == null
                  ? Center(
                      child: Text('Ocurrió un problema, inténtalo más tarde'),
                    )
                  : Column(
                      children: [Center(child: _getButtonRecord()), _getForm()],
                    )),
        ),
      ),
    );
  }

  Form _getForm() {
    return Form(
      onWillPop: () async {
        return isLoading ? false : true;
      },
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _tituloController,
            validator: (value) => value!.isNotEmpty
                ? null
                : 'Ingresa el título de la nota de audio',
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.title_rounded),
              hintText: 'Título del audio',
            ),
          ),
          ListTile(
            leading: Icon(Icons.record_voice_over),
            title: Text('Reproducir grabación'),
            trailing: Icon(Icons.play_circle_fill),
            onTap: () {
              showModalPageSound();
            },
          ),
          Container(
            margin: const EdgeInsets.all(0),
            width: double.infinity,
            height: 0.5,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
          ListTile(
            leading: Icon(Icons.class_),
            title: Text(asignatura!.nombre),
            subtitle: Text('Msc. ' +
                asignatura!.docente.nombre +
                " " +
                asignatura!.docente.apellido),
          ),
          Container(
            margin: const EdgeInsets.all(0),
            width: double.infinity,
            height: 0.5,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
          ListTile(
            leading: Icon(Icons.mic),
            title: Text('Categoría'),
            subtitle: Text('Audio'),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            width: double.infinity,
            height: 0.5,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
          MaterialButton(
              minWidth: double.infinity,
              color: Theme.of(context).primaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: isLoading
                    ? [const CircularProgressIndicator()]
                    : [
                        Icon(Icons.mic_rounded),
                        SizedBox(
                          width: 15,
                        ),
                        Text('Crear Nota de Audio'),
                      ],
              ),
              textColor: Theme.of(context).appBarTheme.foregroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: isLoading
                  ? null
                  : () async {
                      // print(nameAudio);
                      if (_formKey.currentState!.validate()) {
                        if (await player.existFile()) {
                          setState(() {
                            isLoading = true;
                          });
                          String urlCacheAudio = await player.getUrlAudio();
                          File file = File(urlCacheAudio);

                          UserProvider userProvider =
                              Provider.of<UserProvider>(context, listen: false);
                          String audioUrl = await notaProvider.uploadFile(
                              userProvider.userGlobal.idUsuario,
                              nameAudio!,
                              file,
                              'Audios');
                          if (audioUrl != '') {
                            DocumentReference<Map<String, dynamic>> userRef =
                                (await userProvider.getUserReferenceById(
                                    userProvider.userGlobal.idUsuario))!;
                            DocumentReference<Map<String, dynamic>>
                                asignaturaRef = (await asignaturaProvider
                                    .getAsignaturaReferenceById(
                                        asignatura!.idAsignatura))!;

                            NotaModel nota = NotaModel(
                                idNota: 'no-id',
                                titulo: _tituloController.text.toLowerCase(),
                                descripcion: '',
                                file: audioUrl,
                                fecha: DateTime.now(),
                                categoria: 'Audio',
                                asignatura:
                                    AsignaturaModel.asignaturaModelNoData(),
                                usuario: UserModel.userModelNoData());
                            notaProvider.createNota(
                                nota, asignaturaRef, userRef);
                            Navigator.pop(context);
                          } else {
                            getAlert(context, 'Error de carga',
                                'Ocurrió un error en la carga del audio, Por favor, inténtalo más tarde');
                          }
                          // print(audioUrl);
                          setState(() {
                            isLoading = false;
                          });
                        } else {
                          getAlert(context, 'Audio sin grabar',
                              'Por favor, realiza la grabación del audio antes de proceder a guardarlo');
                        }
                      }
                    })
        ],
      ),
    );
  }

  void startTime() {
    if (!mounted) return;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      addTime();
    });
  }

  void resetTime() {
    if (!mounted) return;
    if (isCountDown) {
      setState(() {
        duration = countDownDuration;
      });
    } else {
      setState(() {
        duration = Duration();
      });
    }
    setState(() {
      timer?.cancel();
    });
  }

  void addTime() {
    final addSeconds = isCountDown ? -1 : 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;

      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  Widget _getButtonRecord() {
    final isRecording = recorder.isRecording;
    final icon = isRecording ? Icons.stop : Icons.mic;
    final text = isRecording ? 'Stop' : 'Grabar';
    final primary = isRecording ? Colors.red : Theme.of(context).cardColor;
    final onPrimary = isRecording
        ? Colors.white
        : Theme.of(context).textTheme.bodyText1!.color;
    final circleColor = isRecording ? Colors.red : null;

    //construccion temporizador digitos
    String dosDigitos(int n) => n.toString().padLeft(2, '0');
    final horas = dosDigitos(duration.inHours);
    final minutos = dosDigitos(duration.inMinutes.remainder(60));
    final segundos = dosDigitos(duration.inSeconds.remainder(60));

    final isRunning = timer == null ? false : timer!.isActive;

    return CircleAvatar(
      radius: MediaQuery.of(context).size.width * 0.25,
      backgroundColor: circleColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: MediaQuery.of(context).size.width * 0.09,
          ),
          Text(
            '$horas:$minutos:$segundos',
            style:
                TextStyle(fontSize: MediaQuery.of(context).size.width * 0.06),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                maximumSize: Size(175, 50),
                primary: primary,
                onPrimary: onPrimary),
            icon: Icon(icon),
            label: Text(text),
            onPressed: () async {
              final isRecordingV = await recorder.toggleRecording();
              if (isRunning) {
                resetTime();
                enableBackButton = true;
                player.setFile();
                showModalPageSound();
              } else {
                if (recorder.isRecording) {
                  startTime();
                  enableBackButton = false;
                }
              }
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _getSoundPlaying() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<ProgressBarState>(
            valueListenable: player.progressNotifier,
            builder: (_, value, __) {
              return ProgressBar(
                progress: value.current,
                buffered: value.buffered,
                total: value.total,
                onSeek: player.seek,
              );
            },
          ),
          ValueListenableBuilder<ButtonState>(
            valueListenable: player.buttonNotifier,
            builder: (_, value, __) {
              switch (value) {
                case ButtonState.loading:
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    width: 32.0,
                    height: 32.0,
                    child: const CircularProgressIndicator(),
                  );
                case ButtonState.paused:
                  return IconButton(
                    icon: const Icon(Icons.play_arrow),
                    iconSize: 32.0,
                    onPressed: player.playAudio,
                  );
                case ButtonState.playing:
                  return IconButton(
                    icon: const Icon(Icons.pause),
                    iconSize: 32.0,
                    onPressed: player.pauseAudio,
                  );
              }
            },
          ),
        ],
      ),
    );
  }

  void showModalPageSound() {
    showModalBottomSheet(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      // isScrollControlled: true,
      context: context,
      builder: (context) {
        return _getSoundPlaying();
      },
    );
  }
}
