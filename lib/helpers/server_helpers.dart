import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ServerHelpers {
  static bool is_socket_connected = false;

  static IO.Socket? socket;

  // start socket & listen
  static void start_socket_listerners() {
    socket = IO.io(server_url, {
      'transports': ['websocket'],
      "query": {'userID': ''}
    });

    socket!.connect();

    // ProductMaterials
    // socket!.on('ProductMaterials', (data) {
      
    // });

    // socket!.off('event', (data) {

    // });
  }

  // get all data
  static void get_all_data(context, {bool refresh = false}) {}

  // disconnect socket
  static void disconnect_socket() {
    if (socket != null) {
      socket!.close();
      socket!.destroy();
      socket!.dispose();
    }

    socket = null;
    is_socket_connected = false;
  }

  //
}
