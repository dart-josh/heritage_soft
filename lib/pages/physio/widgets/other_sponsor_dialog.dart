import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/widgets/text_field.dart';

class SponsorDialog extends StatefulWidget {
  final SponsorModel? sponsor;
  final bool view_only;
  const SponsorDialog({super.key, this.sponsor, this.view_only = false});

  @override
  State<SponsorDialog> createState() => _SponsorDialogState();
}

class _SponsorDialogState extends State<SponsorDialog> {
  TextEditingController sponsor_name_controller = TextEditingController();
  TextEditingController sponsor_phone_controller = TextEditingController();
  TextEditingController sponsor_role_controller = TextEditingController();
  TextEditingController sponsor_addr_controller = TextEditingController();

  @override
  void initState() {
    assign_controllers();
    super.initState();
  }

  @override
  void dispose() {
    sponsor_name_controller.dispose();
    sponsor_phone_controller.dispose();
    sponsor_role_controller.dispose();
    sponsor_addr_controller.dispose();
    super.dispose();
  }

  void assign_controllers() {
    if (widget.sponsor == null) return;

    sponsor_name_controller.text = widget.sponsor!.name;
    sponsor_phone_controller.text = widget.sponsor!.phone;
    sponsor_role_controller.text = widget.sponsor!.role;
    sponsor_addr_controller.text = widget.sponsor!.address;
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
                      (widget.view_only)
                          ? 'Sponsor details'
                          : (widget.sponsor == null)
                              ? 'Add Sponsor'
                              : 'Edit Sponsor',
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
                    children: [
                      // sponsor name
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text_field(
                          label: 'Sponsor Fullname',
                          controller: sponsor_name_controller,
                          require: !widget.view_only,
                          edit: widget.view_only,
                        ),
                      ),

                      // sponsor no.
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text_field(
                          label: 'Sponsor Phone no.',
                          controller: sponsor_phone_controller,
                          format: [FilteringTextInputFormatter.digitsOnly],
                          edit: widget.view_only,
                        ),
                      ),

                      // sponsor role
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text_field(
                          label: 'Sponsor Role',
                          controller: sponsor_role_controller,
                          edit: widget.view_only,
                        ),
                      ),

                      // sponsor address
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text_field(
                          label: 'Sponsor Address',
                          controller: sponsor_addr_controller,
                          maxLine: 3,
                          edit: widget.view_only,
                        ),
                      ),

                      if (!widget.view_only) SizedBox(height: 20),

                      // submit button
                      if (!widget.view_only)
                        InkWell(
                          onTap: () async {
                            if (sponsor_name_controller.text.isEmpty) {
                              Helpers.showToast(
                                context: context,
                                color: Colors.redAccent,
                                toastText: 'Enter sponsor name',
                                icon: Icons.error,
                              );
                              return;
                            }

                            if ((sponsor_phone_controller.text.isNotEmpty) &&
                                (sponsor_phone_controller.text.length > 11 ||
                                    sponsor_phone_controller.text.length <
                                        10)) {
                              Helpers.showToast(
                                context: context,
                                color: Colors.redAccent,
                                toastText: 'Sponsor contact Invalid',
                                icon: Icons.error,
                              );
                              return;
                            }

                            bool? res = await showDialog(
                              context: context,
                              builder: (context) => ConfirmDialog(
                                title: 'Submit details',
                                subtitle: 'Are you sure you want to proceed?',
                              ),
                            );

                            if (res != null && res) {
                              SponsorModel sponsorModel = SponsorModel(
                                name:
                                    sponsor_name_controller.text.trim(),
                                phone:
                                    sponsor_phone_controller.text.trim(),
                                address:
                                    sponsor_addr_controller.text.trim(),
                                role:
                                    sponsor_role_controller.text.trim(),
                              );

                              Navigator.pop(context, sponsorModel);
                            }
                          },
                          child: Container(
                            width: 300,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  widget.sponsor == null
                                      ? 'Add Sponsor'
                                      : 'Update SPonsor',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: 10),
                    ],
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
