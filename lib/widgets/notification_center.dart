import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/pages/gym/client_pofile_page.dart';

class NotificationCenter extends StatefulWidget {
  final ClientSignInModel? client;
  const NotificationCenter({super.key, this.client});

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
        valueListenable: notification_height,
        builder: (context, val, child) {
          if (notification_height.value == 90)
            Future.delayed(Duration(seconds: 8), () {
              notification_height.value = 0;
            });
          return Dismissible(
            key: Key('notification'),
            confirmDismiss: (d) async {
              notification_height.value = 0;
              return false;
            },
            direction: DismissDirection.up,
            child: AnimatedContainer(
              height: notification_height.value,
              onEnd: () {},
              duration: Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.only(top: 10),
                height: 70,
                width: 300,
                child: widget.client != null ? list_tile(widget.client!) : null,
              ),
            ),
          );
        });
  }

  // client list tile
  Widget list_tile(ClientSignInModel client) {
    return Card(
      borderOnForeground: false,
      elevation: 0,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            custom_context!,
            MaterialPageRoute(
              builder: (context) => ClientProfilePage(cl_id: client.key),
            ),
          );
          notification_height.value = 0;
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              // profile image
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Color(0xFFf97ecf),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: client.user_image.isEmpty
                      ? Image.asset(
                          'images/icon/user-alt.png',
                          width: 25,
                          height: 25,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            client.user_image,
                            height: 45,
                            width: 45,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),

              SizedBox(width: 10),

              // user details
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // id & subscription
                    Row(
                      children: [
                        // id
                        Text(
                          client.id,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),

                        Expanded(child: Container()),

                        // subscription
                        client.sub_plan.isNotEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Color(0xFF3C58E6).withOpacity(0.67),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'images/icon/map-gym.png',
                                      width: 10,
                                      height: 10,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      client.sub_plan,
                                      style: TextStyle(
                                        fontSize: 8,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),

                    SizedBox(height: 2),

                    // name
                    Text(
                      client.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        height: 1,
                      ),
                    ),

                    SizedBox(height: 4),

                    // status
                    Container(
                      width: 74,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color:
                            Color(client.sub_status ? 0xFF88ECA9 : 0xFFFF5252)
                                .withOpacity(0.67),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.circle,
                              color: Color(
                                  client.sub_status ? 0xFF19F763 : 0xFFFF5252),
                              size: 8),
                          SizedBox(width: 4),
                          Text(
                            client.sub_status ? 'Active' : 'Inactive',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              //
            ],
          ),
        ),
      ),
    );
  }
}
