import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/widgets/select_form.dart';
import 'package:heritage_soft/widgets/text_field.dart';

class ClinicInfo extends StatefulWidget {
  final AssessmentModel? info;
  final bool new_det;
  const ClinicInfo({super.key, required this.info, this.new_det = false});

  @override
  State<ClinicInfo> createState() => _ClinicInfoState();
}

class _ClinicInfoState extends State<ClinicInfo> {
  @override
  void dispose() {
    case_select_controller.dispose();
    equipment_select_controller.dispose();
    diagnosis_controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.new_det && widget.info != null) {
      case_select_controller.text = widget.info!.case_select;
      selected_case_select_options = case_select_controller.text.split(',');

      diagnosis_controller.text = widget.info!.diagnosis;

      case_type_select = widget.info!.case_type;

      treatment_type_select = widget.info!.treatment_type;

      equipment_select_controller.text = widget.info!.equipment;
      selected_equipment_options = equipment_select_controller.text.split(',');
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top bar
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
              child: Stack(
                children: [
                  // title
                  Center(
                    child: Text(
                      'Treatment Protocol',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // close button
                  Positioned(
                    top: 5,
                    right: 0,
                    child: Center(
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // body
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.new_det ? edit_tiles() : tiles(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> tiles() {
    return [
      // case title
      tile('Medical condition', widget.info!.case_select),

      // diagnosis
      tile('PT Diagnosis', widget.info!.diagnosis),

      // case type
      tile('Specialization', widget.info!.case_type),

      // treatment type
      tile('Treatment type', widget.info!.treatment_type),

      // equipment
      tile('Equipment(s)', widget.info!.equipment),
    ];
  }

  // tile
  Widget tile(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // label
          Text(
            label,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),

          SizedBox(height: 6),

          // value
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  //?
  TextEditingController case_select_controller = TextEditingController();
  TextEditingController equipment_select_controller = TextEditingController();
  TextEditingController diagnosis_controller = TextEditingController();

  List<String> selected_case_select_options = [];
  String case_type_select = '';

  String treatment_type_select = '';

  List<String> selected_equipment_options = [];

  //? Edit tile
  List<Widget> edit_tiles() {
    if (selected_case_select_options.isNotEmpty)
      case_select_controller.text = selected_case_select_options.join(',');
    else
      case_select_controller.text = '';

    if (selected_equipment_options.isNotEmpty)
      equipment_select_controller.text = selected_equipment_options.join(',');
    else
      equipment_select_controller.text = '';

    if (case_select_controller.text.startsWith(',')) {
      case_select_controller.text =
          case_select_controller.text.replaceFirst(',', '');
    }

    if (equipment_select_controller.text.startsWith(',')) {
      equipment_select_controller.text =
          equipment_select_controller.text.replaceFirst(',', '');
    }

    return [
      // case multi-select
      Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text_field(
          label: 'Select Medical condition',
          controller: case_select_controller,
          edit: true,
          icon: case_multi_select(
            child: Icon(
              Icons.select_all,
              color: Colors.white,
            ),
          ),
        ),
      ),

      // diagnosis
      Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text_field(
          label: 'PT Diagnosis',
          controller: diagnosis_controller,
          maxLine: 2,
          font_size: 14,
        ),
      ),

      // case type
      Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        // width: 100,
        child: Select_form(
          label: 'Specialization',
          options: case_type_options,
          text_value: case_type_select,
          setval: (val) {
            case_type_select = val;
            setState(() {});
          },
        ),
      ),

      // treatment type
      Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        // width: 100,
        child: Select_form(
          label: 'Treatment type',
          options: treatment_type_options,
          text_value: treatment_type_select,
          setval: (val) {
            treatment_type_select = val;
            setState(() {});
          },
        ),
      ),

      // equipment
      Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text_field(
          label: 'Equipment',
          controller: equipment_select_controller,
          edit: true,
          icon: equipment_multi_select(
            child: Icon(
              Icons.select_all,
              color: Colors.white,
            ),
          ),
        ),
      ),

      SizedBox(height: 15),

      InkWell(
        onTap: () async {
          if (case_select_controller.text.isEmpty) {
            Helpers.showToast(
              context: context,
              color: Colors.redAccent,
              toastText: 'Please Select a case',
              icon: Icons.error,
            );
            return;
          }

          if (diagnosis_controller.text.isEmpty) {
            Helpers.showToast(
              context: context,
              color: Colors.redAccent,
              toastText: 'Enter PT Diagnosis',
              icon: Icons.error,
            );
            return;
          }

          if (case_type_select.isEmpty) {
            Helpers.showToast(
              context: context,
              color: Colors.redAccent,
              toastText: 'Select specialization',
              icon: Icons.error,
            );
            return;
          }

          if (treatment_type_select.isEmpty) {
            Helpers.showToast(
              context: context,
              color: Colors.redAccent,
              toastText: 'Select treatment type',
              icon: Icons.error,
            );
            return;
          }

          var conf = await showDialog(
            context: context,
            builder: (context) => ConfirmDialog(
              title: 'Submit Details',
              subtitle:
                  'You are about to submit this details, Would you like to proceed?',
            ),
          );

          if (conf != null && conf) {
            AssessmentModel ass = AssessmentModel(
              case_select: case_select_controller.text.trim(),
              diagnosis: diagnosis_controller.text.trim(),
              case_type: case_type_select,
              treatment_type: treatment_type_select,
              equipment: equipment_select_controller.text.trim(),
            );

            Navigator.pop(context, ass);
          }
        },
        child: Container(
          height: 34,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: Text(
              'Submit',
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
    ];
  }

  // case select
  Widget case_multi_select({required child}) {
    return PopupMenuButton<String>(
        padding: EdgeInsets.all(0),
        offset: Offset(0, 30),
        child: child,
        elevation: 8,
        onSelected: (value) async {
          bool is_in = selected_case_select_options.contains(value);

          if (is_in) {
            selected_case_select_options.remove(value);
          } else {
            selected_case_select_options.add(value);
          }

          setState(() {});
        },
        itemBuilder: (context) => case_select_options.map((e) {
              bool is_in = selected_case_select_options.contains(e);

              return PopupMenuItem(
                padding: EdgeInsets.all(0),
                value: e,
                child: Container(
                  width: double.infinity,
                  height: kMinInteractiveDimension,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: is_in ? Colors.red.shade100 : Colors.blue.shade50,
                  ),
                  child: Text(
                    e,
                    style: TextStyle(),
                  ),
                ),
              );
            }).toList());
  }

  // equipment select
  Widget equipment_multi_select({required child}) {
    return PopupMenuButton<String>(
        padding: EdgeInsets.all(0),
        offset: Offset(0, 30),
        child: child,
        elevation: 8,
        onSelected: (value) async {
          bool is_in = selected_equipment_options.contains(value);

          if (is_in) {
            selected_equipment_options.remove(value);
          } else {
            selected_equipment_options.add(value);
          }

          setState(() {});
        },
        itemBuilder: (context) => equipment_options.map((e) {
              bool is_in = selected_equipment_options.contains(e);

              return PopupMenuItem(
                enabled: !(e.startsWith('*')),
                padding: EdgeInsets.all(0),
                value: e,
                child: Container(
                  width: double.infinity,
                  height: kMinInteractiveDimension,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: is_in ? Colors.red.shade100 : Colors.blue.shade50,
                  ),
                  child: Text(
                    e.replaceAll('*', ''),
                    style: TextStyle(),
                  ),
                ),
              );
            }).toList());
  }
}
