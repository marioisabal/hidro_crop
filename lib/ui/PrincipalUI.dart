/**
 * Ventana principal de la aplicación
 * Se muestran listados los campos que están guardados en la base de datos.
 * Contiene el método main del proyecto.
 */

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
import 'package:HidroCrop/ui/DetalleUI.dart';
import 'package:connection_status_bar/connection_status_bar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'AltaUI.dart';

void main() => runApp(new PrincipalUI());

class PrincipalUI extends StatelessWidget {
  List<Campo> listaCampos;

  PrincipalUI({this.listaCampos});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(accentColor: Color(0xFF4CA6CA), fontFamily: 'Roboto'),
      home: PrincipalUIState(
        listaCampos: listaCampos,
      ),
    );
  }
// Pantalla principal de la aplicación
}

class PrincipalUIState extends StatefulWidget {
  List<Campo> listaCampos;

  PrincipalUIState({this.listaCampos});

  @override
  _PrincipalUIState createState() {
    return _PrincipalUIState(listaCampos: listaCampos);
  }
}

class _PrincipalUIState extends State<PrincipalUIState> {
  var logger = Logger();

  ConnectivityResult connectivityResult;
  List<Campo> listaCampos;
  List<Cultivo> listaCultivos;
  List<Riego> listaRiego;
  List<Etapa> listaEtapas;
  List<double> listaPorcentajeHoras;
  List<CultivoEtapas> listaCultivoEtapas;
  Future<String> _getListas;
  List<Tiempo> listaTiempo;
  var listaKc;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _PrincipalUIState({this.listaCampos, this.connectivityResult});

  @override
  void initState() {
    super.initState();
    _getListas = cargarListas();
  }

  _comprobarConexionInternet() async {
    await Connectivity().checkConnectivity().then((value) {
      if (value == ConnectivityResult.none) {
        setState(() {
          connectivityResult = value;
        });
      } else if (value == ConnectivityResult.wifi) {
        setState(() {
          connectivityResult = value;
        });
      } else if (value == ConnectivityResult.mobile) {
        setState(() {
          connectivityResult = value;
        });
      }
    });
  }

