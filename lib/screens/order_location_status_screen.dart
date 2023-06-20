import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/order.dart';
import 'package:foodtogo_customers/services/online_shipper_status_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderLocationStatusScreen extends StatefulWidget {
  const OrderLocationStatusScreen({
    super.key,
    required this.order,
  });

  final Order order;

  @override
  State<OrderLocationStatusScreen> createState() =>
      _OrderLocationStatusScreenState();
}

class _OrderLocationStatusScreenState extends State<OrderLocationStatusScreen> {
  LatLng? _shipperLocation;
  LatLng? _deliveryLocation;
  LatLng? _merchantLocation;

  BitmapDescriptor? _shipperIcon;
  BitmapDescriptor? _customerIcon;
  BitmapDescriptor? _merchantIcon;

  bool _isInilizingComplete = false;

  Timer? _initTimer;

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
    }
  ]
  ''';

  _loadShipperLocation() async {
    LatLng? shipperLocation;
    if (widget.order.shipper != null) {
      final onlineShipperStatusServices = OnlineShipperStatusServices();

      final onlineShipperStatusDTO = await onlineShipperStatusServices
          .getDTO(widget.order.shipper!.userId);
      if (onlineShipperStatusDTO != null) {
        shipperLocation = LatLng(
          onlineShipperStatusDTO.geoLatitude,
          onlineShipperStatusDTO.geoLongitude,
        );
      }
    }

    if (mounted) {
      setState(() {
        _shipperLocation = shipperLocation;
      });
    }
  }

  _loadMarkerIcon() async {
    final shipperIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.5),
      'assets/images/shipper.png', // Replace with the path to your asset
    );

    final merchantIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.5),
      'assets/images/merchant.png', // Replace with the path to your asset
    );

    final customerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.5),
      'assets/images/user.png', // Replace with the path to your asset
    );

    setState(() {
      _shipperIcon = shipperIcon;
      _merchantIcon = merchantIcon;
      _customerIcon = customerIcon;
    });
  }

  _initialize() async {
    if (mounted) {
      setState(() {
        _isInilizingComplete = false;
      });
    }
    _loadMarkerIcon();
    _loadShipperLocation();

    if (mounted) {
      setState(() {
        _isInilizingComplete = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _initialize();
      _initTimer?.cancel();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deliveryLocation = LatLng(
      widget.order.deliveryLatitude,
      widget.order.deliveryLongitude,
    );
    _merchantLocation = LatLng(
      widget.order.merchant.geoLatitude,
      widget.order.merchant.geoLongitude,
    );

    Widget bodyContent = const Center(
      child: CircularProgressIndicator.adaptive(),
    );

    if (_isInilizingComplete) {
      bodyContent = GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _shipperLocation ?? _merchantLocation!,
          zoom: 15,
        ),
        markers: {
          if (_shipperLocation != null)
            Marker(
              markerId: const MarkerId('shipper'),
              position: _shipperLocation!,
              infoWindow: const InfoWindow(title: 'Shipper'),
              icon: _shipperIcon ?? BitmapDescriptor.defaultMarker,
              zIndex: 1.0,
            ),
          Marker(
            markerId: const MarkerId('customer'),
            position: _deliveryLocation!,
            infoWindow: const InfoWindow(title: 'Customer'),
            icon: _customerIcon ?? BitmapDescriptor.defaultMarker,
          ),
          Marker(
            markerId: const MarkerId('merchant'),
            position: _merchantLocation!,
            infoWindow: const InfoWindow(title: 'Merchant'),
            icon: _merchantIcon ?? BitmapDescriptor.defaultMarker,
          ),
        },
        buildingsEnabled: false,
        onMapCreated: (controller) {
          controller.setMapStyle(_mapStyle);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Back to order details'),
      ),
      body: bodyContent,
    );
  }
}
