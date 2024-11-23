import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/widgets/text_field.dart';
import 'package:intl/intl.dart';

class SessionPaymentDialog extends StatefulWidget {
  final Map session_details;
  const SessionPaymentDialog({
    super.key,
    required this.session_details,
  });

  @override
  State<SessionPaymentDialog> createState() => _SessionPaymentDialogState();
}

class _SessionPaymentDialogState extends State<SessionPaymentDialog> {
  final TextEditingController add_session_controller = TextEditingController();
  final TextEditingController add_money_controller = TextEditingController();
  final TextEditingController discount_controller = TextEditingController();

  int current_cost = 0; // cost_p_session * total_session
  int cost_p_session = 0;
  int total_session = 0;
  int session_paid = 0;
  int amount_paid = 0;
  int floating_amount = 0; 

  int total_amount = 0;
  int total_active_session = 0;
  int new_floating = 0;

  bool use_session = true;

  int amount_to_pay = 0;
  int new_session = 0;
  int discount = 0;
  int discounted_amount = 0;

  // calculate session
  calculate_sessions() {
    // using session
    if (use_session) {
      if (add_session_controller.text.isNotEmpty) {
        int sess = int.parse(add_session_controller.text);

        if (sess == 0) return;

        int max_sess = total_session - session_paid;

        if (max_sess < 0) max_sess = 0;

        // above max
        if (sess > max_sess) {
          add_session_controller.text = max_sess.toString();
          new_session = max_sess;
          amount_to_pay = max_sess * cost_p_session;
        }

        // below max
        else {
          new_session = sess;
          amount_to_pay = sess * cost_p_session;
        }
      } else {
        new_session = 0;
        amount_to_pay = 0;
      }
    }

    // using amount
    else {
      if (add_money_controller.text.isNotEmpty) {
        int amt = int.parse(add_money_controller.text);
        int total_amt = amt + floating_amount;

        int sess = (total_amt / cost_p_session).truncate();
        new_session = sess;

        new_floating = total_amt - (sess * cost_p_session);
        amount_to_pay = amt;
      } else {
        new_session = 0;
        amount_to_pay = 0;
        new_floating = 0;
      }
    }

    apply_discount();
  }

  // apply discount
  apply_discount() {
    if (discount_controller.text.isNotEmpty) {
      discount = int.parse(discount_controller.text);
      discounted_amount = amount_to_pay - discount;

      if (discounted_amount < 0) {
        discount = amount_to_pay;
        discounted_amount = 0;
      }
    } else {
      discount = 0;
      discounted_amount = amount_to_pay;
    }

    setState(() {});
  }

  @override
  void initState() {
    cost_p_session = widget.session_details['cost_p_session'];
    total_session = widget.session_details['total_session'];
    session_paid = widget.session_details['session_paid'];
    amount_paid = widget.session_details['amount_paid'];
    floating_amount = widget.session_details['floating_amount'];

    current_cost = cost_p_session * (total_session - session_paid);

    add_session_controller.addListener(() {
      calculate_sessions();
    });
    add_money_controller.addListener(() {
      calculate_sessions();
    });
    discount_controller.addListener(() {
      apply_discount();
    });

    super.initState();
  }

