import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:heritage_soft/datamodels/hmo_model.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/utils/test2.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

// /// Fetch all documents from a Firestore collection
// getFirestoreCollection({
//   String projectId = "heritage-soft",
//   String collectionName = "Clients", // "Gym HMO",
//   String? authToken, // Optional (Firebase Auth ID token)
// }) async {
//   final url = Uri.parse(
//     'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collectionName',
//   );

//   final headers = <String, String>{
//     'Content-Type': 'application/json',
//     if (authToken != null) 'Authorization': 'Bearer $authToken',
//   };

//   final response = await http.get(url, headers: headers);

//   if (response.statusCode != 200) {
//     throw Exception('Firestore error: ${response.body}');
//   }

//   final Map<String, Map<String, dynamic>> clientsMap = {};

//   final clientsDecoded = jsonDecode(response.body);
//   final List clientsDocs = clientsDecoded['documents'] ?? [];

//   for (final doc in clientsDocs) {
//     final name = doc['name']; // full path
//     final id = name.split('/').last;

//     clientsMap[id] = {
//       'doc_name': id,
//       ..._firestoreFieldsToJson(doc['fields']),
//       'sub_history': <Map<String, dynamic>>[],
//     };
//   }

//   //

//   final subHistoryResponse = await http.post(
//     Uri.parse(
//       'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents:runQuery',
//     ),
//     headers: headers,
//     body: jsonEncode({
//       "structuredQuery": {
//         "from": [
//           {"collectionId": "Sub History", "allDescendants": true}
//         ]
//       }
//     }),
//   );

//   final List subHistoryDecoded = jsonDecode(subHistoryResponse.body);

//   for (final row in subHistoryDecoded) {
//     if (row['document'] == null) continue;

//     final doc = row['document'];
//     final fullName = doc['name'];
//     final fields = _firestoreFieldsToJson(doc['fields']);

//     // path: Clients/{clientId}/Sub History/{subId}
//     final parts = fullName.split('/');
//     final clientId = parts[parts.indexOf('documents') + 2];

//     final client = clientsMap[clientId];
//     if (client != null) {
//       client['sub_history'].add(fields);
//     }
//   }

//   print(jsonEncode(clientsMap));
// }

// Map<String, dynamic> _firestoreFieldsToJson(Map<String, dynamic> fields) {
//   final Map<String, dynamic> json = {};

//   fields.forEach((key, value) {
//     json[key] = _parseFirestoreValue(value);
//   });

//   return json;
// }

// dynamic _parseFirestoreValue(Map<String, dynamic> value) {
//   if (value.containsKey('stringValue')) return value['stringValue'];
//   if (value.containsKey('integerValue'))
//     return int.parse(value['integerValue']);
//   if (value.containsKey('doubleValue')) return value['doubleValue'];
//   if (value.containsKey('booleanValue')) return value['booleanValue'];
//   if (value.containsKey('nullValue')) return null;

//   if (value.containsKey('mapValue')) {
//     final fields = value['mapValue']['fields'] ?? {};
//     return _firestoreFieldsToJson(Map<String, dynamic>.from(fields));
//   }

//   if (value.containsKey('arrayValue')) {
//     final values = value['arrayValue']['values'] ?? [];
//     return values.map((v) => _parseFirestoreValue(v)).toList();
//   }

//   if (value.containsKey('timestampValue')) {
//     return DateTime.parse(value['timestampValue']);
//   }

//   return null;
// }

// Future<Map<String, Map<String, dynamic>>> getAllClients({
//   required String projectId,
//   required String collectionName,
//   String? authToken,
// }) async {
//   final headers = <String, String>{
//     'Content-Type': 'application/json',
//     if (authToken != null) 'Authorization': 'Bearer $authToken',
//   };

//   String? pageToken;
//   final Map<String, Map<String, dynamic>> clientsMap = {};

//   do {
//     final url = Uri.parse(
//       'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collectionName'
//       '?pageSize=500'
//       '${pageToken != null ? '&pageToken=$pageToken' : ''}',
//     );

