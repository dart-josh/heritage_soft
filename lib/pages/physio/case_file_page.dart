import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/physio_database_helpers.dart';
import 'package:intl/intl.dart';

class CaseFileD extends StatefulWidget {
  final PhysioHealthClientModel client;
  final String case_title;
  const CaseFileD({
    super.key,
    required this.client,
    required this.case_title,
  });

  @override
  State<CaseFileD> createState() => _CaseFileDState();
}

class _CaseFileDState extends State<CaseFileD> {
  List<CaseFileModel> _files = [];

  bool first_fetch = false;

  late StreamSubscription case_file_stream;

  // case file stream
  get_case_files() {
    case_file_stream =
        PhysioDatabaseHelpers.case_file_stream(widget.client.key).listen((event) {
      _files.clear();
      if (event.docs.isNotEmpty) {
        event.docs.forEach((element) {
          CaseFileModel cs = CaseFileModel.fromMap(element.id, element.data());
          _files.add(cs);
        });
      }

      if (first_fetch) {
        if (mounted) {
          Helpers.showToast(
            context: context,
            color: Colors.blue,
            toastText: 'Case File updaated',
            icon: Icons.update,
          );
        }
      } else {
        first_fetch = true;
      }

      setState(() {});
    });
  }

  @override
  void initState() {
    get_case_files();
    super.initState();
  }

  @override
  void dispose() {
    case_file_stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // sort files by most recent treatment date
    _files.sort((a, b) => b.treatment_date!.compareTo(a.treatment_date!));

    return Dialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      child: Row(
        children: [
          Expanded(child: Container()),

          // main box
          Container(
            width: 600,
            margin: EdgeInsets.all(40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Color.fromARGB(255, 62, 56, 47),
            ),
            child: Column(
              children: [
                // top bar
                topBar(),

                // case title
                case_title(widget.case_title),

                // list
                Expanded(
                  child: ListView.builder(
                    itemCount: _files.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) => case_tile(_files[index]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool is_all_expanded = false;

  // top bar
  Widget topBar() {
    is_all_expanded = false;
    _files.forEach((element) {
      if (element.expanded) {
        is_all_expanded = true;
      }
    });

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFd1cfcf)),
        ),
      ),
      child: Stack(
        children: [
          // title
          Padding(
            padding: EdgeInsets.only(top: 14, bottom: 8),
            child: Center(
              child: Text(
                'Case File',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  height: 1,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.7,
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      color: Color(0xFF000000),
                      offset: Offset(0.7, 0.7),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // id area
          Positioned(
            top: 0,
            left: 0,
            child: id_sub_group(),
          ),

          // action buttons
          Positioned(
            top: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // expand all
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: InkWell(
                      onTap: () {
                        _files.forEach((element) {
                          if (!is_all_expanded) {
                            element.expanded = true;
                          } else {
                            element.expanded = false;
                          }
                        });

                        setState(() {});
                      },
                      child: Icon(
                        is_all_expanded ? Icons.minimize : Icons.add,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),

                  // close button
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.cancel,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // client id
  Widget id_sub_group() {
    return Padding(
      padding: EdgeInsets.only(top: 5, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // label
          Text(
            'ID',
            style: TextStyle(
              color: Color(0xFFAFAFAF),
              fontSize: 14,
              letterSpacing: 1,
              height: 1,
            ),
          ),

          SizedBox(height: 4),

          // id group
          Text(
            widget.client.id,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 1,
              height: 0.8,
              shadows: [
                Shadow(
                  color: Color(0xFF000000),
                  offset: Offset(0.7, 0.7),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // case title
  Widget case_title(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TextStyle textStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
  );

  // case tile
  Widget case_tile(CaseFileModel file) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            children: [
              // date
              Text(
                Helpers.date_format(file.treatment_date!),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              
              // show assessment
              (file.type == 'Assessment')
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        file.type,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Container(),

              Expanded(child: Container()),

              // expand icon
              InkWell(  
                onTap: () {
                  file.expanded = !file.expanded;
                  setState(() {});
                },
                child: Icon(
                  file.expanded ? Icons.minimize : Icons.add,
                  color: Colors.white60,
                  size: 20,
                ),
              ),
            ],
          ),

          SizedBox(height: 4),

          // seperator
          Divider(thickness: 1, height: 1, color: Colors.white38),

          !file.expanded ? Container() : SizedBox(height: 15),

          // case file details
          !file.expanded
              ? Container()
              : Column(
                  children: [
                    // time & duration
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white10),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // start
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time Start',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                get_time(file.start_time),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),

                          // duration
                          Column(
                            children: [
                              Text(
                                'Duration',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                get_duration(file.start_time, file.end_time),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          // end
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Time End',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                get_time(file.end_time),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10),

                    // bp
                    Row(
                      children: [
                        // label
                        Text(
                          'B.P Reading:',
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),

                        SizedBox(width: 6),

                        // value
                        Text(
                          file.bp_reading,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    // note label
                    Text(
                      'NOTE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),

                    SizedBox(height: 3),
                    // note
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      width: double.infinity,
                      height: 400,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: SelectableText(
                            file.note,
                            style: textStyle,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    // decision
                    treatment_decision(file),

                    SizedBox(height: 15),

                    // remark label
                    Text(
                      'REMARKS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),

                    SizedBox(height: 3),
                    // remark
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      width: double.infinity,
                      height: 200,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: SelectableText(
                            file.remarks,
                            style: textStyle,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'PT ${file.doctor}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    SizedBox(height: 4),

                    Divider(thickness: 1, height: 1, color: Colors.white38),
                  ],
                ),

          //
        ],
      ),
    );
  }

  Widget treatment_decision(CaseFileModel file) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // decision title
        Text(
          'Treatment Decision',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),

        SizedBox(height: 3),

        // main decision
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(5),
          ),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: SelectableText(
                file.decision,
                style: textStyle,
              ),
            ),
          ),
        ),

        if ((file.decision.toLowerCase().contains('refer')) ||
            (file.decision.toLowerCase().contains('other')))
          SizedBox(height: 8),
        
        // refer decision
        if (file.decision.toLowerCase().contains('refer'))
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(5),
            ),
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: SelectableText(
                  file.refered_decision,
                  style: textStyle,
                ),
              ),
            ),
          )
        
        // other decision
        else if (file.decision.toLowerCase().contains('other'))
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(5),
            ),
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: SelectableText(
                  file.other_decision,
                  style: textStyle,
                ),
              ),
            ),
          ),
      ],
    );
  }

  //

  // format time
  String get_time(DateTime? time) =>
      time != null ? DateFormat.jm().format(time) : '';

  // get duration
  String get_duration(DateTime? time_in, DateTime? time_out) {
    if (time_in == null || time_out == null) return '';

    Duration diff = time_out.difference(time_in);

    int hr = 0;
    int min = 0;
    int day = 0;

    if (diff.inHours >= 24) {
      day = diff.inDays;
      hr = diff.inHours - (diff.inDays * 24);
      min = diff.inMinutes - (diff.inHours * 60);
    } else if (diff.inHours >= 1) {
      hr = diff.inHours;
      min = diff.inMinutes - (diff.inHours * 60);
    } else {
      min = diff.inMinutes;
    }

    String d = (day == 0)
        ? ''
        : (day == 1)
            ? '$day Day '
            : '$day Days ';

    String h = (hr == 0)
        ? ''
        : (hr == 1)
            ? '$hr Hour '
            : '$hr Hours ';

    String m = (min == 0)
        ? ''
        : (min == 1)
            ? '$min Min'
            : '$min Mins';

    return '$d$h$m';
  }

  //
}
