import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/clinic_models/casefile.model.dart';
import 'package:heritage_soft/datamodels/clinic_models/payment.model.dart';
import 'package:heritage_soft/helpers/clinic_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:intl/intl.dart';

class ClinicRecordPage extends StatefulWidget {
  const ClinicRecordPage({super.key});

  @override
  State<ClinicRecordPage> createState() => _ClinicRecordPageState();
}

class _ClinicRecordPageState extends State<ClinicRecordPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  ValueNotifier<List<GroupPaymentHistoryModel>> g_payment_record =
      ValueNotifier([]);
  ValueNotifier<List<PaymentHistoryModel>> main_payment_record =
      ValueNotifier([]);

  ValueNotifier<List<GroupCaseFileModel>> g_assessment = ValueNotifier([]);
  ValueNotifier<List<GroupCaseFileModel>> g_treatment = ValueNotifier([]);

  ValueNotifier<List<CaseFileModel>> main_assessment = ValueNotifier([]);
  ValueNotifier<List<CaseFileModel>> main_treatment = ValueNotifier([]);

  ValueNotifier<String> active_payment_date = ValueNotifier('');
  ValueNotifier<String> active_assessment_date = ValueNotifier('');
  ValueNotifier<String> active_treatment_date = ValueNotifier('');

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);

    fetch_payment_record();
    fetch_clinic_record();

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    g_payment_record.dispose();
    main_payment_record.dispose();
    g_assessment.dispose();
    g_treatment.dispose();
    main_assessment.dispose();
    main_treatment.dispose();
    active_payment_date.dispose();
    active_assessment_date.dispose();
    active_treatment_date.dispose();
    super.dispose();
  }

  fetch_payment_record() async {
    var _record = await ClinicDatabaseHelpers.get_payment_record(context);

    var _filtered_record =
        _record.where((rec) => rec.hist_type.toLowerCase().contains('payment'));

    var _list = groupBy(_filtered_record, (rec) {
      return format_date(rec.date);
    });

    List<GroupPaymentHistoryModel> _t_l = [];

    _list.forEach((k, v) {
      GroupPaymentHistoryModel rec =
          GroupPaymentHistoryModel(date: k, record: v);
      _t_l.add(rec);
    });

    g_payment_record.value = _t_l;

    var chk = _t_l.indexWhere((rec) => rec.date == format_date(DateTime.now()));

    if (chk != -1) {
      active_payment_date.value = _t_l[chk].date;
      main_payment_record.value = _t_l[chk].record;
    }
  }

  fetch_clinic_record() async {
    var _record = await ClinicDatabaseHelpers.get_all_case_files(context);

    if (_record != null && _record.isNotEmpty) {
      sort_assessment(_record);
      sort_treatment(_record);
    }
  }

  sort_assessment(List<CaseFileModel> _record) {
    var _filtered_record = _record
        .where((rec) => rec.case_type.toLowerCase() == 'assessment')
        .toList();

    var _list = groupBy(_filtered_record, (rec) {
      return format_date(rec.treatment_date);
    });

    List<GroupCaseFileModel> _t_l = [];

    _list.forEach((k, v) {
      GroupCaseFileModel rec = GroupCaseFileModel(date: k, record: v);
      _t_l.add(rec);
    });

    g_assessment.value = _t_l;

    var chk = _t_l.indexWhere((rec) => rec.date == format_date(DateTime.now()));

    if (chk != -1) {
      active_assessment_date.value = _t_l[chk].date;
      main_assessment.value = _t_l[chk].record;
    }
  }

  sort_treatment(List<CaseFileModel> _record) {
    var _filtered_record = _record
        .where((rec) => rec.case_type.toLowerCase() == 'treatment')
        .toList();

    var _list = groupBy(_filtered_record, (rec) {
      return format_date(rec.treatment_date);
    });

    List<GroupCaseFileModel> _t_l = [];

    _list.forEach((k, v) {
      GroupCaseFileModel rec = GroupCaseFileModel(date: k, record: v);
      _t_l.add(rec);
    });

    g_treatment.value = _t_l;

    var chk = _t_l.indexWhere((rec) => rec.date == format_date(DateTime.now()));

    if (chk != -1) {
      active_treatment_date.value = _t_l[chk].date;
      main_treatment.value = _t_l[chk].record;
    }
  }

  String format_date(DateTime? date) {
    if (date == null) return 'unknon';

    if (date.month == DateTime.now().month &&
        date.year == DateTime.now().year) {
      return DateFormat('dd MMMM, yyyy').format(date);
    } else
      return DateFormat('MMMM, yyyy').format(date);
  }

  DateTime reverse_date(String date) {
    if (date.split(' ').length > 2) {
      return DateFormat('dd MMMM, yyyy').parse(date);
    } else
      return DateFormat('MMMM, yyyy').parse(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Clinc record'),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 15, 51, 117),
        centerTitle: true,
        bottom: TabBar(
          unselectedLabelColor: Colors.white70,
          labelColor: Colors.blueAccent,
          dividerColor: Colors.white54,
          controller: _tabController,
          tabs: const [
            Tab(text: "Payment record"),
            Tab(text: "Treatment record"),
            Tab(text: "Assessment record"),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 20, 59, 91),
      body: ValueListenableBuilder(
        valueListenable: g_payment_record,
        builder: (context, value, child) {
          return TabBarView(
            controller: _tabController,
            physics: BouncingScrollPhysics(),
            children: [
              payment_details(),
              treatment_list(),
              assessment_list(),
            ],
          );
        },
      ),
    );
  }

  //? WIdgets

  // payment list
  Widget payment_details() {
    return ValueListenableBuilder(
        valueListenable: g_payment_record,
        builder: (context, g_payment_record_value, child) {
          return Container(
            child: Column(
              children: [
                // date selector
                payment_date_selector(g_payment_record_value),

                const SizedBox(height: 10),

                // page
                payment_record_list(),
              ],
            ),
          );
        });
  }

  // assessment list
  Widget assessment_list() {
    return ValueListenableBuilder(
        valueListenable: g_assessment,
        builder: (context, g_assessment_value, child) {
          return Container(
            child: Column(
              children: [
                // date selector
                assessment_date_selector(g_assessment_value),

                const SizedBox(height: 10),

                // page
                assessment_record_list(),
              ],
            ),
          );
        });
  }

  // treatment list
  Widget treatment_list() {
    return ValueListenableBuilder(
        valueListenable: g_treatment,
        builder: (context, g_treatment_value, child) {
          return Container(
            child: Column(
              children: [
                // date selector
                treatment_date_selector(g_treatment_value),

                const SizedBox(height: 10),

                // page
                treatment_record_list(),
              ],
            ),
          );
        });
  }

  // ?

  // date selector
  Widget payment_date_selector(List<GroupPaymentHistoryModel> record) {
    record.sort((a, b) => reverse_date(b.date).compareTo(reverse_date(a.date)));

    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white60,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ValueListenableBuilder(
          valueListenable: active_payment_date,
          builder: (context, _value, child) {
            return Row(
              children: [
                Expanded(
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      children: record
                          .map((e) => payment_date_picker_tile(e))
                          .toList()),
                ),

                SizedBox(width: 10),

                // date picker
                IconButton(
                  onPressed: () async {
                    var res = await showDatePicker(
                      context: context,
                      initialDate: _value.isNotEmpty
                          ? reverse_date(_value)
                          : DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );

                    if (res != null) {
                      var dt = format_date(res);

                      var chk = g_payment_record.value
                          .indexWhere((rec) => rec.date == dt);

                      if (chk != -1) {
                        active_payment_date.value = dt;
                        main_payment_record.value =
                            g_payment_record.value[chk].record;
                      } else {
                        Helpers.showToast(
                          context: context,
                          color: Colors.redAccent,
                          toastText: 'No Record',
                          icon: Icons.warning,
                        );
                      }
                    }
                  },
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.white70,
                  ),
                ),

                // month picker
                IconButton(
                  onPressed: () async {
                    // final res = await SimpleMonthYearPicker.showMonthYearPickerDialog(
                    //   context: context,
                    //   // initialDate: (sale_type == 'store')
                    //   //     ? store_dateM ?? DateTime.now()
                    //   //     : (sale_type == 'online')
                    //   //         ? online_dateM ?? DateTime.now()
                    //   //         : terminal_dateM ?? DateTime.now(),
                    //   // firstDate: DateTime(2020),
                    //   // lastDate: DateTime.now(),
                    // );

                    // if (res != null) {}
                  },
                  icon: Icon(Icons.calendar_month_outlined),
                ),

                // date range
                IconButton(
                  onPressed: () async {
                    var res = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      // initialDateRange: ,
                    );

                    if (res != null) {}
                  },
                  icon: Icon(Icons.date_range),
                ),
              ],
            );
          }),
    );
  }

  Widget assessment_date_selector(List<GroupCaseFileModel> record) {
    record.sort((a, b) => reverse_date(b.date).compareTo(reverse_date(a.date)));

    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white60,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ValueListenableBuilder(
          valueListenable: active_assessment_date,
          builder: (context, _value, child) {
            return Row(
              children: [
                Expanded(
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      children: record
                          .map((e) => assessment_date_picker_tile(e))
                          .toList()),
                ),

                SizedBox(width: 10),

                // date picker
                IconButton(
                  onPressed: () async {
                    var res = await showDatePicker(
                      context: context,
                      initialDate: _value.isNotEmpty
                          ? reverse_date(_value)
                          : DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );

                    if (res != null) {
                      var dt = format_date(res);

                      var chk = g_assessment.value
                          .indexWhere((rec) => rec.date == dt);

                      if (chk != -1) {
                        active_assessment_date.value = dt;
                        main_assessment.value = g_assessment.value[chk].record;
                      } else {
                        Helpers.showToast(
                          context: context,
                          color: Colors.redAccent,
                          toastText: 'No Record',
                          icon: Icons.warning,
                        );
                      }
                    }
                  },
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.white70,
                  ),
                ),

                // month picker
                IconButton(
                  onPressed: () async {
                    // final res = await SimpleMonthYearPicker.showMonthYearPickerDialog(
                    //   context: context,
                    //   // initialDate: (sale_type == 'store')
                    //   //     ? store_dateM ?? DateTime.now()
                    //   //     : (sale_type == 'online')
                    //   //         ? online_dateM ?? DateTime.now()
                    //   //         : terminal_dateM ?? DateTime.now(),
                    //   // firstDate: DateTime(2020),
                    //   // lastDate: DateTime.now(),
                    // );

                    // if (res != null) {}
                  },
                  icon: Icon(Icons.calendar_month_outlined),
                ),

                // date range
                IconButton(
                  onPressed: () async {
                    // var res = await showDateRangePicker(
                    //   context: context,
                    //   firstDate: DateTime(2020),
                    //   lastDate: DateTime.now(),
                    //   // initialDateRange: ,
                    // );

                    // if (res != null) {}
                  },
                  icon: Icon(Icons.date_range),
                ),
              ],
            );
          }),
    );
  }

  Widget treatment_date_selector(List<GroupCaseFileModel> record) {
    record.sort((a, b) => reverse_date(b.date).compareTo(reverse_date(a.date)));

    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white60,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ValueListenableBuilder(
          valueListenable: active_treatment_date,
          builder: (context, _value, child) {
            return Row(
              children: [
                Expanded(
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      children: record
                          .map((e) => treatment_date_picker_tile(e))
                          .toList()),
                ),

                SizedBox(width: 10),

                // date picker
                IconButton(
                  onPressed: () async {
                    var res = await showDatePicker(
                      context: context,
                      initialDate: _value.isNotEmpty
                          ? reverse_date(_value)
                          : DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );

                    if (res != null) {
                      var dt = format_date(res);

                      var chk =
                          g_treatment.value.indexWhere((rec) => rec.date == dt);

                      if (chk != -1) {
                        active_treatment_date.value = dt;
                        main_treatment.value = g_treatment.value[chk].record;
                      } else {
                        Helpers.showToast(
                          context: context,
                          color: Colors.redAccent,
                          toastText: 'No Record',
                          icon: Icons.warning,
                        );
                      }
                    }
                  },
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.white70,
                  ),
                ),

                // month picker
                IconButton(
                  onPressed: () async {
                    // final res = await SimpleMonthYearPicker.showMonthYearPickerDialog(
                    //   context: context,
                    //   // initialDate: (sale_type == 'store')
                    //   //     ? store_dateM ?? DateTime.now()
                    //   //     : (sale_type == 'online')
                    //   //         ? online_dateM ?? DateTime.now()
                    //   //         : terminal_dateM ?? DateTime.now(),
                    //   // firstDate: DateTime(2020),
                    //   // lastDate: DateTime.now(),
                    // );

                    // if (res != null) {}
                  },
                  icon: Icon(Icons.calendar_month_outlined),
                ),

                // date range
                IconButton(
                  onPressed: () async {
                    // var res = await showDateRangePicker(
                    //   context: context,
                    //   firstDate: DateTime(2020),
                    //   lastDate: DateTime.now(),
                    //   // initialDateRange: ,
                    // );

                    // if (res != null) {}
                  },
                  icon: Icon(Icons.date_range),
                ),
              ],
            );
          }),
    );
  }

