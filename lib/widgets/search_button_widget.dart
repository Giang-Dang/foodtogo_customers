import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_customers/screens/search_screen.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';

class SearchButtonWidget extends StatefulWidget {
  const SearchButtonWidget({
    Key? key,
    this.onSearchTap,
  }) : super(key: key);

  final Function? onSearchTap;

  @override
  State<SearchButtonWidget> createState() => _SearchButtonWidgetState();
}

class _SearchButtonWidgetState extends State<SearchButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: GestureDetector(
        onTap: () {
          if (context.mounted) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const SearchScreen(),
            ));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
          decoration: BoxDecoration(
            border: Border.all(
              color: KColors.kPrimaryColor,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              Icon(Icons.search),
            ],
          ),
        ),
      ),
    );
  }
}
