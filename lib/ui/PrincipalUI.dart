import 'dart:ui';

import 'package:HidroCrop/controller/DatabaseHelper.dart';
import 'package:HidroCrop/controller/NecesidadHidrica.dart';
import 'package:HidroCrop/controller/TiempoController.dart';
import 'package:HidroCrop/dao/Campo.dart';
import 'package:HidroCrop/dao/Cultivo.dart';
import 'package:HidroCrop/dao/CultivoEtapas.dart';
import 'package:HidroCrop/dao/Etapa.dart';
import 'package:HidroCrop/dao/Riego.dart';
import 'package:HidroCrop/dao/Tiempo.dart';
import 'package:HidroCrop/ui/CopiaSeguridadUI.dart';
import 'package:HidroCrop/ui/DetalleUI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'AltaUI.dart';

void main() => runApp(new PrincipalUI());

class PrincipalUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(accentColor: Color(0xFF4CA6CA), fontFamily: 'Roboto'),
      home: PrincipalUIState(),
    );
  }
// Pantalla principal de la aplicación
}

class PrincipalUIState extends StatefulWidget {

  @override
  _PrincipalUIState createState() {
    return _PrincipalUIState();
  }
}

class _PrincipalUIState extends State<PrincipalUIState> {
  var logger = Logger();

  List<Campo> listaCampos;
  List<Cultivo> listaCultivos;
  List<Riego> listaRiego;
  List<Etapa> listaEtapas;
  List<CultivoEtapas> listaCultivoEtapas;
  List<double> listaPorcentajeHoras;
  Future<String> _getListas;
  List<Tiempo> listaTiempo;
  var listaKc;

  @override
  void initState() {
    super.initState();
    _getListas = cargarListas();
  }

  Future<String> cargarListas() async {
    logger.i('#### START cargarListas()');
    listaCampos = [];
    listaCultivos = [];
    listaRiego = [];
    listaEtapas = [];
    listaCultivoEtapas = [];
    listaPorcentajeHoras = [];
    listaTiempo = [];
    int m = 32;
    int n = 4;

    listaKc = new List.generate(m, (_) => new List(n));

    DatabaseHelper.iniciarBD().then((status) {
      if (status != null) {
        DatabaseHelper.listaCampos().then((listMap) {
          listMap.map((map) {
            return cargarCampo(map);
          }).forEach((campo) {
            setState(() {
              listaCampos.add(campo);
            });
          });
        }).whenComplete(
          () {
            for (int i = 0; i < listaCampos.length; i++) {
              DatabaseHelper.getPorcentajeHorasDiurnasMensuales(
                      DateTime.now().month, listaCampos[i].latitud)
                  .then(
                (value) {
                  setState(() {
                    listaPorcentajeHoras.add(value);
                  });
                },
              );
              TiempoController.fetchTiempo(http.Client(),
                      listaCampos[i].latitud, listaCampos[i].longitud)
                  .then((value) {
                setState(() {
                  listaTiempo.add(value);
                });
              });
            }
          },
        );
        DatabaseHelper.listaCultivos().then((listMap) {
          listMap.map((map) {
            return cargarCultivo(map);
          }).forEach((cultivo) {
            setState(() {
              listaCultivos.add(cultivo);
            });
          });
        });
        DatabaseHelper.listaRiegos().then((listMap) {
          listMap.map((map) {
            return cargarRiego(map);
          }).forEach((riego) {
            setState(() {
              listaRiego.add(riego);
            });
          });
        });
        DatabaseHelper.listaEtapas().then((listMap) {
          listMap.map((map) {
            return cargarEtapa(map);
          }).forEach((etapa) {
            setState(() {
              listaEtapas.add(etapa);
            });
          });
        }).whenComplete(() {
          DatabaseHelper.listaCultivoEtapas().then((listMap) {
            listMap.map((map) {
              return cargarCultivoEtapas(map);
            }).forEach((cultivoEtapas) {
              setState(() {
                listaCultivoEtapas.add(cultivoEtapas);
              });
            });
          });
          for (int i = 0; i < listaCultivos.length; i++) {
            for (int e = 0; e < listaEtapas.length; e++) {
              DatabaseHelper.getKc(
                      listaCultivos[i].idCultivo, listaEtapas[e].idEtapa)
                  .then((value) {
                listaKc[i][e] = value;
              });
            }
          }
        });
      }
    });

    if (listaCultivos.length != null &&
        listaCampos.length != null &&
        listaRiego.length != null &&
        listaEtapas.length != null &&
        listaPorcentajeHoras.length != null &&
        listaTiempo.length != null &&
        listaKc.toString() != '[]') {
      logger.i('#### END cargarListas()');

      logger.d('cultivos: ' +
          listaCultivos.length.toString() +
          '\n campos: ' +
          listaCampos.length.toString() +
          '\n riego: ' +
          listaRiego.length.toString() +
          '\n horas: ' +
          listaPorcentajeHoras.length.toString() +
          '\n tiempo: ' +
          listaTiempo.length.toString());
      return 'OK';
    }
    logger.i('#### END cargarListas()');
    return 'ERROR';
  }

