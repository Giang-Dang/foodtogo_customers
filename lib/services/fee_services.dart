class FeeServices {
  static double _appFeePercentage = 10.0;
  static double _shippingFeePerKm = 5;

  double calAppFee(double subTotal) {
    return subTotal / 100 * _appFeePercentage;
  }

  double calShippingFee(double distance) {
    if (distance <= 1.0) {
      return _shippingFeePerKm;
    }
    return distance * _shippingFeePerKm;
  }
}
