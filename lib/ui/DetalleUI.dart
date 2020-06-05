/**
 * Ventana que muestra la ventana de detalle
 */

import 'package:HidroCrop/controller/DatabaseHelper.dart';
import 'package:HidroCrop/controller/NecesidadHidrica.dart';
import 'package:HidroCrop/dao/Campo.dart';
import 'package:HidroCrop/dao/Cultivo.dart';
import 'package:HidroCrop/dao/CultivoEtapas.dart';
import 'package:HidroCrop/dao/Etapa.dart';
import 'package:HidroCrop/dao/Riego.dart';
import 'package:HidroCrop/dao/Tiempo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:HidroCrop/ui/ModificarUI.dart';
import 'Mapa.dart';

class DetalleUI extends StatefulWidget {
  Campo campo;
  Cultivo cultivo;
  Riego riego;
  List<Etapa> listaEtapas;
  List<CultivoEtapas> listaCultivoEtapas;
  List<Campo> listaCampos;
  double porcentajeHoras;
  Tiempo tiempo;
  var listaKc;
  int idEtapa;
  int posicionCampo;
  DetalleUI(this.campo, this.cultivo, this.riego, this.listaEtapas,
      this.listaCultivoEtapas, this.listaCampos, this.porcentajeHoras, this.tiempo, this.listaKc, this.idEtapa, this.posicionCampo);

  @override
  _DetalleUI createState() => _DetalleUI(
      campo, cultivo, riego, listaEtapas, listaCultivoEtapas, listaCampos, porcentajeHoras, tiempo, listaKc, idEtapa, posicionCampo);
}

