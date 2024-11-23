import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/gym/Widgets/qr_code_dialog.dart';
import 'package:heritage_soft/widgets/text_field.dart';

class GetBarcode extends StatefulWidget {
  final List<ClientListModel> clients;
  const GetBarcode({super.key, required this.clients});

  @override
  State<GetBarcode> createState() => _GetBarcodeState();
}

class _GetBarcodeState extends State<GetBarcode> {
  TextEditingController id_controller = TextEditingController();

  List<ClientListModel> clients = [];

  @override
  void initState() {
    clients = widget.clients;
    super.initState();
  }

  @override
  void dispose() {
    id_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 3, 25, 43),
        foregroundColor: Colors.white,
        title: Text('Get Barcode'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: InkWell(onTap: () {}, child: Icon(Icons.barcode_reader)),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 3, 25, 43),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'images/logo.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 50),

            // label
            Text(
              'Enter client ID below to view QR Code',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),

            SizedBox(height: 50),

            // textfield
            Container(
              width: 200,
              child: Text_field(controller: id_controller),
            ),

            SizedBox(height: 30),

            // view button
            InkWell(
              onTap: () async {
                var chk = clients.where((e) =>
                    e.id!.toLowerCase() ==
                    id_controller.text.trim().toLowerCase());

                if (chk.isNotEmpty) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => QRCodeDialog(user_id: chk.first.id!),
                  );
                } else {
                  Helpers.showToast(
                    context: context,
                    color: Colors.red,
                    toastText: 'ID not found',
                    icon: Icons.error,
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                width: 200,
                height: 40,
                child: Center(
                  child: Text(
                    'View Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
