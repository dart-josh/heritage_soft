import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/store_models/accessory.model.dart';

class AccessoryItemDialog extends StatelessWidget {
  final List<AccessoryItemModel> items;
  const AccessoryItemDialog({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // top bar
          Stack(
            children: [
              // title
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                height: 40,
                width: 400,
                child: Center(
                  child: Text(
                    'Items List',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // close button
              Positioned(
                top: 0,
                right: 6,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 5),
          // list
          Container(
            decoration: BoxDecoration(),
            width: 400,
            height: 400,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: items.map((e) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                    ),
                    margin: EdgeInsets.symmetric(vertical: 3),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        // name
                        Expanded(
                          child: Text(
                            e.accessory.itemName,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        SizedBox(width: 10),

                        // quantity
                        Text(
                          e.qty.toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}