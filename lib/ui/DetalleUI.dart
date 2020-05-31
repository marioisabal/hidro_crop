import 'package:HidroCrop/controller/DatabaseHelper.dart';
import 'package:HidroCrop/dao/Campo.dart';
import 'package:HidroCrop/dao/Cultivo.dart';
import 'package:HidroCrop/dao/CultivoEtapas.dart';
import 'package:HidroCrop/dao/Etapa.dart';
import 'package:HidroCrop/dao/Riego.dart';
import 'package:HidroCrop/utils/Constantes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'Mapa.dart';

class DetalleUI extends StatefulWidget {
  Campo campo;
  Cultivo cultivo;
  Riego riego;
  List<Etapa> listaEtapas;
  List<CultivoEtapas> listaCultivoEtapas;
  List<Campo> listaCampos;

  DetalleUI(this.campo, this.cultivo, this.riego, this.listaEtapas,
      this.listaCultivoEtapas, this.listaCampos);

  @override
  _DetalleUI createState() => _DetalleUI(
      campo, cultivo, riego, listaEtapas, listaCultivoEtapas, this.listaCampos);
}

class _DetalleUI extends State<DetalleUI> {
  List<Campo> listaCampos;
  Campo campo;
  Cultivo cultivo;
  Riego riego;
  List<Etapa> listaEtapas;
  List<CultivoEtapas> listaCultivoEtapas;

  _DetalleUI(this.campo, this.cultivo, this.riego, this.listaEtapas,
      this.listaCultivoEtapas, this.listaCampos);


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
              onSelected: elegirAccion,
              itemBuilder: (BuildContext context) {
                return Constantes.eleccionesDetalle.map((String eleccion) {
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
                  ' ' + campo.nombre + ' \u2022 ' + cultivo.tipo,
                  style: TextStyle(
                      color: Color(0xFF4CA6CA),
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
              ],
              alignment: Alignment.bottomLeft,
            ),
            Padding(
              padding: new EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'Riego: ' + riego.tipo,
                    style: TextStyle(fontSize: 20.0),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    'Eficiencia: ' + campo.eficiencia.toString(),
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Text(
                    'Fecha de siembra: ' + campo.fecha_siembra,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Text(
                    'Etapa: ' + getEtapa(),
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Text(
                    'Proxima etapa: ' + proximaEtapa(),
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Text(
                    'Días para la proxima etapa: ' +
                        diasProximaEtapa().toString(),
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Text(
                    'Coeficiente de cultivo (kc): ' +
                        listaCultivoEtapas[0].kc.toString(),
                    style: TextStyle(fontSize: 20.0),
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
              ),
            ),
          ],
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
    } else {
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

  Widget elegirAccion(String eleccion) {
    if (eleccion == 'Editar') {}
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
                listaCampos.remove(campo.idCampo);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }
}
