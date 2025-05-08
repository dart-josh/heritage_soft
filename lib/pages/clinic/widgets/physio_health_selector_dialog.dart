import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/physio_helpers.dart';
import 'package:intl/intl.dart';

class PhysioHealthSelectorDialog extends StatelessWidget {
  final List<G_PhysioHealthModel> list;
  const PhysioHealthSelectorDialog({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    list.sort((a, b) => DateFormat('dd_MM_yyyy')
        .parse(b.data.date)
        .compareTo(DateFormat('dd_MM_yyyy').parse(a.data.date)));

    return Dialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          color: Color.fromARGB(163, 4, 6, 29),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // list
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: list
                      .map((e) => InkWell(
                            onTap: () {
                              Navigator.pop(context, [e.data, false]);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              child: Center(
                                child: Text(
                                  e.key != 'Baseline'
                                      ? PhysioHelpers.fmt_date(e.key)
                                      : 'Baseline',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),

            // new health data
            if (app_role == 'desk' || app_role == 'ict')
              InkWell(
                onTap: () {
                  var chk = list
                      .where((element) =>
                          element.key ==
                          DateFormat('dd_MM_yyyy').format(DateTime.now()))
                      .toList();

                  if (chk.isNotEmpty) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.red,
                      toastText: 'You can\'t fill a new form at this moment',
                      icon: Icons.error,
                    );
                    return;
                  }

                  PhysioHealthModel pty = PhysioHealthModel(
                    height: '',
                    weight: '',
                    ideal_weight: '',
                    fat_rate: '',
                    weight_gap: '',
                    weight_target: '',
                    waist: '',
                    arm: '',
                    chest: '',
                    thighs: '',
                    hips: '',
                    pulse_rate: '',
                    blood_pressure: '',
                    chl_ov: '',
                    chl_nv: '',
                    chl_rm: '',
                    hdl_ov: '',
                    hdl_nv: '',
                    hdl_rm: '',
                    ldl_ov: '',
                    ldl_nv: '',
                    ldl_rm: '',
                    trg_ov: '',
                    trg_nv: '',
                    trg_rm: '',
                    blood_sugar: false,
                    eh_finding: '',
                    eh_recommend: '',
                    sh_finding: '',
                    sh_recommend: '',
                    ah_finding: '',
                    ah_recommend: '',
                    other_finding: '',
                    other_recommend: '',
                    ft_obj_1: '',
                    ft_obj_2: '',
                    ft_obj_3: '',
                    ft_obj_4: '',
                    ft_obj_5: '',
                    key: DateFormat('dd_MM_yyyy').format(DateTime.now()),
                    date: DateFormat('dd_MM_yyyy').format(DateTime.now()),
                    done: false,
                  );

                  Navigator.pop(context, [pty, true]);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 24, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'New Health Data',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
