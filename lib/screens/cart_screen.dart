import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/merchant.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
