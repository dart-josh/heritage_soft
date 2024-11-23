import 'package:flutter/material.dart';

class OptionsDialog extends StatelessWidget {
  OptionsDialog({
    super.key,
    required this.title,
    required this.options,
    this.dismiss = true,
  });

  final String title;
  final List<String> options;
  final bool dismiss;

  final TextStyle option_style = TextStyle(
    color: Colors.white,
    fontSize: 16,
    shadows: [
      Shadow(
        color: Color(0xFF000000),
        offset: Offset(0.7, 0.7),
        blurRadius: 6,
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 300,
        ),
        child: Container(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // heading
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF000000),
                      offset: Offset(0.7, 0.7),
                      blurRadius: 6,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 2),

                    // title
                    Stack(
                      children: [
                        // title
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),

                        // close button
                        if (dismiss)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close,
                                color: Colors.black,
                                size: 22,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // horizontal line
                    Container(
                      height: 1,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                    ),

                    SizedBox(height: 4),

                    // subtitle
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Text(
                        'Select one of the options below',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // options
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.isNotEmpty
                        ? options.map((e) => option_tile(context, e)).toList()
                        : [],
                  ),
                ),
              ),

              SizedBox(height: 7),
            ],
          ),
        ),
      ),
    );
  }

  // option tile
  Widget option_tile(context, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      child: InkWell(
        onTap: () {
          // return value
          Navigator.pop(context, text);
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFFbd9150).withOpacity(0.6),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(text, style: option_style),
        ),
      ),
    );
  }
}
