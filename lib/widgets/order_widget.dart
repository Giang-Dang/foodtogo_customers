import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/enum/order_status.dart';
import 'package:foodtogo_customers/models/order.dart';
import 'package:foodtogo_customers/services/order_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/order_list_item.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({Key? key}) : super(key: key);

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  Future<List<Order>> _getUserOrders() async {
    final orderServices = OrderServices();

    List<Order> orderList = [];

    List<Future> futures = [];
    for (var element in OrderStatus.values) {
      if (element != OrderStatus.Completed &&
          element != OrderStatus.Cancelled) {
        futures.add(() async {
          orderList = [
            ...await orderServices.getAll(
                  customerId: UserServices.userId,
                  searchStatus: element.name,
                ) ??
                []
          ];
        }());
      }
    }
    await Future.wait(futures);

    return orderList;
  }

  refresh() {
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.sizeOf(context).height;

    return FutureBuilder(
      future: _getUserOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        } else {
          return Container(
            height: deviceHeight,
            color: KColors.kBackgroundColor,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var order in snapshot.data!)
                    OrderListItem(
                      order: order,
                      onPop: refresh,
                    ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
