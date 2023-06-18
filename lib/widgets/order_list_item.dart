import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/order.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/screens/order_details_screen.dart';
import 'package:foodtogo_customers/services/order_services.dart';
import 'package:foodtogo_customers/widgets/order_list_item_shipper_widget.dart';
import 'package:intl/intl.dart';

final timeFormatter = DateFormat('HH:mm:ss');
final dateFormatter = DateFormat.MMMd();

class OrderListItem extends StatelessWidget {
  const OrderListItem({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  _onTapListTile(BuildContext context, Order order) {
    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(order: order),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final OrderServices orderServices = OrderServices();

    Widget contain = const ListTile(
      leading: CircularProgressIndicator(),
      title: Text('Loading...'),
    );

    contain = Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: orderServices.getOrderColor(order.status).withOpacity(0.08)),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          onTap: () {
            _onTapListTile(context, order);
          },
          title: OrderListItemShipperWidget(order: order),
          subtitle: Transform.translate(
            offset: const Offset(0, 5),
            child: Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  size: 17,
                  color: KColors.kLightTextColor,
                ),
                Text(
                  ': ${order.orderPrice.toStringAsFixed(1)};',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_month,
                  size: 17,
                  color: KColors.kLightTextColor,
                ),
                Text(
                  ': ${dateFormatter.format(order.placedTime)} ${timeFormatter.format(order.placedTime)};',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.schedule,
                  size: 17,
                  color: KColors.kLightTextColor,
                ),
                Text(
                  ': ${timeFormatter.format(order.eta)};  ',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return contain;
  }
}