//

  // date picker
  Widget payment_date_picker_tile(GroupPaymentHistoryModel rec) {
    bool active = rec.date == active_payment_date.value;

    return InkWell(
      key: Key(rec.date),
      onTap: () {
        main_payment_record.value = rec.record;
        active_payment_date.value = rec.date;
      },
      child: Container(
        decoration: BoxDecoration(
          color: active ? Colors.blueAccent : Colors.grey.shade500,
          borderRadius: BorderRadius.circular(3),
        ),
        width: 140,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        margin: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Center(
          child: Text(
            rec.date,
            style: TextStyle(
              fontSize: 14,
              color: active ? Colors.white : Colors.white,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget assessment_date_picker_tile(GroupCaseFileModel rec) {
    bool active = rec.date == active_assessment_date.value;

    return InkWell(
      onTap: () {
        main_assessment.value = rec.record;
        active_assessment_date.value = rec.date;
      },
      child: Container(
        decoration: BoxDecoration(
          color: active ? Colors.blueAccent : Colors.grey.shade500,
          borderRadius: BorderRadius.circular(3),
        ),
        width: 140,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        margin: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Center(
          child: Text(
            rec.date,
            style: TextStyle(
              fontSize: 14,
              color: active ? Colors.white : Colors.white,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget treatment_date_picker_tile(GroupCaseFileModel rec) {
    bool active = rec.date == active_treatment_date.value;

    return InkWell(
      onTap: () {
        main_treatment.value = rec.record;
        active_treatment_date.value = rec.date;
      },
      child: Container(
        decoration: BoxDecoration(
          color: active ? Colors.blueAccent : Colors.grey.shade500,
          borderRadius: BorderRadius.circular(3),
        ),
        width: 140,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        margin: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Center(
          child: Text(
            rec.date,
            style: TextStyle(
              fontSize: 14,
              color: active ? Colors.white : Colors.white,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  //

  // record list
  Widget payment_record_list() {
    return ValueListenableBuilder(
        valueListenable: main_payment_record,
        builder: (context, record_value, child) {
          if (record_value.isEmpty)
            return Expanded(
                child: Center(
              child: Text(
                'No Record to view',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ));

          int total = record_value.fold(0, (prev, elem) => prev + elem.amount);

          record_value.sort((a, b) => b.date.compareTo(a.date));

          return Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: record_value.length,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) =>
                        payment_record_tile(record_value[index]),
                  ),
                ),

                // totals
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 17,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SelectableText(
                        Helpers.format_amount(total, naira: true),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget assessment_record_list() {
    return ValueListenableBuilder(
        valueListenable: main_assessment,
        builder: (context, record_value, child) {
          if (record_value.isEmpty)
            return Expanded(
                child: Center(
              child: Text(
                'No Record to view',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ));

          int total = record_value.length;

          record_value
              .sort((a, b) => b.treatment_date!.compareTo(a.treatment_date!));

          return Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: record_value.length,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) =>
                        clinic_record_tile(record_value[index]),
                  ),
                ),

                // totals
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total assessment seesion:',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 17,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SelectableText(
                        Helpers.format_amount(total),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget treatment_record_list() {
    return ValueListenableBuilder(
        valueListenable: main_treatment,
        builder: (context, record_value, child) {
          if (record_value.isEmpty)
            return Expanded(
                child: Center(
              child: Text(
                'No Record to view',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ));

          int total = record_value.length;

          record_value
              .sort((a, b) => b.treatment_date!.compareTo(a.treatment_date!));

          return Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: record_value.length,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) =>
                        clinic_record_tile(record_value[index]),
                  ),
                ),

                // totals
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total treatment session:',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 17,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SelectableText(
                        Helpers.format_amount(total),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

//

  // payment_record_tile
  Widget payment_record_tile(PaymentHistoryModel record) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // type & date
          Row(
            children: [
              Expanded(
                child: Text(
                  record.hist_type.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),

              const Expanded(child: SizedBox()),

              // date
              Text(
                '${DateFormat.jm().format(record.date).toLowerCase()}, ${DateFormat('dd MMM, yyyy').format(record.date)}',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          // name & amount
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  '${record.patient.f_name} ${record.patient.l_name}',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Colors.white70,
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
              Text(
                Helpers.format_amount(record.amount, naira: true),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget clinic_record_tile(CaseFileModel record) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // type & date
          Row(
            children: [
              Expanded(
                child: Text(
                  record.case_type.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),

              const Expanded(child: SizedBox()),

              // date
              Text(
                '${DateFormat.jm().format(record.treatment_date!).toLowerCase()}, ${DateFormat('dd MMM, yyyy').format(record.treatment_date!)}',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          // patient & duration
          Row(
            children: [
              Text(
                'Patient:',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: SelectableText(
                  '${record.patient.f_name} ${record.patient.l_name}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              // const Expanded(child: SizedBox()),
              Text(
                'Duration: ',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                Helpers.get_duration(record.start_time, record.end_time),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          // doctor
          Row(
            children: [
              Text(
                'Doctor:',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: SelectableText(
                  '${record.doctor.user.f_name} ${record.doctor.user.l_name}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

//

  //
}

class GroupPaymentHistoryModel {
  String date;
  List<PaymentHistoryModel> record;

  GroupPaymentHistoryModel({
    required this.date,
    required this.record,
  });
}

class GroupCaseFileModel {
  String date;
  List<CaseFileModel> record;

  GroupCaseFileModel({
    required this.date,
    required this.record,
  });
}
