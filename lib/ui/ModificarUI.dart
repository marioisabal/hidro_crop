/**
 * Ventana que abre el formulario de modificación
 */

import 'package:HidroCrop/controller/DatabaseHelper.dart';
import 'package:HidroCrop/dao/Campo.dart';
import 'package:HidroCrop/dao/Riego.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'Mapa.dart';

class ModificarUI extends StatefulWidget {
  List<Campo> listaCampos;
  Campo campo;
  String cultivo;
  Riego riego;
  int posicionCampo;
  @override
  _ModificarUI createState() => _ModificarUI(listaCampos: listaCampos, campo: campo, cultivo: cultivo, riego: riego, posicionCampo: posicionCampo);

  ModificarUI({@required this.listaCampos, this.campo, this.cultivo, this.riego, this.posicionCampo});
}

class _ModificarUI extends State<ModificarUI> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  List<Campo> listaCampos;
  Campo campo;
  String cultivo;
  Riego riego;
  int posicionCampo;
  _ModificarUI({@required this.listaCampos, this.campo, this.cultivo, this.riego, this.posicionCampo});
  List<DropdownMenuItem<String>> listaCultivos;
  List<DropdownMenuItem<String>> listaRiego;
  List<DropdownMenuItem<String>> listaEficiencia;
  String valorCultivo;
  String valorRiego;
  String valorEficiencia;
  var latlng;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final controladorCampo = TextEditingController();
  final controladorFecha = TextEditingController();
  final controladorUbicacion = TextEditingController();

  @override
  void initState() {
    super.initState();
    controladorCampo.value = TextEditingValue(text: campo.nombre);
    valorCultivo = cultivo;
    valorRiego = riego.tipo;
    valorEficiencia = campo.eficiencia.toString();
    controladorFecha.value = TextEditingValue(text: campo.fecha_siembra);
    controladorUbicacion.value = TextEditingValue(text: campo.latitud.toString() + ', ' + campo.longitud.toString());
    listaCultivos = [];
    listaRiego = [];
    listaEficiencia = [];
    DatabaseHelper.iniciarBD().then((status) {
      if (status) {
        DatabaseHelper.listaRiegos().then((listMap) {
          listMap.map((map) {
            return getDropdownTipoRiego(map);
          }).forEach((dropdownItem) {
            listaRiego.add(dropdownItem);
          });
        });
      }
    });
  }

  @override
  void dispose() {
    controladorCampo.dispose();
    controladorFecha.dispose();
    super.dispose();
  }



  DropdownMenuItem<String> getDropdownTipoRiego(Riego map) {
    return DropdownMenuItem<String>(
      value: map.tipo,
      child: Text(map.tipo),
    );
  }

  DropdownMenuItem<String> getDropdownEficienciaRiego(int num) {
    return DropdownMenuItem<String>(
      value: num.toString(),
      child: Text(num.toString()),
    );
  }

  cargarListaEficiencia(String nuevoRiego) {
    List<int> lista = new List<int>();
    if (nuevoRiego == 'Surcos') {
      lista = Riego.getEficiencia(50, 20);
    } else if (nuevoRiego == 'Fajas') {
      lista = Riego.getEficiencia(60, 15);
    } else if (nuevoRiego == 'Inundación') {
      lista = Riego.getEficiencia(60, 20);
    } else if (nuevoRiego == 'Aspersión') {
      lista = Riego.getEficiencia(65, 20);
    } else if (nuevoRiego == 'Goteo') {
      lista = Riego.getEficiencia(75, 15);
    }
    lista.map((int i) {
      return getDropdownEficienciaRiego(i);
    }).forEach((dropdownItem) {
      listaEficiencia.add(dropdownItem);
    });
    setState(() {});
  }

  double getLatitud() {
    const inicioLongitud = '[';
    const finLongitud = ",";
    final startIndexLongitud = latlng.toString().indexOf(inicioLongitud);
    final finIndexLongitud = latlng
        .toString()
        .indexOf(finLongitud, startIndexLongitud + inicioLongitud.length);
    String longitudS = latlng.toString().substring(
        startIndexLongitud + inicioLongitud.length, finIndexLongitud);
    double longitud = double.parse(longitudS);
    return longitud;
  }

  double getLongitud() {
    const inicioLatitud = ',';
    const finLatitud = "]";
    final startIndexLatitud = latlng.toString().indexOf(inicioLatitud);
    final finIndexLatitud = latlng
        .toString()
        .indexOf(finLatitud, startIndexLatitud + inicioLatitud.length);
    String latitudS = latlng
        .toString()
        .substring(startIndexLatitud + inicioLatitud.length, finIndexLatitud);
    double latitud = double.parse(latitudS);
    return latitud;
  }

  String textUbicacion() {
    var ubicacion = campo.latitud.toString() + '\n' + campo.longitud.toString();
    return ubicacion;
  }

  @override
  Widget build(BuildContext context) {
    DateTime _fecha;
    String ubicacion = textUbicacion();

    _onWillPop(){
      Navigator.pop(context, campo);
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: MaterialApp(
          home: Scaffold(
            key: _scaffoldKey,
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Image.asset('images/appbar.png', height: 70),
              centerTitle: true,
              leading: new IconButton(
                icon: new Icon(
                  Icons.arrow_back,
                  color: Colors.grey,
                ),
                onPressed: () => Navigator.pop(context, campo),
              ),
            ),
            body: FormBuilder(
              key: _fbKey,
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('MODIFICAR CAMPO', style: TextStyle(fontSize: 20, color: Color(0xFF4CA6CA), fontWeight: FontWeight.bold),),
                    SizedBox(
                      height: 16.0,
                    ),
                    FormBuilderTextField(
                      controller: controladorCampo,
                      decoration: InputDecoration(
                        labelText: 'Campo',
                        hintText: "Nombre del campo",
                        enabled: false,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: <Widget>[
                        Text('Cultivo'),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: FormBuilderDropdown(
                            readOnly: true,
                            hint: Text(valorCultivo),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 16.0),
                    FormBuilderTextField(
                      controller: controladorFecha,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Fecha de siembra',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: <Widget>[
                        Text('Tipo de riego'),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: FormBuilderDropdown(
                            attribute: valorRiego,
                            initialValue: valorRiego,
                            onChanged: (newValue) {
                              setState(() {
                                valorRiego = newValue;
                                listaEficiencia.clear();
                                valorEficiencia = null;
                                cargarListaEficiencia(newValue);
                              });
                            },
                            hint: Text('Seleccionar riego'),
                            items: listaRiego,
                            validators: [FormBuilderValidators.required(errorText: 'Seleccione el tipo de riego')],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 16.0),
                    if (valorRiego != null)
                      Row(
                        children: <Widget>[
                          Text('Eficiencia'),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: FormBuilderDropdown(
                              attribute: valorEficiencia,
                              onChanged: (newValue) {
                                setState(() {
                                  valorEficiencia = newValue;
                                });
                              },
                              initialValue: campo.eficiencia.toStringAsFixed(0),
                              hint: Text('Seleccionar eficiencia'),
                              items: listaEficiencia,
                              validators: [FormBuilderValidators.required(errorText: 'Seleccione un porcentaje de eficiencia')],
                            ),
                          )
                        ],
                      ),
                    SizedBox(height: 16.0),
                    Row(
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () async {
                            latlng = await Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => MapaDetalle(lat: campo.latitud, lon:  campo.longitud,)));
                          },
                          child: Text('UBICACIÓN'),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: FormBuilderTextField(
                            readOnly: true,
                            decoration: InputDecoration(labelText: ubicacion, hintText: 'Seleccione la ubicación'),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () {
                            _fbKey.currentState.reset();
                          },
                          child: Text('LIMPIAR'),
                        ),
                        SizedBox(width: 32.0),
                        RaisedButton(
                          color: Color(0xFF4CA6CA),
                          onPressed: () async {
                            // devolverá true si el formulario es válido, o falso si
                            // el formulario no es válido.

                            if (_fbKey.currentState.saveAndValidate()) {
                              // Si el formulario es válido, se muestra un snackbar
                              final snackBar =
                              SnackBar(content: Text('Formulario válido'));
                              _scaffoldKey.currentState.showSnackBar(snackBar);
                              //Se realiza el alta de un campo
                              var idRiego =
                              await DatabaseHelper.getIdRiego(valorRiego);
                              Campo campoModificado = new Campo(
                                idCampo: campo.idCampo,
                                nombre: controladorCampo.text,
                                fecha_siembra: campo.fecha_siembra,
                                longitud: campo.latitud,
                                latitud: campo.longitud,
                                eficiencia: double.parse(valorEficiencia),
                                idRiego: idRiego,
                                idCultivo: campo.idCultivo,
                              );
                              print(campo.idCampo.toString() +
                                  ' ' +
                                  campo.nombre +
                                  ' ' +
                                  campo.idCultivo.toString() +
                                  ' ' +
                                  valorCultivo +
                                  ' ' +
                                  campo.idRiego.toString() +
                                  valorRiego +
                                  ' ');
                              DatabaseHelper.updateCampo(campoModificado, campo.idCampo);
                              Navigator.pop(context, campoModificado);
                            }
                          },
                          child: Text(
                            'MODIFICAR',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