  Campo cargarCampo(Campo campo) {
    return Campo(
        idCampo: campo.idCampo,
        nombre: campo.nombre,
        latitud: campo.latitud,
        longitud: campo.longitud,
        eficiencia: campo.eficiencia,
        fecha_siembra: campo.fecha_siembra,
        idCultivo: campo.idCultivo,
        idRiego: campo.idRiego);
  }

  Cultivo cargarCultivo(Cultivo cultivo) {
    return Cultivo(
      idCultivo: cultivo.idCultivo,
      tipo: cultivo.tipo,
      fecha_siembra_maxima: cultivo.fecha_siembra_maxima,
      fecha_siembra_minima: cultivo.fecha_siembra_minima,
    );
  }

  Riego cargarRiego(Riego riego) {
    return Riego(
        idRiego: riego.idRiego,
        tipo: riego.tipo,
        eficiencia_maxima: riego.eficiencia_maxima,
        eficiencia_minima: riego.eficiencia_minima);
  }

  Etapa cargarEtapa(Etapa etapa) {
    return Etapa(
      idEtapa: etapa.idEtapa,
      nombre: etapa.nombre,
    );
  }

  CultivoEtapas cargarCultivoEtapas(CultivoEtapas cultivoEtapas) {
    return CultivoEtapas(
        idCultivoTieneEtapas: cultivoEtapas.idCultivoTieneEtapas,
        idCultivo: cultivoEtapas.idCultivo,
        idEtapa: cultivoEtapas.idEtapa,
        kc: cultivoEtapas.kc,
        duracion: cultivoEtapas.duracion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('images/appbar.png', height: 70),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.grey,
            ),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CopiaSeguridadUI()));
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _getListas,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == 'OK') {
            return ListadoCards(
              listaCampos: listaCampos,
              listaCultivoEtapas: listaCultivoEtapas,
              listaCultivos: listaCultivos,
              listaEtapas: listaEtapas,
              listaRiego: listaRiego,
              listaPorcentajeHoras: listaPorcentajeHoras,
              listaTiempo: listaTiempo,
              listaKc: listaKc,
            );
          }
          return SpinKitRotatingCircle(color: Color(0xFF4CA6CA), size: 50.0);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: ()  {
          setState(() async {
            listaCampos = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AltaUI(listaCampos: listaCampos,)));
          });
        },
      ),
    );
  }

  Widget elegirAccion(String eleccion) {
    if (eleccion == 'Alta') {}
    if (eleccion == 'Copia de seguridad') {
      print('copia de seguridad');
    }
  }
}

class ListadoCards extends StatefulWidget {
  List<Campo> listaCampos;
  List<CultivoEtapas> listaCultivoEtapas;
  List<Cultivo> listaCultivos;
  List<Riego> listaRiego;
  List<Etapa> listaEtapas;
  List<double> listaPorcentajeHoras;
  List<Tiempo> listaTiempo;
  var listaKc;