  @override
  void dispose() {
    add_session_controller.dispose();
    add_money_controller.dispose();
    discount_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var val = NumberFormat('#,###');
    total_active_session = new_session + session_paid;
    total_amount = discounted_amount + amount_paid;

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 500,
        ),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade400.withOpacity(.9),
            borderRadius: BorderRadius.circular(6),
          ),
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
                        // heading
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Treatment Session payment',
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
                        'Use the form below to make payment for treatment sessions',
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

              SizedBox(height: 20),

              // session payment
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // current cost & cost/session
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // current cost
                          Column(
                            children: [
                              // label
                              Text(
                                'Current Cost',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              // value
                              Text(
                                '₦${val.format(current_cost)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),

                          // cost/session
                          Column(
                            children: [
                              // label
                              Text(
                                'Session Cost',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              // value
                              Text(
                                '₦${val.format(cost_p_session)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      // amount paid & floating amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // amount paid
                          Column(
                            children: [
                              // label
                              Text(
                                'Amount Paid',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              // value
                              Text(
                                '₦${val.format(amount_paid)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),

                          // floating amount
                          Column(
                            children: [
                              // label
                              Text(
                                'Floating amount',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              // value
                              Text(
                                '₦${val.format(floating_amount)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      // total session & session paid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // total session
                          Column(
                            children: [
                              // label
                              Text(
                                'Total Session',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              // total
                              Text(
                                '${val.format(total_session)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),

                          // session paid
                          Column(
                            children: [
                              // label
                              Text(
                                'Session Paid',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              // value
                              Text(
                                '${val.format(session_paid)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // new payment label
                      Text(
                        'New Payment',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 8),

                      // new payment
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            // add label
                            Text(
                              (use_session) ? 'Enter session' : 'Enter amount',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            Expanded(child: Container()),

                            // use session
                            if (use_session)
                              Container(
                                width: 60,
                                child: Text_field(
                                  controller: add_session_controller,
                                  text_align: TextAlign.center,
                                  format: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              )

                            // use amount
                            else
                              Container(
                                width: 120,
                                child: Text_field(
                                  controller: add_money_controller,
                                  format: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  prefix: Text('₦'),
                                ),
                              ),

                            SizedBox(width: 10),

                            IconButton(
                              onPressed: () {
                                use_session = !use_session;
                                new_floating = 0;

                                amount_to_pay = 0;
                                new_session = 0;
                                discount = 0;
                                discounted_amount = 0;

                                add_money_controller.clear();
                                add_session_controller.clear();
                                discount_controller.clear();

                                setState(() {});
                              },
                              icon: Icon(Icons.refresh),
                            ),
                            //
                          ],
                        ),
                      ),

                      SizedBox(height: 12),

                      // discount box
                      Container(
                        width: 100,
                        child: Text_field(
                          label: 'Discount',
                          center: true,
                          controller: discount_controller,
                          text_align: TextAlign.center,
                          format: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),

                      SizedBox(height: 20),

                      // total active session
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Text(
                              'Total Active Session:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              '${val.format(total_active_session)}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 2),

                      // floating amount
                      if (new_floating != 0)
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              Text(
                                'Floating:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(width: 3),
                              Text(
                                '₦${val.format(new_floating)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // amount to pay & session label
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // amount
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // session
                    Text(
                      'Session',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2),

              // amount to pay & session value
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // amount
                    Text(
                      '₦${val.format(discounted_amount)}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // session
                    Text(
                      '${val.format(new_session)}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15),

              // submit button
              InkWell(
                onTap: () async {
                  if (use_session && add_session_controller.text.isEmpty) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'Enter session',
                      icon: Icons.error,
                    );
                    return;
                  }

                  if (!use_session && add_money_controller.text.isEmpty) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'Enter amount',
                      icon: Icons.error,
                    );
                    return;
                  }

                  if (use_session && int.parse(add_session_controller.text) == 0) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'Session cannot be 0',
                      icon: Icons.error,
                    );
                    return;
                  }

                  if (!use_session && int.parse(add_money_controller.text) == 0) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'Amount cannot be 0',
                      icon: Icons.error,
                    );
                    return;
                  }

                  var conf = await showDialog(
                    context: context,
                    builder: (context) => ConfirmDialog(
                      title: 'Complete Payment',
                      subtitle:
                          'You about to submit this payment details, would you like to proceed?',
                    ),
                  );

                  Map map = {
                    'total_amount': total_amount,
                    'total_active_session': total_active_session,
                    'amount_to_pay': amount_to_pay,
                    'discounted_amount': discounted_amount,
                    'new_session': new_session,
                    'floating_amount': (!use_session) ? new_floating : floating_amount,
                  };

                  if (conf != null && conf) Navigator.pop(context, map);
                },
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                    color: Color(0xFF3c5bff).withOpacity(0.6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Center(
                    child: Text(
                      'Complete Payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