class _DetalleUI extends State<DetalleUI> {
  List<Campo> listaCampos;
  Campo campo;
  Cultivo cultivo;
  Riego riego;
  List<Etapa> listaEtapas;
  List<CultivoEtapas> listaCultivoEtapas;
  double porcentajeHoras;
  Tiempo tiempo;
  var listaKc;
  int idEtapa;
  int posicionCampo;
  _DetalleUI(this.campo, this.cultivo, this.riego, this.listaEtapas,
      this.listaCultivoEtapas, this.listaCampos, this.porcentajeHoras, this.tiempo, this.listaKc, this.idEtapa, this.posicionCampo);

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    _onWillPop(){
      Navigator.pop(context, listaCampos);
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Image.asset('images/appbar.png', height: 70),
            centerTitle: true,
            leading: new IconButton(
              icon: new Icon(
                Icons.arrow_back,
                color: Colors.grey,
              ),
              onPressed: () => Navigator.pop(context, listaCampos),
            ),
            actions: <Widget>[
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                ),
                onSelected: elegirAccion,
                itemBuilder: (BuildContext context) {
                  return Elecciones.eleccionesDetalle.map((String eleccion) {
                    return PopupMenuItem<String>(
                      value: eleccion,
                      child: Text(eleccion),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          body: ListView(
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
                      'D.png'),
                  Text(
                    '   ' + campo.nombre + ' \u2022 ' + cultivo.tipo,
                    style: TextStyle(
                        color: Color(0xFF4CA6CA),
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ],
                alignment: Alignment.bottomLeft,
              ),
              Center(
                child: Container(
                    margin: const EdgeInsets.all(10.0),
                    width: 300.0,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(10.0),
                          width: 250.0,
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text('Riego: ', style: TextStyle(
                                      color: Color(0xFF4CA6CA),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0),),
                                  Expanded(
                                    child: Text(riego.tipo, style: TextStyle(fontSize: 16.0)),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text('Eficiencia: ', style: TextStyle(
                                      color: Color(0xFF4CA6CA),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                                  Expanded(
                                    child: Text(campo.eficiencia.toString(), style: TextStyle(fontSize: 16.0)),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text('Fecha de siembra: ', style: TextStyle(
                                      color: Color(0xFF4CA6CA),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                                  Expanded(
                                    child: Text(campo.fecha_siembra.toString(), style: TextStyle(fontSize: 16.0)),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text('Etapa: ', style: TextStyle(
                                      color: Color(0xFF4CA6CA),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                                  Expanded(
                                    child: Text(getEtapa(), style: TextStyle(fontSize: 16.0)),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text('Proxima etapa: ', style: TextStyle(
                                      color: Color(0xFF4CA6CA),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                                  Expanded(
                                    child: Text(proximaEtapa(), style: TextStyle(fontSize: 16.0)),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text('Días para la próxima etapa: ', style: TextStyle(
                                      color: Color(0xFF4CA6CA),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                                  Expanded(
                                    child: Text(diasProximaEtapa().toString(), style: TextStyle(fontSize: 16.0)),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text('Coeficiente del cultivo (kc): ', style: TextStyle(
                                      color: Color(0xFF4CA6CA),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                                  Expanded(
                                    child: Text(listaCultivoEtapas[0].kc.toString(), style: TextStyle(fontSize: 16.0)),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text('Necesidad hídrica: ', style: TextStyle(
                                      color: Color(0xFF4CA6CA),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                                  Expanded(
                                    child: Text(NecesidadHidrica.calcularNecesidadHidrica(
                                        porcentajeHoras,
                                        listaKc[cultivo.idCultivo - 1][idEtapa],
                                        campo.eficiencia,
                                        tiempo.data[0].temp,
                                        tiempo.data[0].precip).toStringAsPrecision(2) + 'm3/ha', style: TextStyle(fontSize: 16.0),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text('Temperatura media: ', style: TextStyle(
                                      color: Color(0xFF4CA6CA),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                                  Expanded(
                                    child: Text(tiempo.data[0].temp.toString() + 'ºC', style: TextStyle(fontSize: 16.0),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text('Precipitación: ', style: TextStyle(
                                      color: Color(0xFF4CA6CA),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0)),
                                  Expanded(
                                    child: Text(tiempo.data[0].precip.toString() + 'l/m2', style: TextStyle(fontSize: 16.0),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          children: <Widget>[
                            new SpinKitRotatingCircle(
                                color: Color(0xFF4CA6CA), size: 50.0),
                            new InkWell(
                              child: Center(
                                child: Image.network('https://maps.googleapis.com/maps/api/staticmap?xzoom=13&size=350x250&maptype=hybrid' +
                                    '&markers=color:red%7C' + campo.latitud.toString() + ',' + campo.longitud.toString() +
                                    '&language=es&key=AIzaSyC244R2LmHrvjTO65WoaVEi7n2ZUgRIJKQ',),
                              ),
                              onTap: () async {
                                await Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => MapaDetalle(lat: campo.latitud, lon: campo.longitud,)));
                              },
                            ),
                          ],
                        ),
                      ],
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getEtapa() {
    DateTime siembra = DateTime.parse(campo.fecha_siembra);
    if (listaCultivoEtapas != null) {
      DateTime primeraEtapa =
          siembra.add(new Duration(days: listaCultivoEtapas[1].duracion));
      DateTime segundaEtapa =
          primeraEtapa.add(new Duration(days: listaCultivoEtapas[2].duracion));
      DateTime terceraEtapa =
          segundaEtapa.add(new Duration(days: listaCultivoEtapas[3].duracion));
      if (DateTime.now().isBefore(primeraEtapa)) {
        return listaEtapas[listaCultivoEtapas[0].idEtapa - 1].nombre;
      }
      if (DateTime.now().isBefore(segundaEtapa)) {
        return listaEtapas[listaCultivoEtapas[1].idEtapa - 1].nombre;
      }
      if (DateTime.now().isBefore(terceraEtapa)) {
        return listaEtapas[listaCultivoEtapas[2].idEtapa - 1].nombre;
      }
      if (DateTime.now().isAfter(terceraEtapa)) {
        return listaEtapas[listaCultivoEtapas[3].idEtapa - 1].nombre;
      }
    }
  }

  String proximaEtapa() {
    if (getEtapa() == 'Germinación') {
      return 'Ahijamiento';
    }
    if (getEtapa() == 'Ahijamiento') {
      return 'Gran crecimiento';
    }
    if (getEtapa() == 'Gran crecimiento') {
      return 'Maduración';
    }
    if (getEtapa() == 'Maduración') {
      return ' ';
    }
  }

  int diasProximaEtapa() {
    DateTime siembra = DateTime.parse(campo.fecha_siembra);
    DateTime primeraEtapa =
        siembra.add(new Duration(days: listaCultivoEtapas[1].duracion));
    DateTime segundaEtapa =
        primeraEtapa.add(new Duration(days: listaCultivoEtapas[2].duracion));
    DateTime terceraEtapa =
        segundaEtapa.add(new Duration(days: listaCultivoEtapas[3].duracion));
    if (DateTime.now().isBefore(primeraEtapa)) {
      return primeraEtapa.difference(DateTime.now()).inDays;
    }
    if (DateTime.now().isBefore(segundaEtapa)) {
      return segundaEtapa.difference(DateTime.now()).inDays;
    }
    if (DateTime.now().isBefore(terceraEtapa)) {
      return terceraEtapa.difference(DateTime.now()).inDays;
    }
    if (DateTime.now().isAfter(terceraEtapa)) {
      return 0;
    }
  }

  Future<Widget> elegirAccion(String eleccion) async {
    if (eleccion == 'Editar') {
       await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ModificarUI(
            listaCampos: listaCampos,
            campo: campo,
            cultivo: cultivo.tipo,
            riego: riego,
            posicionCampo: posicionCampo,
          ),
        ),
      ).then((value) {
        setState(() {
          campo = value;
          listaCampos[posicionCampo] = value;
        });
       });
    }
    if (eleccion == 'Eliminar') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Eliminar campo'),
          content: Text('Se va a eliminar el campo ' + campo.nombre),
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
                  listaCampos.removeAt(posicionCampo);
                  Navigator.pop(context, listaCampos);
                  Navigator.pop(context, listaCampos);
                });
              },
            ),
          ],
        ),
      );
    }
  }
}

class Elecciones{
  static const String editar = 'Editar';
  static const String eliminar = 'Eliminar';

  static const List<String> eleccionesDetalle = <String>[
    editar, eliminar
  ];
}
