// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:heritage_soft/widgets/options_dialog.dart';

class Select_form extends StatefulWidget {
  Select_form({
    super.key,
    this.label = '',
    required this.options,
    required this.text_value,
    required this.setval,
    this.edit = true,
    this.require = false,
  });

  final String label;
  final List<String> options;
  String text_value;
  Function setval;
  final bool edit;
  final bool require;

  @override
  State<Select_form> createState() => _Select_formState();
}

class _Select_formState extends State<Select_form> {
  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = TextStyle(
      color: Color(0xFFc3c3c3),
      fontSize: 12,
    );
    TextStyle textfieldStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // label
          if (widget.label.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(widget.require ? '${widget.label} (*)' : widget.label, style: labelStyle),
            ),

          if (widget.label.isNotEmpty) SizedBox(height: 3),

          // select field
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Color(0xFFBCBCBC)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: () async {
                if (!widget.edit) return;

                // open options dialog
                var response = await showDialog(
                  context: context,
                  builder: (context) => OptionsDialog(
                    title: widget.label,
                    options: widget.options,
                  ),
                );

                if (response != null) widget.setval(response);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // text
                    Expanded(
                      child: SelectableText(
                        widget.text_value,
                        style: textfieldStyle,
                      ),
                    ),

                    // icon
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: (widget.edit)
                          ? Color(0xFF9b9B9B)
                          : Colors.transparent,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
