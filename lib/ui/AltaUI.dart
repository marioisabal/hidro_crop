import 'package:HidroCrop/controller/DatabaseHelper.dart';
import 'package:HidroCrop/dao/Campo.dart';
import 'package:HidroCrop/dao/Cultivo.dart';
import 'package:HidroCrop/dao/Riego.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

import 'Mapa.dart';

class AltaUI extends StatefulWidget {
  List<Campo> listaCampos;
  @override
  _AltaUI createState() => _AltaUI(listaCampos: listaCampos);

  AltaUI({@required this.listaCampos});
}

class _AltaUI extends State<AltaUI> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  List<Campo> listaCampos;

  _AltaUI({@required this.listaCampos});
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
    listaCultivos = [];
    listaRiego = [];
    listaEficiencia = [];
    DatabaseHelper.iniciarBD().then((status) {
      if (status) {
        DatabaseHelper.listaCultivos().then((listMap) {
          listMap.map((map) {
            return getDropdownCultivo(map);
          }).forEach((dropdownItem) {
            listaCultivos.add(dropdownItem);
          });
          setState(() {});
        });
        DatabaseHelper.listaRiegos().then((listMap) {
          listMap.map((map) {
            return getDropdownTipoRiego(map);
          }).forEach((dropdownItem) {
            listaRiego.add(dropdownItem);
          });
          setState(() {});
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

  DropdownMenuItem<String> getDropdownCultivo(Cultivo map) {
    return DropdownMenuItem<String>(
      value: map.tipo,
      child: Text(map.tipo),
    );
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
    String ubicacion;
    if (latlng == null) {
      ubicacion = 'Seleccione la ubicación';
      return null;
    }
    ubicacion = getLatitud().toString() + '\n' + getLongitud().toString();
    return ubicacion;
  }

  @override
  Widget build(BuildContext context) {
    DateTime _fecha;
    String ubicacion = textUbicacion();

    return GestureDetector(
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
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: FormBuilder(
            key: _fbKey,
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('NUEVO CAMPO', style: TextStyle(fontSize: 20, color: Color(0xFF4CA6CA), fontWeight: FontWeight.bold),),
                  SizedBox(
                    height: 16.0,
                  ),
                  FormBuilderTextField(
                    controller: controladorCampo,
                    decoration: InputDecoration(
                      labelText: 'Campo',
                      hintText: "Nombre del campo",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    validators: [
                      FormBuilderValidators.required(errorText: 'Introduzca el nombre del campo'),
                      FormBuilderValidators.maxLength(20, errorText: 'El nombre del campo no puede superar los 20 carácteres')
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: <Widget>[
                      Text('Cultivo'),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: FormBuilderDropdown(
                          attribute: valorCultivo,
                          onChanged: (newValue) {
                            setState(() {
                              valorCultivo = newValue;
                            });
                          },
                          hint: Text('Seleccionar cultivo'),
                          items: listaCultivos,
                          validators: [FormBuilderValidators.required(errorText: 'Seleccione el tipo de cultivo')],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 16.0),
                  FormBuilderDateTimePicker(
                    inputType: InputType.date,
                    controller: controladorFecha,
                    validators: [
                      FormBuilderValidators.required(
                          errorText: 'Introduzca una fecha'),
                    ],
                    format: DateFormat("yyyy-MM-dd"),
                    initialDate: DateTime.now(),
                    decoration: InputDecoration(
                      labelText: 'Fecha de siembra',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    onChanged: (dt) {
                      setState(() => _fecha = dt);
                    },
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: <Widget>[
                      Text('Tipo de riego'),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: FormBuilderDropdown(
                          attribute: valorRiego,
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
                              MaterialPageRoute(builder: (context) => Mapa()));
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
                            var idCultivo =
                                await DatabaseHelper.getIdCultivo(valorCultivo);
                            double longitud = getLongitud();
                            double latitud = getLatitud();
                            Campo campo = new Campo(
                              nombre: controladorCampo.text,
                              fecha_siembra: controladorFecha.text,
                              longitud: longitud,
                              latitud: latitud,
                              eficiencia: double.parse(valorEficiencia),
                              idRiego: idRiego,
                              idCultivo: idCultivo,
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
                            print('ALTA');
                            DatabaseHelper.insertCampo(campo);
                            //Se vuelve a la pantalla principal
                            listaCampos.add(campo);
                            Navigator.pop(context, listaCampos);
                          }
                        },
                        child: Text(
                          'ALTA',
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
    );
  }
}
