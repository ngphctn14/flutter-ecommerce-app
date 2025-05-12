import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/utils/app_textstyles.dart';
import 'package:flutter_ecommerce_app/view/widgets/category_chips.dart';
import 'package:flutter_ecommerce_app/view/widgets/filter_bottom_sheet.dart';
import 'package:flutter_ecommerce_app/view/widgets/product_grid.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Shopping',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          IconButton(
            onPressed: () => FilterBottomSheet.show(context),
            icon: Icon(
              Icons.filter_list,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 16), child: CategoryChips()),
          Expanded(child: ProductGrid(products: [])),
        ],
      ),
    );
  }
}
