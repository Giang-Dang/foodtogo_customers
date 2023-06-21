import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/enum/days_of_week.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/models/normal_open_hours.dart';
import 'package:foodtogo_customers/services/normal_open_hours_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:intl/intl.dart';

final timeFormatter = DateFormat.Hm();

class MerchantInfoOpenHours extends StatefulWidget {
  const MerchantInfoOpenHours({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  @override
  State<MerchantInfoOpenHours> createState() => _MerchantInfoOpenHoursState();
}

class _MerchantInfoOpenHoursState extends State<MerchantInfoOpenHours> {
  List<NormalOpenHours> _normalOpenHoursList = [];

  Timer? _initTimer;

  _getOpenHours(Merchant merchant) async {
    final normalOpenHoursServices = NormalOpenHoursServices();

    final normalOpenHoursList = await normalOpenHoursServices.getAll(
        searchMerchantId: widget.merchant.merchantId);

    if (normalOpenHoursList == null) {
      return;
    }

    if (mounted) {
      setState(() {
        _normalOpenHoursList = normalOpenHoursList;
      });
    }
  }

  Widget _getOpenHoursWidget(List<NormalOpenHours> normalOpenHoursList) {
    List<Widget> columnChilren = [
      const Row(
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: KColors.kBlue,
          ),
          SizedBox(width: 5),
          Text(
            'Opening Hours:',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      const SizedBox(height: 10),
    ];

    for (int i = 0; i < DaysOfWeek.values.length; i++) {
      NormalOpenHours? current = normalOpenHoursList
          .where((e) => e.dayOfWeek == i)
          .toList()
          .firstOrNull;

      Widget trailingContent = const Text(
        'Closed',
        style: TextStyle(color: KColors.kDanger),
      );

      if (current != null) {
        trailingContent = Text(
          '${timeFormatter.format(current.openTime)} - ${timeFormatter.format(current.closeTime)}',
          style: const TextStyle(color: KColors.kSuccessColor),
        );
      }

      final now = DateTime.now();
      final todayDayOfWeek = DateFormat('EEEE').format(now);
      final isToday = todayDayOfWeek.toLowerCase() ==
          DaysOfWeek.values[i].name.toLowerCase();

      columnChilren.add(Container(
        padding: const EdgeInsets.fromLTRB(20, 2, 40, 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              isToday
                  ? '${DaysOfWeek.values[i].name} (today)'
                  : DaysOfWeek.values[i].name,
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailingContent,
          ],
        ),
      ));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
      child: Column(
        children: columnChilren,
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _getOpenHours(widget.merchant);
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
    final content = _getOpenHoursWidget(_normalOpenHoursList);
    return content;
  }
}
