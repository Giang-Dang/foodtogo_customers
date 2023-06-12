import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:transparent_image/transparent_image.dart';

class MenuItemListItem extends StatefulWidget {
  const MenuItemListItem({
    Key? key,
    required this.menuItem,
    required this.maxHeight,
  }) : super(key: key);

  final MenuItem menuItem;
  final double maxHeight;

  @override
  State<MenuItemListItem> createState() => _MenuItemListItemState();
}

class _MenuItemListItemState extends State<MenuItemListItem> {
  @override
  Widget build(BuildContext context) {
    final maxHeight = widget.maxHeight;
    final menuItem = widget.menuItem;

    final double containerHeight = maxHeight - 30;
    final double containerWidth = 140;

    final jwtToken = UserServices.jwtToken;

    final imageUrl =
        Uri.http(Secrets.kFoodToGoAPILink, menuItem.imagePath).toString();

    return Row(
      children: [
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            color: KColors.kOnBackgroundColor,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              child: Container(
                width: containerWidth,
                height: containerHeight,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                child: Column(
                  children: [
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: FadeInImage(
                            height: 65,
                            width: containerWidth - 20,
                            placeholder: MemoryImage(kTransparentImage),
                            image: NetworkImage(
                              imageUrl,
                              headers: {
                                'Authorization': 'Bearer $jwtToken',
                              },
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${menuItem.name}\n',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color: KColors.kPrimaryColor, fontSize: 15),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            RatingBarIndicator(
                              rating: menuItem.rating,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 20,
                              direction: Axis.horizontal,
                            ),
                            Text(
                              menuItem.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '${menuItem.description}\n',
                          style: const TextStyle(
                              fontSize: 11, color: KColors.kGrey),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${menuItem.unitPrice.toStringAsFixed(1)} \$',
                          style: const TextStyle(
                              fontSize: 15,
                              color: KColors.kPrimaryColor,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
