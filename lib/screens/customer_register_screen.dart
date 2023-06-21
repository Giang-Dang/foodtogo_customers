import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/dto/create_dto/customer_create_dto.dart';
import 'package:foodtogo_customers/models/place_location.dart';
import 'package:foodtogo_customers/screens/map_screen.dart';
import 'package:foodtogo_customers/screens/tabs_screen.dart';
import 'package:foodtogo_customers/services/customer_services.dart';
import 'package:foodtogo_customers/services/location_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final int userId;

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final _formCustomerRegisterKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final _userServices = UserServices();

  String? _pickedAddress;

  bool _isRegistering = false;

  _showAlertDialog(String title, String message, void Function() onOkPressed) {
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
                onOkPressed();
              },
            ),
          ],
        );
      },
    );
  }

  _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => MapScreen(
          location: PlaceLocation(
            address: '',
            longitude: UserServices.currentLongitude,
            latitude: UserServices.currentLatitude,
          ),
        ),
      ),
    );

    if (pickedLocation == null) {
      return;
    }

    final locationServices = LocationServices();
    final address = await locationServices.getAddress(
      pickedLocation.latitude,
      pickedLocation.longitude,
    );

    if (mounted) {
      setState(() {
        _pickedAddress = address;
      });
    }
  }

  _onRegisterPressed() async {
    if (widget.userId == 0) {
      log('_onRegisterPressed widget.userId == 0');
      return;
    }

    if (_pickedAddress == null) {
      _showAlertDialog(
        'Location Selection',
        'Please pick your location.',
        () {
          Navigator.of(context).pop();
        },
      );
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
      return;
    }
    if (_formCustomerRegisterKey.currentState!.validate()) {
      if (mounted) {
        setState(() {
          _isRegistering = true;
        });
      }
    }

    if (widget.userId != 0) {
      final customerCreateDTO = CustomerCreateDTO(
          customerId: widget.userId,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          middleName: _middleNameController.text,
          address: _pickedAddress!);

      final customerServices = CustomerServices();

      final customerId = await customerServices.create(customerCreateDTO);

      if (customerId == 0) {
        _showAlertDialog(
          'Sorry',
          'Unable to create your account at the moment. Please try again at a later time.',
          () {
            Navigator.of(context).pop();
          },
        );
        return;
      }

      _showAlertDialog(
        'Success',
        'We have successfully created your account. Let\'s order something to eat.',
        () {
          Navigator.pop(context);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const TabsScreen(),
          ));
        },
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodToGo - Customers'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(35, 15, 40, 30),
        child: Form(
          key: _formCustomerRegisterKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Register',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: KColors.kPrimaryColor,
                      fontSize: 30,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.badge,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        label: Text('Enter your first name'),
                      ),
                      controller: _firstNameController,
                      validator: (value) {
                        if (_userServices.isValidVietnameseName(value)) {
                          return null;
                        }
                        return 'Please enter a valid first name.';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.badge,
                    size: 27,
                    color: KColors.kOnBackgroundColor,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        label: Text('Enter your middle name'),
                      ),
                      controller: _middleNameController,
                      validator: (value) {
                        if (_userServices.isValidVietnameseName(value)) {
                          return null;
                        }
                        return 'Please enter a valid middle name.';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.badge,
                    size: 27,
                    color: KColors.kOnBackgroundColor,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        label: Text('Enter your last name'),
                      ),
                      controller: _lastNameController,
                      validator: (value) {
                        if (_userServices.isValidVietnameseName(value)) {
                          return null;
                        }
                        return 'Please enter a valid last name.';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.pin_drop,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      _pickedAddress == null
                          ? 'Pick your location.'
                          : _pickedAddress!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: _selectOnMap,
                    icon: const Icon(Icons.navigate_next),
                    iconSize: 30,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _onRegisterPressed();
                  },
                  child: _isRegistering
                      ? const CircularProgressIndicator()
                      : const Text('Register'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
