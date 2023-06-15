import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/widgets/merchant_list.dart';

class SearchMerchantList extends StatefulWidget {
  const SearchMerchantList({
    Key? key,
    required this.merchantList,
  }) : super(key: key);

  final List<Merchant> merchantList;

  @override
  State<SearchMerchantList> createState() => _SearchMerchantListState();
}

class _SearchMerchantListState extends State<SearchMerchantList> {
  @override
  Widget build(BuildContext context) {
    return MerchantList(merchantList: widget.merchantList);
  }
}
