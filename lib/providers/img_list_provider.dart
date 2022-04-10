import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';

class ImgListProvider extends ChangeNotifier {
  List<File> _listImg = [];

  List<File> get listImg => _listImg;

  void addItemListImg(File img) {
    _listImg.add(img);
    notifyListeners();
  }

  File removeAtItemListImg(int index) {
    File file = _listImg.removeAt(index);
    notifyListeners();
    return file;
  }

  void insertItemListImg(int index, File file) {
    _listImg.insert(index, file);
    notifyListeners();
  }

  void clearList() {
    _listImg.clear();
  }
}
