import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/db_helpers/clinic_api.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/clinic/patient_attendance_records.dart';

class PatientAttendancePage extends StatefulWidget {
  const PatientAttendancePage({super.key});

  @override
  State<PatientAttendancePage> createState() => _PatientAttendancePageState();
}

class _PatientAttendancePageState extends State<PatientAttendancePage> {
  final TextEditingController reasonController = TextEditingController();

  Map? selectedPatient;
  List patients = [];

  // Defaults to the current date.
  DateTime? selectedDate = DateTime.now();

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  String formatDate(DateTime? date) {
    if (date == null) return "";

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final rawPatients = AppData.get(context).patients;
    patients = rawPatients
        .map((p) => {
              "id": p.key,
              "patient_id": p.patient_id,
              "name": "${p.f_name} ${p.l_name}",
            })
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'images/background1.png',
              fit: BoxFit.cover,
            ),
          ),

          // Background overlay
          Positioned.fill(
            child: Container(
              color: const Color(0xFF202020).withOpacity(0.65),
            ),
          ),

          // Background blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 2,
                sigmaY: 2,
              ),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Main content
          Center(
            child: Container(
              width: width * 0.85 > 550 ? 550 : width * 0.85,
              height: height * 0.75 > 600 ? 600 : height * 0.75,
              decoration: BoxDecoration(
                color: const Color(0xFF202020).withOpacity(0.90),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              child: Column(
                children: [
                  topBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            Icons.assignment_ind_outlined,
                            size: 55,
                            color: Colors.blueAccent,
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Patient Attendance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Register a patient visit',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Field 1: Select patient
                          const Text(
                            'Select Patient',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 8),

                          InkWell(
                            onTap: selectPatient,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white24,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      selectedPatient == null
                                          ? 'Choose a patient'
                                          : '${selectedPatient!['patient_id']} - '
                                              '${selectedPatient!['name']}',
                                      style: TextStyle(
                                        color: selectedPatient == null
                                            ? Colors.white54
                                            : Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Field 2: Visit date
                          const Text(
                            'Visit Date',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 8),

                          InkWell(
                            onTap: selectDate,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white24,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      formatDate(selectedDate),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.edit_calendar_outlined,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Field 3: Reason for visit
                          const Text(
                            'Reason for Visit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextField(
                            controller: reasonController,
                            maxLines: 4,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter reason for the visit...',
                              hintStyle: const TextStyle(
                                color: Colors.white38,
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 55),
                                child: Icon(
                                  Icons.notes,
                                  color: Colors.white70,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.07),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.white24,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.white24,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blueAccent,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Register attendance
                          SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: registerAttendance,
                              icon: const Icon(
                                Icons.check_circle_outline,
                              ),
                              label: const Text(
                                'Register Attendance',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Please confirm the patient details '
                            'before registering.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 12,
                            ),
                          ),
                        ],
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

  // Top bar
  Widget topBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white24),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PatientAttendanceRecordsPage(),
                ),
              )
            },
            child: const Text(
              "Records",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  decoration: TextDecoration.underline),
            ),
          ),
          const Expanded(
            child: Text(
              'PATIENT REGISTRATION',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.cancel_outlined,
              color: Colors.white70,
              size: 27,
            ),
          ),
        ],
      ),
    );
  }

  // Editable visit date
  Future<void> selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select Visit Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Color(0xFF292929),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF292929),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        selectedDate = DateUtils.dateOnly(pickedDate);
      });
    }
  }

  // Patient selection dialog with search
  Future<void> selectPatient() async {
    String searchQuery = '';

    final patient = await showDialog<Map>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredPatients = patients.where((patient) {
              final name = patient['name'].toString().toLowerCase();
              final id = patient['patient_id'].toString().toLowerCase();
              final query = searchQuery.toLowerCase().trim();

              return name.contains(query) || id.contains(query);
            }).toList();

            return AlertDialog(
              backgroundColor: const Color(0xFF292929),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Select Patient',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field
                    TextField(
                      autofocus: true,
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                        });
                      },
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by name or patient ID...',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  setDialogState(() {
                                    searchQuery = '';
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white70,
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.07),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.white24,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.white24,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Filtered patient list
                    Flexible(
                      child: filteredPatients.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 30,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_search_outlined,
                                    color: Colors.white38,
                                    size: 40,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'No patients found',
                                    style: TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: filteredPatients.length,
                              separatorBuilder: (_, __) => const Divider(
                                color: Colors.white12,
                              ),
                              itemBuilder: (context, index) {
                                final patient = filteredPatients[index];

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFF343F60),
                                    child: Icon(
                                      Icons.person_outline,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    patient['name'].toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    patient['patient_id'].toString(),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white54,
                                  ),
                                  onTap: () {
                                    Navigator.pop(
                                      dialogContext,
                                      patient,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );

    if (patient != null && mounted) {
      setState(() {
        selectedPatient = patient;
      });
    }
  }

  // Register attendance
  void registerAttendance() async {
    if (selectedPatient == null) {
      showMessage('Please select a patient.');
      return;
    }

    // if (reasonController.text.trim().isEmpty) {
    //   showMessage('Please enter the reason for the visit.');
    //   return;
    // }

    final attendance = {
      'id': selectedPatient!['id'],
      'patient_id': selectedPatient!['patient_id'],
      'reason': reasonController.text,
      'date': selectedDate != null
          ? selectedDate?.toIso8601String()
          : DateTime.now().toIso8601String(),
    };

    try {
      var res = await ClinicApi.add_attendance(context,
          data: attendance, showLoading: true, showToast: true);

      // if (res.data == null) return;

      showMessage('Patient attendance registered successfully.', error: false);

      setState(() {
        selectedPatient = null;
        reasonController.clear();
        selectedDate = null;
      });
    } catch (e) {}
  }

  // Feedback message
  void showMessage(String message, {bool error = true}) {
    Helpers.showToast(
      context: context,
      color: error ? Colors.red : Colors.blueAccent,
      toastText: message,
      icon: error ? Icons.error : Icons.check,
    );
  }
}
