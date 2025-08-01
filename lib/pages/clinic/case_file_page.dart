import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/clinic_models/casefile.model.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/clinic_database_helpers.dart';
import 'package:intl/intl.dart';

class CaseFileD extends StatefulWidget {
  final PatientModel patient;
  const CaseFileD({
    super.key,
    required this.patient,
  });

  @override
  State<CaseFileD> createState() => _CaseFileDState();
}

class _CaseFileDState extends State<CaseFileD> {
  List<CaseFileModel> _files = [];
  bool isLoading = true;

  // case file stream
  get_case_files() async {
    isLoading = true;
    _files = await ClinicDatabaseHelpers.get_case_file_by_patient(
            context, widget.patient.key ?? '') ??
        [];
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    get_case_files();
    super.initState();
  }

  @override
  void dispose() {
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
                if (widget.patient.assessment_info.isNotEmpty)
                  case_title(widget.patient.assessment_info[0].diagnosis),

                // list
                Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          itemCount: _files.length,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) =>
                              case_tile(_files[index]),
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
                'Case File - ${_files.length}',
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
            widget.patient.patient_id,
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
              (file.case_type == 'Assessment')
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        file.case_type,
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
                               Helpers. get_duration(file.start_time, file.end_time),
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
                          file.bp_reading.isNotEmpty ? file.bp_reading : 'Not recorded',
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
                        'PT ${file.doctor.user.f_name}',
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

        // main treatment_decision
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
                file.treatment_decision,
                style: textStyle,
              ),
            ),
          ),
        ),

        if ((file.treatment_decision.toLowerCase().contains('refer')) ||
            (file.treatment_decision.toLowerCase().contains('other')))
          SizedBox(height: 8),

        // refer treatment_decision
        if (file.treatment_decision.toLowerCase().contains('refer'))
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

        // other treatment_decision
        else if (file.treatment_decision.toLowerCase().contains('other'))
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

  
  //
}
