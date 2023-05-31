class OrderSuccessRate {
  const OrderSuccessRate({
    this.successOrderCount = 0,
    this.cancelledOrderCount = 0,
  });

  final int successOrderCount;
  final int cancelledOrderCount;

  double getSuccessRate() {
    if ((successOrderCount + cancelledOrderCount) == 0) {
      return 0;
    }
    return successOrderCount / (successOrderCount + cancelledOrderCount);
  }
}