  Future<String> cargarListas() async {
    logger.i('#### START cargarListas()');
    listaCampos = [];
    listaCultivos = [];
    listaRiego = [];
    listaEtapas = [];
    listaPorcentajeHoras = [];
    listaTiempo = [];
    listaCultivoEtapas = [];
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
            }).forEach((cultivoEtapa) {
              setState(() {
                listaCultivoEtapas.add(cultivoEtapa);
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
    /*_comprobarConexionInternet();
    if(connectivityResult == ConnectivityResult.none){
      return Scaffold(
        appBar: AppBar(
          title: Image.asset('images/appbar.png', height: 70),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: SpinKitRotatingCircle(
          color: Color(0xFF4CA6CA), size: 50.0),
      );

    }*/
    return Scaffold(
      key: _scaffoldKey,
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
              final snackBar =
                  SnackBar(content: Text('Copia de seguridad no implementada'));
              _scaffoldKey.currentState.showSnackBar(snackBar);
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder(
            future: _getListas,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == 'OK') {
                return ListadoCards(
                  listaCampos: listaCampos,
                  listaCultivos: listaCultivos,
                  listaEtapas: listaEtapas,
                  listaRiego: listaRiego,
                  listaPorcentajeHoras: listaPorcentajeHoras,
                  listaTiempo: listaTiempo,
                  listaKc: listaKc,
                  listaCultivoEtapas: listaCultivoEtapas,
                );
              }
              return SpinKitRotatingCircle(
                  color: Color(0xFF4CA6CA), size: 50.0);
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConnectionStatusBar(
              height: 25.0,
              width: double.maxFinite,
              color: Colors.redAccent,
              lookUpAddress: 'google.com',
              endOffset: const Offset(0.0, 0.0),
              beginOffset: const Offset(0.0, -1.0),
              animationDuration: const Duration(milliseconds: 200),
              title: const Text(
                'Revise su conexión a internet',
                style: TextStyle(color: Colors.white, fontSize: 14.0),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          setState(() async {
             Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AltaUI(listaCampos: listaCampos,),
              ),
            ).then((value) {
              setState(() {
                listaCampos = value;
                listaTiempo = [];
                for(int i = 0; i < listaCampos.length; i++){
                  TiempoController.fetchTiempo(http.Client(),
                      listaCampos[i].latitud, listaCampos[i].longitud)
                      .then((value) {
                    setState(() {
                      listaTiempo.add(value);
                    });
                  });
                }
              });
             });
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
  List<Cultivo> listaCultivos;
  List<Riego> listaRiego;
  List<Etapa> listaEtapas;
  List<double> listaPorcentajeHoras;
  List<Tiempo> listaTiempo;
  List<CultivoEtapas> listaCultivoEtapas;
  var listaKc;

  ListadoCards(
      {this.listaCampos,
      this.listaCultivos,
      this.listaRiego,
      this.listaEtapas,
      this.listaPorcentajeHoras,
      this.listaTiempo,
      this.listaKc,
      this.listaCultivoEtapas});

  @override
  _ListadoCards createState() {
    return _ListadoCards(
        listaCampos: listaCampos,
        listaCultivos: listaCultivos,
        listaEtapas: listaEtapas,
        listaRiego: listaRiego,
        listaPorcentajeHoras: listaPorcentajeHoras,
        listaTiempo: listaTiempo,
        listaKc: listaKc,
        listaCultivoEtapas: listaCultivoEtapas);
  }
}

class _ListadoCards extends State<ListadoCards> {
  Logger logger = new Logger();
  List<Campo> listaCampos;
  List<CultivoEtapas> listaCultivoEtapas;
  List<Cultivo> listaCultivos;
  List<Riego> listaRiego;
  List<Etapa> listaEtapas;
  List<double> listaPorcentajeHoras;
  List<Tiempo> listaTiempo;
  List<CultivoEtapas> listaCultivoEtapasIdCultivo;
  List<CultivoEtapas> listaFiltrada;
  var listaKc;

  _ListadoCards(
      {this.listaCampos,
      this.listaCultivos,
      this.listaRiego,
      this.listaEtapas,
      this.listaPorcentajeHoras,
      this.listaTiempo,
      this.listaKc,
      this.listaCultivoEtapas});

  @override
  Widget build(BuildContext context) {
    if (listaCampos.length == 0) {
      return Center(
        child: Text(
            'Para introducir un campo pulse sobre el botón con el icono +'),
      );
    }

    getListaCultivoEtapasFiltrada(int idCultivo) {
      listaFiltrada = [];
      listaCultivoEtapas.forEach((element) {
        if (element.idCultivo == idCultivo) {
          listaFiltrada.add(element);
        }
      });
      logger.d('LISTA FILTRADA: ' +
          listaFiltrada.length.toString() +
          '\n idCultivo: ' +
          listaFiltrada[3].idCultivo.toString() +
          '\n idEtapa: ' +
          listaFiltrada[3].idEtapa.toString());
    }

    int getEtapa(int idCultivo, String fecha) {
      logger.d('idCultivo: ' + idCultivo.toString() + '\n fecha: ' + fecha);
      getListaCultivoEtapasFiltrada(idCultivo);
      DateTime siembra = DateTime.parse(fecha);
      if (listaFiltrada != null) {
        DateTime primeraEtapa =
            siembra.add(new Duration(days: listaFiltrada[1].duracion));
        DateTime segundaEtapa =
            primeraEtapa.add(new Duration(days: listaFiltrada[2].duracion));
        DateTime terceraEtapa =
            segundaEtapa.add(new Duration(days: listaFiltrada[3].duracion));
        if (DateTime.now().isBefore(primeraEtapa)) {
          return 0;
        }
        if (DateTime.now().isBefore(segundaEtapa)) {
          return 1;
        }
        if (DateTime.now().isBefore(terceraEtapa)) {
          return 2;
        }
        if (DateTime.now().isAfter(terceraEtapa)) {
          return 3;
        }
      }
    }

    return ListView.builder(
      padding: EdgeInsets.all(32.0),
      itemCount: listaCampos.length,
      itemBuilder: (BuildContext context, index) {
        Campo campo = listaCampos[index];
        Cultivo cultivo = listaCultivos[campo.idCultivo - 1];
        Tiempo tiempo = listaTiempo[index];
        Riego riego = listaRiego[campo.idRiego - 1];
        double horas = listaPorcentajeHoras[index];
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
                    campo,
                    cultivo,
                    riego,
                    listaEtapas,
                    listaCultivoEtapas,
                    listaCampos,
                    horas,
                    tiempo,
                    listaKc,
                    getEtapa(cultivo.idCultivo - 1, campo.fecha_siembra),
                    index
                  ),
                ),
              ).then((value) {
                setState(() {
                  listaCampos = value;
                });
              });
            },
            onLongPress: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                        title: Text('Eliminar campo'),
                        content:
                            Text('Se va a eliminar el campo ' + campo.nombre),
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
                              DatabaseHelper.deleteCampo(campo.idCampo);
                              setState(() {
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
                          cultivo.tipo
                              .replaceAll('á', 'a')
                              .replaceAll('é', 'e')
                              .replaceAll('í', 'i')
                              .replaceAll('ú', 'u')
                              .replaceAll('ó', 'o')
                              .replaceAll('ñ', 'n')
                              .toLowerCase() +
                          '.jpg'),
                      new Text(
                        ' ' + campo.nombre + ' \u2022 ' + cultivo.tipo,
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
                                horas,
                                listaKc[cultivo.idCultivo - 1][getEtapa(
                                    cultivo.idCultivo - 1,
                                    campo.fecha_siembra)],
                                campo.eficiencia,
                                tiempo.data[0].temp,
                                tiempo.data[0].precip)
                            .toStringAsPrecision(2) +
                        'm3/ha',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  new Text(
                    'Tipo de riego: ' +
                        listaRiego[(listaCampos[index].idRiego) - 1].tipo,
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
