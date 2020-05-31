import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:logger/logger.dart';

class Mapa extends StatefulWidget {
  @override
  _Mapa createState() => _Mapa();
}

class _Mapa extends State<Mapa> {
  Logger logger = new Logger();
  String buscarDireccion;
  Position position;
  CameraPosition _initialPosition = CameraPosition(target: LatLng(0.0, 0.0));
  Completer<GoogleMapController> _controller = Completer();
  Widget _child;
  Marker _marcador;
  final Set<Marker> _marcadores = Set();
  final controladorBusqueda = TextEditingController();

  @override
  void initState() {
    _child = SpinKitRotatingCircle(
      color: Color(0xFF4CA6CA),
      size: 50.0,
    );
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    Position res = await Geolocator().getCurrentPosition();

    final MarkerId markerId = MarkerId("Campo");
    Marker marcador = Marker(
      markerId: markerId,
      draggable: true,
      position: LatLng(res.latitude, res.longitude),
    );

    setState(() {
      _marcadores.add(marcador);
      _marcador = marcador;
      position = res;
      _child = widgetMapa();
    });

    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(res.latitude, res.longitude), 17.0));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Future anadirMarcador(LatLng latLng) async {
    setState(() {
      final MarkerId markerId = MarkerId("Campo");
      Marker marcador = Marker(
        markerId: markerId,
        position: latLng,
      );
      _marcadores.add(marcador);
      _marcador = marcador;
      _child = widgetMapa();
    });

    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(latLng.latitude, latLng.longitude), 17.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.grey,
            ),
            onPressed: () {
              Navigator.pop(context,
                  [_marcador.position.latitude, _marcador.position.longitude]);
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          _child,
          Positioned(
            top: 30.0,
            right: 15.0,
            left: 15.0,
            child: Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
              ),
              child: TextField(
                controller: controladorBusqueda,
                onSubmitted: (value) {
                  buscaryNavegar();
                },
                onTap: () async {
                  controladorBusqueda.clear();
                  Prediction p = await PlacesAutocomplete.show(
                    context: context,
                    apiKey: "AIzaSyC1GE5eJz2fi_GZue4TOpSJFGithuGrzqg",
                    language: "es",
                    components: [
                      Component(Component.country, "es"),
                    ],
                  );
                  if (p != null) {
                    buscarDireccion = p.description;
                    controladorBusqueda.text = p.description;
                  } else {
                    controladorBusqueda.text = null;
                  }
                },
                textInputAction: TextInputAction.go,
                decoration: InputDecoration(
                  hintText: 'Busque su campo',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: buscaryNavegar,
                    iconSize: 30.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: getCurrentLocation,
        label: Text('Mi Ubicación'),
        icon: Icon(Icons.location_on),
      ),
    );
  }

  buscaryNavegar() {
    Geolocator().placemarkFromAddress(buscarDireccion).then(
      (value) async {
        GoogleMapController controller = await _controller.future;
        final MarkerId markerId = MarkerId("Campo");
        LatLng latLng =
            new LatLng(value[0].position.latitude, value[0].position.longitude);
        anadirMarcador(latLng);
        controller.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(value[0].position.latitude, value[0].position.longitude),
            17.0));
      },
    );
  }

  Widget widgetMapa() {
    return GoogleMap(
      mapType: MapType.hybrid,
      myLocationEnabled: true,
      mapToolbarEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      onMapCreated: _onMapCreated,
      markers: _marcadores,
      initialCameraPosition: _initialPosition,
      onLongPress: (LatLng) {
        anadirMarcador(LatLng);
      },
    );
  }
}

class MapaDetalle extends StatefulWidget {
  double lat;
  double lon;

  MapaDetalle({this.lat, this.lon});

  @override
  _MapaDetalle createState() => _MapaDetalle(lat: lat, lon: lon);
}

class _MapaDetalle extends State<MapaDetalle> {
  double lat;
  double lon;

  _MapaDetalle({this.lat, this.lon});

  @override
  void initState() {
    _child = SpinKitRotatingCircle(
      color: Color(0xFF4CA6CA),
      size: 50.0,
    );
    getMarkerLocation(lat, lon);
  }


  Completer<GoogleMapController> _controller = Completer();
  Widget _child;
  Marker _marcador;
  Position position;
  final Set<Marker> _marcadores = Set();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: _child,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: getCurrentLocation,
        label: Text('Mi Ubicación'),
        icon: Icon(Icons.location_on),
      ),
    );
  }

  Widget widgetMapa() {
    return GoogleMap(
      mapType: MapType.hybrid,
      myLocationEnabled: true,
      mapToolbarEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      onMapCreated: _onMapCreated,
      markers: _marcadores,
      initialCameraPosition: new CameraPosition(target: new LatLng(lat, lon)),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    LatLng latLng = new LatLng(lat, lon);
    anadirMarcador(latLng);
  }

  void getCurrentLocation() async {
    Position res = await Geolocator().getCurrentPosition();
    setState(() {
      position = res;
      _child = widgetMapa();
    });

    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(res.latitude, res.longitude), 17.0));
  }

  void getMarkerLocation(double lat, double lon) async {
    final MarkerId markerId = MarkerId("Campo");
    Marker marcador = Marker(
      markerId: markerId,
      draggable: true,
      position: LatLng(lat, lon),
    );

    setState(() {
      _marcadores.add(marcador);
      _marcador = marcador;
      position = new Position(altitude: lat, longitude: lon);
      _child = widgetMapa();
    });

    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lon), 17.0));
  }

  Future anadirMarcador(LatLng latLng) async {
    setState(() {
      final MarkerId markerId = MarkerId("Campo");
      Marker marcador = Marker(
        markerId: markerId,
        position: latLng,
      );
      _marcadores.add(marcador);
      _marcador = marcador;
      _child = widgetMapa();
    });
  }
}