import 'package:foodtogo_customers/settings/kdelivery.dart';

class DeliveryServices {
  double calDeliveryETA(double distanceInKm) {
    return distanceInKm * KDelivery.kMinsPerKm + KDelivery.kPrepairTime;
  }
}
