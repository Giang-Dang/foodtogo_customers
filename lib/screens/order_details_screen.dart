import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_customers/models/dto/update_dto/order_update_dto.dart';
import 'package:foodtogo_customers/models/enum/order_status.dart';
import 'package:foodtogo_customers/models/enum/user_type.dart';
import 'package:foodtogo_customers/models/order.dart';
import 'package:foodtogo_customers/services/order_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/checkout_menu_item_list.dart';
import 'package:foodtogo_customers/widgets/order_deliver_address.dart';
import 'package:foodtogo_customers/widgets/order_menu_item_list.dart';
import 'package:foodtogo_customers/widgets/order_merchant.dart';
import 'package:foodtogo_customers/widgets/order_price_widget.dart';
import 'package:foodtogo_customers/widgets/order_shipper.dart';
import 'package:foodtogo_customers/widgets/order_status_widget.dart';
import 'package:intl/intl.dart';

final dateFormatter = DateFormat.yMMMMd();

class OrderDetailsScreen extends ConsumerStatefulWidget {
  const OrderDetailsScreen({
    Key? key,
    required this.order,
    this.onPop,
  }) : super(key: key);

  final Order order;
  final Function()? onPop;

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  _showAlertDialog(String title, String message, void Function() onOkPressed) {
    if (context.mounted) {
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
  }

  _isAbleToCancel(Order order) {
    if (order.status == OrderStatus.Placed.name.toLowerCase()) {
      return true;
    }
    if (order.status == OrderStatus.Getting.name.toLowerCase()) {
      return true;
    }
    if (order.status == OrderStatus.DriverAtMerchant.name.toLowerCase()) {
      return true;
    }
    return false;
  }

  _showCancellationBottomSheet(
    BuildContext context,
    Order order,
  ) async {
    final TextEditingController controller = TextEditingController();
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 1.0,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Please enter a cancellation reason:',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: KColors.kPrimaryColor),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  minLines: 2,
                  maxLines: 5,
                  decoration:
                      const InputDecoration(hintText: 'Cancellation reason'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (controller.text == '') {
                      _showAlertDialog('Invalid Reason',
                          'The reason field cannot be left empty!', () {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      });
                      return;
                    }
                    // Return the cancellation reason
                    String? reason = controller.text;

                    await _onCancelPress(order, reason);
                  },
                  child: const Text('Cancel Order'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onCancelPress(Order order, String reason) async {
    final updateDTO = OrderUpdateDTO(
      id: order.id,
      merchantId: order.merchant.merchantId,
      shipperId: order.shipper == null ? null : order.shipper!.userId,
      customerId: order.customer.customerId,
      promotionId: order.promotion == null ? null : order.promotion!.id,
      placedTime: order.placedTime,
      eta: order.eta,
      deliveryCompletionTime: order.deliveryCompletionTime,
      orderPrice: order.orderPrice,
      shippingFee: order.shippingFee,
      appFee: order.appFee,
      promotionDiscount: order.promotionDiscount,
      status: OrderStatus.Cancelled.name.toLowerCase(),
      cancelledBy: UserType.Customer.name.toLowerCase(),
      cancellationReason: reason,
      deliveryAddress: order.deliveryAddress,
      deliveryLatitude: order.deliveryLatitude,
      deliveryLongitude: order.deliveryLongitude,
    );
    final OrderServices orderServices = OrderServices();

    bool isSuccess = await orderServices.update(order.id, updateDTO);

    final orderList =
        await orderServices.getAll(merchantId: order.merchant.merchantId);

    isSuccess &= (orderList != null);

    if (isSuccess) {
      if(widget.onPop != null) {
        widget.onPop!();
      }
      
      _showAlertDialog('Cancelled', 'The order has been cancelled', () {
        if (context.mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      });
    } else {
      _showAlertDialog('Cancellation failed',
          'Unable to cancel this order at the moment. Please try again later.',
          () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //get order details
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAbleToCancel = _isAbleToCancel(widget.order);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.order.merchant.name,
          style: const TextStyle(color: KColors.kPrimaryColor),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        width: double.infinity,
        color: KColors.kPrimaryColor.withOpacity(0.2),
        child: ListView(
          children: [
            //Order status
            OrderStatusWidget(order: widget.order),
            //Customer
            const SizedBox(height: 20),
            OrderDeliverAddress(order: widget.order),
            //Merchant
            const SizedBox(height: 20),
            OrderMerchant(order: widget.order),
            //Shipper
            const SizedBox(height: 20),
            OrderShipper(order: widget.order),
            //Order details
            const SizedBox(height: 20),
            OrderMenuItemList(orderId: widget.order.id),
            //Order Price
            const SizedBox(height: 20),
            OrderPriceWidget(order: widget.order),

            if (isAbleToCancel) const SizedBox(height: 10),
            if (isAbleToCancel) const SizedBox(height: 20),
            if (isAbleToCancel)
              ElevatedButton(
                  onPressed: () {
                    _showCancellationBottomSheet(context, widget.order);
                  },
                  child: const Text('Cancel Order')),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