//     final response = await http.get(url, headers: headers);

//     if (response.statusCode != 200) {
//       throw Exception('Firestore error: ${response.body}');
//     }

//     final decoded = jsonDecode(response.body);
//     final List docs = decoded['documents'] ?? [];

//     for (final doc in docs) {
//       final name = doc['name'];
//       final id = name.split('/').last;

//       clientsMap[id] = {
//         'doc_name': id,
//         ..._firestoreFieldsToJson(doc['fields']),
//         'sub_history': <Map<String, dynamic>>[],
//       };
//     }

//     pageToken = decoded['nextPageToken'];
//   } while (pageToken != null);

//   return clientsMap;
// }

// Future<List<Map<String, dynamic>>> getAllSubHistory({
//   required String projectId,
//   String? authToken,
// }) async {
//   final headers = <String, String>{
//     'Content-Type': 'application/json',
//     if (authToken != null) 'Authorization': 'Bearer $authToken',
//   };

//   final List<Map<String, dynamic>> allSubHistory = [];
//   String? nextPageToken;

//   do {
//     final body = {
//       "structuredQuery": {
//         "from": [
//           {"collectionId": "Sub History", "allDescendants": true}
//         ],
//         "limit": 500, // max per request
//       },
//       if (nextPageToken != null) "pageToken": nextPageToken,
//     };

//     final response = await http.post(
//       Uri.parse(
//           'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents:runQuery'),
//       headers: headers,
//       body: jsonEncode(body),
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Firestore error: ${response.body}');
//     }

//     final List decoded = jsonDecode(response.body);

//     for (final row in decoded) {
//       if (row['document'] != null) {
//         allSubHistory.add(row['document']);
//       }
//     }

//     // Firestore doesn't always return nextPageToken for runQuery,
//     // you may need to adjust if using a cursor-based approach
//     nextPageToken = null; // ensures loop exits, adapt if you implement cursors
//   } while (nextPageToken != null);

//   return allSubHistory;
// }

// /// Fetch all sub-history documents for a given client
// Future<List<Map<String, dynamic>>> fetchSubHistoryForClient(
//   String projectId,
//   String clientId, {
//   String? authToken,
// }) async {
//   final headers = <String, String>{
//     'Content-Type': 'application/json',
//     if (authToken != null) 'Authorization': 'Bearer $authToken',
//   };

//   final url = Uri.parse(
//     'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/Clients/$clientId/Sub History?pageSize=1000',
//   );

//   final response = await http.get(url, headers: headers);

//   if (response.statusCode != 200) {
//     throw Exception('Firestore error fetching sub-history: ${response.body}');
//   }

//   final decoded = jsonDecode(response.body);

//   // The Firestore REST API returns a 'documents' list
//   final List documents = decoded['documents'] ?? [];

//   return documents.map<Map<String, dynamic>>((doc) {
//     final fields = doc['fields'] as Map<String, dynamic>;
//     return _firestoreFieldsToJson(fields); // your existing helper
//   }).toList();
// }


// g_ggt({
//   String projectId = "heritage-soft",
//   String collectionName = "Clients",
//   String? authToken,
// }) async {
//   print('Started fetching clients...');

//   final clientsMap = await getAllClients(
//     projectId: projectId,
//     collectionName: collectionName,
//     authToken: authToken,
//   );

//   print('Clients fetched: ${clientsMap.length}');

//   // Loop over each client and fetch its sub-history
//   int counter = 0;
//   for (final clientId in clientsMap.keys) {
//     final subHistoryDocs = await fetchSubHistoryForClient(
//       projectId,
//       clientId,
//       authToken: authToken,
//     );

//     clientsMap[clientId]!['sub_history'] = subHistoryDocs;

//     counter++;
//     if (counter % 50 == 0) {
//       print('Fetched sub-history for $counter clients...');
//     }
//   }

