import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ecommerce_app/utils/app_textstyles.dart';

class CategoryChips extends StatefulWidget{
  const CategoryChips({super.key});
  @override
  State<CategoryChips> createState()=>_CategoryChipsState();
}
class _CategoryChipsState extends State<CategoryChips>{
  int selctedIndex = 0;
  final categories=['All','Men','Women','Girls','Boys'];
  @override
  Widget build(BuildContext context){
    final isDark = Theme.of(context).brightness==Brightness.dark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          categories.length,
            (index)=> Padding(
                padding: EdgeInsets.only(right: 12),
              child: AnimatedContainer(
                  duration: const  Duration(microseconds: 300),
                curve: Curves.easeOut,
                child: ChoiceChip(
                  label: Text(
                    categories[index],
                    style: AppTextStyle.withColor(
                      selctedIndex == index
                          ? AppTextStyle.withWeight(AppTextStyle.bodySmall,
                      FontWeight.w600,
                      ):AppTextStyle.bodySmall,
                      selctedIndex == index? Colors.white:
                      isDark? Colors.grey[300]!:Colors.grey[600]!
                    ),
                  ),
                  selected: selctedIndex==index,
                  onSelected: (bool selected){
                    setState(() {
                      selctedIndex=selected?index:selctedIndex;
                    });
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  backgroundColor:isDark? Colors.grey[800]:Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: selctedIndex == index?2:0,
                  pressElevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(
                    color: selctedIndex == index?
                        Colors.transparent:
                        isDark? Colors.grey[700]!:Colors.grey[300]!,
                    width: 1
                  ),
                ),
              ),
            )
        )
      ),
    );
  }
}