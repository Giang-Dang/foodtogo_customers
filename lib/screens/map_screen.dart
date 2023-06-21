import 'package:flutter/services.dart';
import 'package:foodtogo_customers/models/place_location.dart';
import 'package:flutter/material.dart';
import 'package:foodtogo_customers/services/location_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.location,
    this.isSelecting = true,
  });

  final PlaceLocation location;
  final bool isSelecting;

  @override
  State<StatefulWidget> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;
  final _searchTextController = TextEditingController();
  final _locationServices = LocationServices();
  GoogleMapController? mapController;
  late bool _isSearching;

  final String _mapStyle = '''
  [
    {
      "featureType": "poi",
      "elementType": "labels",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "transit.station.bus",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    }
  ]
  ''';

  _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onSearchAddressPressed() async {
    if (mounted) {
      setState(() {
        _isSearching = true;
      });
    }

    LatLng? result =
        await _locationServices.getCoordinates(_searchTextController.text);

    if (result == null) {
      _showAlertDialog('Address', 'Cannot find the input address.');
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
      return;
    } else {
      mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: result, zoom: 17)));

      if (mounted) {
        setState(() {
          _isSearching = false;
          _pickedLocation = LatLng(result.latitude, result.longitude);
        });
      }

      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
  }

  @override
  void initState() {
    super.initState();
    _isSearching = false;
  }

  @override
  void dispose() {
    super.dispose();
    _searchTextController.dispose();
    mapController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop(_pickedLocation);
        },
        child: const Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: AppBar(
        title: Text(
          widget.isSelecting ? 'Pick your location' : 'Your location',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: TextFormField(
              controller: _searchTextController,
              decoration: InputDecoration(
                label: const Text('Enter your address'),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 30.0,
                        height: 30.0,
                        child: Center(child: CircularProgressIndicator()))
                    : IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: KColors.kPrimaryColor,
                        ),
                        onPressed: () {
                          _onSearchAddressPressed();
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                if (mounted) {
                  setState(() {
                    controller.setMapStyle(_mapStyle);
                    mapController = controller;
                  });
                }
              },
              onTap: !widget.isSelecting
                  ? null
                  : (position) {
                      if (mounted) {
                        setState(() {
                          _pickedLocation = position;
                        });
                      }
                    },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.location.latitude,
                  widget.location.longitude,
                ),
                zoom: 17,
              ),
              markers: (_pickedLocation == null && widget.isSelecting)
                  ? {}
                  : {
                      Marker(
                        markerId: const MarkerId('m1'),
                        position: _pickedLocation ??
                            LatLng(
                              widget.location.latitude,
                              widget.location.longitude,
                            ),
                      ),
                    },
              buildingsEnabled: false,
            ),
          ),
        ],
      ),
    );
  }
}
