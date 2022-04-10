import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class OcrPage extends StatefulWidget {
  OcrPage({Key? key}) : super(key: key);
  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  TextEditingController textEditingController = TextEditingController();
  String text = '';
  Dio dio = Dio();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    print(MediaQuery.of(context).size.height);
    print(MediaQuery.of(context).size.width.toString().substring(0, 2));
    return Scaffold(
      appBar: AppBar(title: const Text('OCR')),
      body: TextFormField(
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.text_snippet_rounded),
            hintText: 'Seleccione una imagen, para digitalizarla a texto',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        keyboardType: TextInputType.multiline,
        controller: textEditingController,
        maxLines: int.parse(
            MediaQuery.of(context).size.width.toString().substring(0, 2)),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: isLoading
              ? CircularProgressIndicator()
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.camera),
                      onPressed: () async {
                        chooseImage(ImageSource.camera);
                      },
                    ),
                    Container(
                      color: Theme.of(context)
                          .appBarTheme
                          .foregroundColor!
                          .withOpacity(0.2),
                      width: 2,
                      height: 15,
                    ),
                    IconButton(
                      icon: Icon(Icons.image),
                      onPressed: () async {
                        chooseImage(ImageSource.gallery);
                      },
                    )
                  ],
                )),
    );
  }

  void chooseImage(ImageSource source) async {
    XFile? fileGallery = await ImagePicker().pickImage(source: source);

    if (fileGallery != null) {
      setState(() {
        isLoading = true;
      });
      String fileName = fileGallery.path.split('/').last;
      try {
        FormData formData = FormData.fromMap(
            {'file': await MultipartFile.fromFile(fileGallery.path)});
        var tex = await dio.post('https://ocrnorkik.herokuapp.com/api/ocr',
            data: formData);
        setState(() {
          textEditingController.text = tex.data['text'].toString();
        });
        setState(() {
          isLoading = false;
        });
        print(tex);
      } catch (e) {
        print(e.toString());
      }
    }
  }
}