//   print('Saving JSON...');
//   saveToJsonFile('./clients_export.json', clientsMap);
//   print('✅ Done! JSON saved with all clients and sub-history.');
// }


// // lGwYimeuavWqd6LC7GjW
// __gggt({
//   String projectId = "heritage-soft",
//   String collectionName = "Clients",
//   String? authToken,
// }) async {
//   print('Started');

//   final clientsMap = await getAllClients(
//     projectId: projectId,
//     collectionName: collectionName,
//     authToken: authToken,
//   );

//   print('Clients fetched: ${clientsMap.length}');

//   final subHistoryDocs = await getAllSubHistory(
//     projectId: projectId,
//     authToken: authToken,
//   );

//   print('SubHistory fetched: ${subHistoryDocs.length}');

//   for (final doc in subHistoryDocs) {
//     final fullName = doc['name'];
//     final fields = _firestoreFieldsToJson(doc['fields']);

//     final parts = fullName.split('/');
//     final clientId = parts[parts.indexOf('documents') + 2];

//     clientsMap[clientId]?['sub_history'].add(fields);
//   }

//   print(clientsMap);
//   print('Saving JSON...');
//   saveToJsonFile('./lib/utils/clients_export.json', clientsMap);
//   print('Done!');
// }

// /// Save a JSON-serializable object to a file
// /// [filePath] = path including file name, e.g. "./clients_export.json"
// /// [data] = any JSON-serializable object (Map/List)
// void saveToJsonFile(String filePath, dynamic data) {
//   final file = File(filePath);

//   // Convert data to pretty-printed JSON string
//   final jsonString = const JsonEncoder.withIndent('  ').convert(data);

//   file.writeAsStringSync(jsonString);

//   print('✅ JSON saved to $filePath');
// }

// ?
Future<List<Map<String, dynamic>>> fetchNode(
  String databaseUrl,
  String node,
  String? authToken,
) async {
  final uri = Uri.parse(
    authToken == null
        ? '$databaseUrl/$node.json'
        : '$databaseUrl/$node.json?auth=$authToken',
  );

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }

  final decoded = jsonDecode(response.body) as Map<String, dynamic>?;

  if (decoded == null) return [];

  return decoded.entries
      .map((e) => {'id': e.key, ...Map<String, dynamic>.from(e.value)})
      .toList();
}

void tester(context) async {
  // setter(context);
  // return;
  Helpers.showLoadingScreen(context: context);
  await gggt(
      // projectId: 'your-project-id',
      // collectionName: 'users',
      );

  // final data = await fetchNode(
  //     'https://heritage-soft-default-rtdb.firebaseio.com', "Sub History", null);

  // print(jsonEncode(data));

  Navigator.pop(context);

  // print(jsonEncode(data));
}

List _lst = [
  {"days_week": 2, "hmo_name": "Leadway 2", "hmo_amount": 20000},
  {"hmo_amount": 30000, "hmo_name": "Leadway 3", "days_week": 3},
  {"hmo_amount": 8000, "days_week": 1, "hmo_name": "Reliance 1"},
  {"hmo_amount": 16000, "days_week": 2, "hmo_name": "Reliance 2"},
  {"hmo_amount": 24000, "hmo_name": "Reliance 3", "days_week": 3},
  {"days_week": 2, "hmo_name": "DOT", "hmo_amount": 20000},
  {"hmo_name": "AXA", "days_week": 2, "hmo_amount": 20000},
  {"hmo_amount": 10000, "hmo_name": "Bastion 1", "days_week": 1},
  {"hmo_amount": 20000, "days_week": 2, "hmo_name": "Bastion 2"}
];

void setter(context) async {
  for (var i = 0; i < _lst.length; i++) {
    var ele = _lst[i];
    HMO_Model hm = HMO_Model.fromMap(ele);

    // var vv =
    //     await GymDatabaseHelpers.add_update_hmo(context, data: hm.toJson());

    // if (vv)
    //   print('Done');
    // else
    //   print('-------------------');
  }
}
