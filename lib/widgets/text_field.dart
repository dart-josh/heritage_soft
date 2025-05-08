import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Text_field extends StatefulWidget {
  const Text_field({
    super.key,
    this.label = '',
    this.sample = '',
    required this.controller,
    this.node,
    this.hintText = '',
    this.maxLine = 1,
    this.edit = false,
    this.icon = null,
    this.prefix = null,
    this.center = false,
    this.ontap = null,
    this.format,
    this.text_align = TextAlign.start,
    this.font_size = 16,
    this.obscure = null,
    this.is_filled,
    this.fill_color,
    this.require = false,
    this.top_border_only = false,
  });

  final String label;
  final String sample;
  final TextEditingController controller;
  final FocusNode? node;
  final String hintText;
  final int maxLine;
  final bool edit;
  final Widget? icon;
  final Widget? prefix;
  final bool center;
  final void Function()? ontap;
  final List<TextInputFormatter>? format;
  final TextAlign text_align;
  final double font_size;
  final bool? obscure;
  final bool? is_filled;
  final Color? fill_color;
  final bool require;
  final bool top_border_only;

  @override
  State<Text_field> createState() => _Text_fieldState();
}

class _Text_fieldState extends State<Text_field> {
  bool? obscure = null;

  @override
  void initState() {
    obscure = widget.obscure;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = TextStyle(
      color: Color(0xFFc3c3c3),
      fontSize: 12,
    );
    TextStyle textfieldStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w400,
      fontSize: widget.font_size,
    );
    TextStyle hintStyle = TextStyle(
      color: Color(0xFFc3c3c3),
      fontSize: 12,
      letterSpacing: 0.6,
      fontStyle: FontStyle.italic,
    );

    return Column(
      crossAxisAlignment:
          widget.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // label
        widget.label.isEmpty
            ? SizedBox()
            : Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(widget.require ? '${widget.label} (*)' : widget.label, style: labelStyle),
              ),

        widget.label.isEmpty ? SizedBox() : SizedBox(height: 3),
        
        // sample
        widget.sample.isEmpty
            ? SizedBox()
            : Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(widget.sample, style: labelStyle),
              ),

        widget.sample.isEmpty ? SizedBox() : SizedBox(height: 3),
        
        // text bbox
        Container(
          height: (widget.maxLine == 1) ? 40 : null,
          child: TextField(
            style: textfieldStyle,
            readOnly: widget.edit,
            controller: widget.controller,
            focusNode: widget.node,
            textInputAction: widget.obscure!= null && widget.obscure! ? TextInputAction.done :
                (widget.maxLine == 1) ? TextInputAction.next : null,
            maxLines: widget.maxLine,
            inputFormatters: widget.format,
            textAlign: widget.text_align,
            obscureText: obscure ?? false,
            decoration: InputDecoration(
              filled: widget.is_filled,
              fillColor: widget.fill_color,
              hintText: widget.hintText,
              hintStyle: hintStyle,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFBCBCBC),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFBCBCBC),
                ),
                borderRadius: (widget.top_border_only) ? BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)) : BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.fromLTRB(
                12,
                (widget.maxLine == 1) ? 6 : 15,
                (widget.icon == null) ? 12 : 1,
                (widget.maxLine == 1) ? 6 : 15,
              ),
              suffixIcon: obscure != null && widget.controller.text.isNotEmpty
                  ? InkWell(
                      onTap: () async {
                        setState(() {
                          obscure = !obscure!;
                        });
                      },
                      child: Icon(
                        obscure! ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                    )
                  : widget.icon,
              prefix: widget.prefix != null
                  ? Padding(
                      padding: EdgeInsets.only(right: 5, top: 5),
                      child: widget.prefix,
                    )
                  : null,
            ),
            onTap: widget.ontap,
            onChanged: (val) {
              setState(() {});
            },
          ),
        ),
      ],
    );
  }
}