  ListadoCards(
      {this.listaCampos,
      this.listaCultivoEtapas,
      this.listaCultivos,
      this.listaRiego,
      this.listaEtapas,
      this.listaPorcentajeHoras,
      this.listaTiempo,
      this.listaKc});

  @override
  _ListadoCards createState() {
    return _ListadoCards(
        listaCampos: listaCampos,
        listaCultivoEtapas: listaCultivoEtapas,
        listaCultivos: listaCultivos,
        listaEtapas: listaEtapas,
        listaRiego: listaRiego,
        listaPorcentajeHoras: listaPorcentajeHoras,
        listaTiempo: listaTiempo,
        listaKc: listaKc);
  }
}

class _ListadoCards extends State<ListadoCards> {
  Logger logger = new Logger();
  List<Campo> listaCampos;
  List<CultivoEtapas> listaCultivoEtapas;
  List<CultivoEtapas> listaCultivoEtapasIdCultivo;
  List<Cultivo> listaCultivos;
  List<Riego> listaRiego;
  List<Etapa> listaEtapas;
  List<double> listaPorcentajeHoras;
  List<Tiempo> listaTiempo;
  var listaKc;

  _ListadoCards(
      {this.listaCampos,
      this.listaCultivoEtapas,
      this.listaCultivos,
      this.listaRiego,
      this.listaEtapas,
      this.listaPorcentajeHoras,
      this.listaTiempo,
      this.listaKc});

  @override
  Widget build(BuildContext context) {
    if (listaCampos.length == 0) {
      return Center(
        child: Text(
            'Para introducir un campo pulse sobre el icono con el icono +'),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(32.0),
      itemCount: listaCampos.length,
      itemBuilder: (BuildContext context, index) {
        return Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () async {
              listaCultivoEtapasIdCultivo = [];
              listaCultivoEtapasIdCultivo =
                  await DatabaseHelper.listaCultivosEtapasFromIdCultivo(
                      listaCampos[index].idCultivo);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DetalleUI(
                    listaCampos[index],
                    listaCultivos[listaCampos[index].idCultivo - 1],
                    listaRiego[listaCampos[index].idRiego - 1],
                    listaEtapas,
                    listaCultivoEtapas,
                    listaCampos,
                  ),
                ),
              );
            },
            onLongPress: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                        title: Text('Eliminar campo'),
                        content: Text('Se va a eliminar el campo ' +
                            listaCampos[index].nombre),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Cancelar'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text('Eliminar'),
                            onPressed: () {
                              DatabaseHelper.deleteCampo(
                                  listaCampos[index].idCampo);
                              setState((){
                                listaCampos.removeAt(index);
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ));
            },
            child: Container(
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      new Image.asset('images/' +
                          listaCultivos[listaCampos[index].idCultivo - 1]
                              .tipo
                              .replaceAll('á', 'a')
                              .replaceAll('é', 'e')
                              .replaceAll('í', 'i')
                              .replaceAll('ú', 'u')
                              .replaceAll('ó', 'o')
                              .replaceAll('ñ', 'n')
                              .toLowerCase() +
                          '.jpg'),
                      new Text(
                        ' ' +
                            listaCampos[index].nombre +
                            ' \u2022 ' +
                            listaCultivos[listaCampos[index].idCultivo - 1]
                                .tipo,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                    alignment: Alignment.bottomLeft,
                  ),
                  new Text(
                    'Necesidad hídrica: ' +
                        NecesidadHidrica.calcularNecesidadHidrica(
                                listaPorcentajeHoras[index],
                                listaKc[listaCultivos[index].idCultivo]
                                    [listaEtapas[index].idEtapa],
                                listaCampos[index].eficiencia,
                                listaTiempo[index].data[0].temp,
                                listaTiempo[index].data[0].precip)
                            .toStringAsPrecision(2) +
                        'm3/ha',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  new Text(
                    'Tipo de riego: ' +
                        listaRiego[listaCampos[index].idRiego - 1].tipo,
                    style: TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
