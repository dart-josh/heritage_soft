import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:heritage_soft/db_helpers/clinic_api.dart';

class PatientAttendanceRecordsPage extends StatefulWidget {
  const PatientAttendanceRecordsPage({super.key});

  @override
  State<PatientAttendanceRecordsPage> createState() =>
      _PatientAttendanceRecordsPageState();
}

class _PatientAttendanceRecordsPageState
    extends State<PatientAttendanceRecordsPage> {
  final TextEditingController searchController = TextEditingController();

  DateTime? selectedDate;

  List attendanceRecords = [];

  void get_attendance() async {
    final data = await ClinicApi.get_attendance(context);
    final data_att = data['attendance'] ?? [];

    var att = data_att.map((p) {
          var name = "${p['patient']['f_name']} ${p['patient']['l_name']}";

          return {
            'patient_id': p['patient_id'],
            'patient_name': name,
            'reason': p['reason'],
            'date': p['date'],
          };
        }).toList() ??
        [];

    attendanceRecords = att;
    setState(() {});
  }

  @override
  void initState() {
    get_attendance();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour >= 12 ? 'PM' : 'AM'}';
  }

  List get filteredRecords {
    final query = searchController.text.trim().toLowerCase();

    final results = attendanceRecords.where((record) {
      final name = record['patient_name'].toString().toLowerCase();
      final id = record['patient_id'].toString().toLowerCase();
      final reason = record['reason'].toString().toLowerCase();

      final matchesSearch = query.isEmpty ||
          name.contains(query) ||
          id.contains(query) ||
          reason.contains(query);

      final date = DateTime.tryParse(record['date'].toString());

      final matchesDate = selectedDate == null ||
          (date != null &&
              date.year == selectedDate!.year &&
              date.month == selectedDate!.month &&
              date.day == selectedDate!.day);

      return matchesSearch && matchesDate;
    }).toList();

    results.sort((a, b) {
      final dateA = DateTime.tryParse(a['date'].toString());
      final dateB = DateTime.tryParse(b['date'].toString());

      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'images/background1.png',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay
          Positioned.fill(
            child: Container(
              color: const Color(0xFF202020).withOpacity(0.70),
            ),
          ),

          // Blur
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
              width: width * 0.94 > 900 ? 900 : width * 0.94,
              height: height * 0.94,
              decoration: BoxDecoration(
                color: const Color(0xFF202020).withOpacity(0.94),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  topBar(),

                  // Compact heading
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.fact_check_outlined,
                          color: Colors.blueAccent,
                          size: 25,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Attendance Records',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${filteredRecords.length} records',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search and date picker on the same row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: TextField(
                              controller: searchController,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search patients...',
                                hintStyle: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.white60,
                                  size: 20,
                                ),
                                suffixIcon: searchController.text.isNotEmpty
                                    ? IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          searchController.clear();
                                          setState(() {});
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white60,
                                          size: 18,
                                        ),
                                      )
                                    : null,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.06),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide:
                                      const BorderSide(color: Colors.white24),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide:
                                      const BorderSide(color: Colors.white24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: const BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Compact date filter
                        InkWell(
                          onTap: selectDate,
                          borderRadius: BorderRadius.circular(7),
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_month_outlined,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  selectedDate == null
                                      ? 'Date'
                                      : formatDate(selectedDate!),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                if (selectedDate != null)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedDate = null;
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white60,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Attendance list gets the remaining height
                  Expanded(
                    child: filteredRecords.isEmpty
                        ? emptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                            itemCount: filteredRecords.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              return attendanceTile(filteredRecords[index]);
                            },
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

  Widget topBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white24),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'PATIENT ATTENDANCE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.cancel_outlined,
              color: Colors.white70,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // Simple date picker
  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        selectedDate = DateUtils.dateOnly(picked);
      });
    }
  }

  Widget attendanceTile(Map<String, dynamic> record) {
    final date = DateTime.tryParse(record['date'].toString());

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 19,
                backgroundColor: Color(0xFF343F60),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['patient_name'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      record['patient_id'].toString(),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_outline,
                color: Colors.greenAccent,
                size: 19,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            record['reason'].toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Colors.blueAccent,
                size: 13,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  date == null ? 'Invalid date' : formatDate(date),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ),
              if (date != null)
                Text(
                  formatTime(date),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 44,
              color: Colors.white.withOpacity(0.30),
            ),
            const SizedBox(height: 10),
            const Text(
              'No attendance records found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Try changing your search or date filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
