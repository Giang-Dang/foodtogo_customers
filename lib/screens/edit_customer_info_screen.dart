import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/customer.dart';
import 'package:foodtogo_customers/models/dto/update_dto/customer_update_dto.dart';
import 'package:foodtogo_customers/models/dto/update_dto/user_update_dto.dart';
import 'package:foodtogo_customers/models/dto/user_dto.dart';
import 'package:foodtogo_customers/models/place_location.dart';
import 'package:foodtogo_customers/screens/map_screen.dart';
import 'package:foodtogo_customers/services/customer_services.dart';
import 'package:foodtogo_customers/services/location_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/checkout_delivery_address.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EditCustomerInfoScreen extends StatefulWidget {
  const EditCustomerInfoScreen({
    Key? key,
    required this.userDTO,
    required this.customer,
  }) : super(key: key);

  final UserDTO userDTO;
  final Customer customer;

  @override
  State<EditCustomerInfoScreen> createState() => _EditCustomerInfoScreenState();
}

class _EditCustomerInfoScreenState extends State<EditCustomerInfoScreen> {
  final _formEditCustomerInfoKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  late String _address;
  bool _isEditing = false;
  double _userLatitude = UserServices.currentLatitude;
  double _userLongitude = UserServices.currentLongitude;

  Timer? _initTimer;

  late UserDTO _userDTO;
  late Customer _customer;

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

  _getGeoLocation() async {
    final locationServices = LocationServices();

    final geoLocation =
        await locationServices.getCoordinates(_customer.address);

    if (geoLocation == null) {
      log('_getGeoLocation geoLocation == null');
      return;
    }

    _userLatitude = geoLocation.latitude;
    _userLongitude = geoLocation.longitude;

    return;
  }

  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => MapScreen(
          location: PlaceLocation(
            address: '',
            longitude: _userLongitude,
            latitude: _userLatitude,
          ),
        ),
      ),
    );

    if (pickedLocation == null) {
      log('_selectOnMap pickedLocation == null');
      return;
    }

    _userLatitude = pickedLocation.latitude;
    _userLongitude = pickedLocation.longitude;

    await _getAddress(_userLatitude, _userLongitude);
  }

  _getAddress(double latitude, double longitude) async {
    final locationServices = LocationServices();

    final address = await locationServices.getAddress(latitude, longitude);

    if (address != _address) {
      if (mounted) {
        setState(() {
          _address = address;
        });
      }
    }
  }

  bool _isValidEmail(String? email) {
    RegExp validRegex = RegExp(
        r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})+');
    if (email == null) {
      return false;
    }
    return validRegex.hasMatch(email);
  }

  bool _isValidPhoneNumber(String? phoneNumber) {
    // Regular expression pattern to match valid phone numbers
    String pattern =
        r'^(0|\+84)(3[2-9]|5[689]|7[06-9]|8[1-6]|9[0-46-9])[0-9]{7}$|^(0|\+84)(2[0-9]{1}|[3-9]{1})[0-9]{8}$';
    RegExp regExp = RegExp(pattern);

    if (phoneNumber == null) {
      return false;
    }
    // Check if the phone number matches the pattern
    if (regExp.hasMatch(phoneNumber)) {
      return true;
    } else {
      return false;
    }
  }

  _onSavePressed() async {
    if (_formEditCustomerInfoKey.currentState!.validate()) {
      final userServices = UserServices();
      final userUpdateDTO = UserUpdateDTO(
        id: _userDTO!.id,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
      );

      final customerServices = CustomerServices();
      final customerUpdateDTO = CustomerUpdateDTO(
        customerId: _customer.customerId,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        middleName: _middleNameController.text,
        address: _address,
        rating: _customer.rating,
      );

      var isSuccess = await userServices.update(_userDTO.id, userUpdateDTO);
      isSuccess &= await customerServices.update(
          _customer.customerId, customerUpdateDTO);

      if (!isSuccess) {
        _showAlertDialog(
          'Sorry',
          'Unable to update your account at the moment. Please try again at a later time.',
          () {
            Navigator.of(context).pop();
          },
        );
      }

      List<Object> popObjects = [];
      popObjects.add(userUpdateDTO);
      popObjects.add(customerUpdateDTO);

      _showAlertDialog(
        'Success',
        'We have successfully updated your account.',
        () {
          Navigator.pop(context);
          Navigator.pop(context, popObjects);
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _userDTO = widget.userDTO;
    _customer = widget.customer;
    _address = _customer.address;

    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _getGeoLocation();
      _initTimer?.cancel();
    });
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _emailController.dispose();
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userDTO = widget.userDTO;
    _customer = widget.customer;
    _phoneNumberController.text = _userDTO.phoneNumber;
    _emailController.text = _userDTO.email;
    _firstNameController.text = _customer.firstName;
    _middleNameController.text = _customer.middleName;
    _lastNameController.text = _customer.lastName;

    final userServices = UserServices();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: KColors.kPrimaryColor,
        foregroundColor: KColors.kOnBackgroundColor,
        title: const Text('FoodToGo - Merchants'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 80,
              color: KColors.kPrimaryColor,
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                'Edit your profile',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: KColors.kOnBackgroundColor,
                      fontSize: 34,
                    ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(35, 15, 40, 30),
              child: Form(
                key: _formEditCustomerInfoKey,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 27,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Enter your new phone number'),
                            ),
                            keyboardType: TextInputType.phone,
                            controller: _phoneNumberController,
                            validator: (value) {
                              if (_isValidPhoneNumber(value)) {
                                return null;
                              }
                              return 'Please enter a valid phone number.';
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.email,
                          size: 27,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Enter your new email'),
                            ),
                            controller: _emailController,
                            validator: (value) {
                              if (_isValidEmail(value)) {
                                return null;
                              }
                              return 'Please enter a valid email.';
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.badge,
                          size: 27,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Enter your new first name'),
                            ),
                            controller: _firstNameController,
                            validator: (value) {
                              if (userServices.isValidVietnameseName(value)) {
                                return null;
                              }
                              return 'Please enter a valid first name.';
                            },
                            keyboardType: TextInputType.name,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            decoration: const InputDecoration(
                              label: Text('Enter your new middle name'),
                            ),
                            controller: _middleNameController,
                            validator: (value) {
                              if (userServices.isValidVietnameseName(value)) {
                                return null;
                              }
                              return 'Please enter a valid middle name.';
                            },
                            keyboardType: TextInputType.name,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            decoration: const InputDecoration(
                              label: Text('Enter your new last name'),
                            ),
                            controller: _lastNameController,
                            validator: (value) {
                              if (userServices.isValidVietnameseName(value)) {
                                return null;
                              }
                              return 'Please enter a valid last name.';
                            },
                            keyboardType: TextInputType.name,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.pin_drop),
                        const SizedBox(width: 15),
                        Flexible(flex: 4, child: Text(_address)),
                        IconButton(
                          icon: Icon(Icons.navigate_next),
                          onPressed: _selectOnMap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        _onSavePressed();
                      },
                      child: _isEditing
                          ? const CircularProgressIndicator.adaptive()
                          : const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
