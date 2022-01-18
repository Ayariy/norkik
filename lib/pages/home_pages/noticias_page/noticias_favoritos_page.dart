import 'package:flutter/material.dart';
import 'package:norkik_app/models/noticia_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/noticia_provider.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:intl/intl.dart';

class NoticiasFavoritos extends StatefulWidget {
  const NoticiasFavoritos({Key? key}) : super(key: key);

  @override
  State<NoticiasFavoritos> createState() => _NoticiasFavoritosState();
}

class _NoticiasFavoritosState extends State<NoticiasFavoritos> {
  GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();
  NoticiaProvider noticiasProvider = NoticiaProvider();

  List<NoticiaModel> listNoticias = [];
  StorageShared storageShared = StorageShared();
  List<String> listFavoritosId = [];
  List<NoticiaModel> listNoticiasAux = [];

  bool isSecondAppbarSelection = false;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getListaNoticiasFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: isSecondAppbarSelection
            ? AppBar(
                leading: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      isSecondAppbarSelection = false;
                      listNoticias = listNoticiasAux;
                    });
                  },
                ),
                title: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      hintText: 'Buscar',
                      hintStyle: TextStyle(
                          color:
                              Theme.of(context).appBarTheme.foregroundColor)),
                  style: TextStyle(
                      color: Theme.of(context).appBarTheme.foregroundColor),
                  onChanged: (text) {
                    setState(() {
                      listNoticias.clear();
                    });
                    _buscarListaNoticiasFavoritos(text);
                  },
                ),
              )
            : AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context, () {});
                  },
                ),
                title: Text('Noticias favoritas'),
                actions: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          isSecondAppbarSelection = true;
                        });
                      },
                      icon: Icon(Icons.search))
                ],
              ),
        body: Column(
          children: [
            listNoticias.isEmpty && !isLoading
                ? Expanded(
                    child:
                        Center(child: Text('Agregue sus noticias a favoritos')))
                : SizedBox(),
            isLoading
                ? Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Expanded(
                    child: AnimatedList(
                        key: animatedListKey,
                        initialItemCount: listNoticias.length,
                        itemBuilder: (context, index, animation) {
                          return _buildItemFav(context, index, animation);
                        }),
                  ),
          ],
        ));
  }

  void deleteItem(int index, NoticiaModel noticiaItem) async {
    listNoticias.remove(noticiaItem);
    listNoticiasAux.remove(noticiaItem);
    listFavoritosId.remove(noticiaItem.idNoticia);
    animatedListKey.currentState!.removeItem(index, (context, animation) {
      return _buildItemFav(context, index, animation);
    });
    storageShared.agregarFavoritosStorageList(listFavoritosId);
  }

  void _getListaNoticiasFavoritos() async {
    isLoading = true;
    listFavoritosId = await storageShared.obtenerFavoritosStorageList();

    if (listFavoritosId.isNotEmpty) {
      for (String item in listFavoritosId) {
        NoticiaModel noticiaModel = await noticiasProvider.getNoticiaById(item);
        noticiaModel.isFavorite = true;
        listNoticias.add(noticiaModel);
      }
    }

    listNoticiasAux = listNoticias.map((e) => e).toList();
    setState(() {
      isLoading = false;
    });
  }

  void _buscarListaNoticiasFavoritos(String title) {
    setState(() {
      isLoading = true;
    });
    listNoticias = listNoticiasAux.map((e) => e).toList();

    listNoticias = listNoticias
        .where((element) => element.titulo.contains(title.toUpperCase()))
        .toList();

    setState(() {
      isLoading = false;
    });
  }

  Widget _buildItemFav(
      BuildContext context, int index, Animation<double> animation) {
    return index >= listNoticias.length
        ? SizedBox()
        : SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset(0, 0),
            ).animate(animation),
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 0.5,
                          color:
                              Theme.of(context).textTheme.bodyText1!.color!))),
              child: ListTile(
                onTap: () {
                  index >= listNoticias.length
                      ? ''
                      : Navigator.pushNamed(context, 'noticia',
                          arguments: listNoticias[index]);
                },
                title: Text(
                  index >= listNoticias.length
                      ? ''
                      : listNoticias[index].titulo,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(index >= listNoticias.length
                    ? ''
                    : DateFormat.yMMMEd('es')
                        .format(listNoticias[index].fecha)),
                trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () {
                    index >= listNoticias.length
                        ? ''
                        : Navigator.pushNamed(context, 'noticia',
                            arguments: listNoticias[index]);
                  },
                ),
                leading: IconButton(
                  onPressed: () {
                    if (!(index >= listNoticias.length)) {
                      setState(() {
                        listNoticias[index].isFavorite =
                            !listNoticias[index].isFavorite;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          snackBarFavorite('Se ha removido de favoritos',
                              Icons.remove_circle));
                    }
                    deleteItem(index, listNoticias[index]);
                  },
                  icon: index >= listNoticias.length
                      ? SizedBox()
                      : !listNoticias[index].isFavorite
                          ? Icon(Icons.star_border,
                              key: const ValueKey('iconFav1'))
                          : Icon(
                              Icons.star,
                              key: const ValueKey('iconFav2'),
                            ),
                  iconSize: 40,
                  color: Colors.yellow.shade800,
                ),
              ),
            ),
          );
  }

  SnackBar snackBarFavorite(String text, IconData icon) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    return SnackBar(
      duration: Duration(seconds: 1),
      backgroundColor: Theme.of(context).primaryColor,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
          ),
        ],
      ),
    );
  }
}
