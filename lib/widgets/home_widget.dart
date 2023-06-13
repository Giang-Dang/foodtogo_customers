import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/widgets/nearby_merchants_widget.dart';
import 'package:foodtogo_customers/widgets/promotion_merchants_widget.dart';
import 'package:foodtogo_customers/widgets/search_button_widget.dart';
import 'package:foodtogo_customers/widgets/top_drinks_widget.dart';
import 'package:foodtogo_customers/widgets/top_main_courses_widget.dart';
import 'package:foodtogo_customers/widgets/top_snacks_widget.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KColors.kBackgroundColor,
      height: double.infinity,
      width: double.infinity,
      child: const SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(height: 40),
              SearchButtonWidget(),
              SizedBox(height: 10),
              PromotionMerchantsWidget(),
              SizedBox(height: 20),
              NearbyMerchantsWidget(),
              SizedBox(height: 20),
              TopMainCoursesWidget(),
              SizedBox(height: 20),
              TopSnacksWidget(),
              SizedBox(height: 20),
              TopDrinksWidget(),
              SizedBox(height: 50),
            ],
          )),
    );
  }
}
