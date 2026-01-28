import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Map<String, dynamic> _firestoreFieldsToJson(Map<String, dynamic> fields) {
  final Map<String, dynamic> json = {};

  fields.forEach((key, value) {
    json[key] = _parseFirestoreValue(value);
  });

  return json;
}

dynamic _parseFirestoreValue(Map<String, dynamic> value) {
  if (value.containsKey('stringValue')) return value['stringValue'];
  if (value.containsKey('integerValue'))
    return int.parse(value['integerValue']);
  if (value.containsKey('doubleValue')) return value['doubleValue'];
  if (value.containsKey('booleanValue')) return value['booleanValue'];
  if (value.containsKey('nullValue')) return null;

  if (value.containsKey('mapValue')) {
    final fields = value['mapValue']['fields'] ?? {};
    return _firestoreFieldsToJson(Map<String, dynamic>.from(fields));
  }

  if (value.containsKey('arrayValue')) {
    final values = value['arrayValue']['values'] ?? [];
    return values.map((v) => _parseFirestoreValue(v)).toList();
  }

  if (value.containsKey('timestampValue')) {
    return DateTime.parse(value['timestampValue']);
  }

  return null;
}


/// Save JSON to a file
void saveToJsonFile(String filePath, dynamic data) {
  final file = File(filePath);
  final jsonString = const JsonEncoder.withIndent('  ').convert(data);
  file.writeAsStringSync(jsonString);
  print('✅ JSON saved to $filePath');
}

/// Fetch all clients
Future<Map<String, Map<String, dynamic>>> getAllClients({
  required String projectId,
  required String collectionName,
  String? authToken,
}) async {
  final headers = <String, String>{
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  final Map<String, Map<String, dynamic>> clientsMap = {};
  String? pageToken;

  do {
    final url = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$collectionName'
      '?pageSize=500'
      '${pageToken != null ? '&pageToken=$pageToken' : ''}',
    );

    final response = await http.get(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Firestore error: ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    final List docs = decoded['documents'] ?? [];

    for (final doc in docs) {
      final name = doc['name'];
      final id = name.split('/').last;
      clientsMap[id] = {
        'doc_name': id,
        ..._firestoreFieldsToJson(doc['fields']),
        'sub_history': <Map<String, dynamic>>[],
      };
    }

    pageToken = decoded['nextPageToken'];
  } while (pageToken != null);

  return clientsMap;
}

/// Fetch sub-history for a single client
Future<List<Map<String, dynamic>>> fetchSubHistoryForClient(
    String projectId, String clientId,
    {String? authToken}) async {
  final headers = <String, String>{
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  final url = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/Clients/$clientId/Sub History?pageSize=1000');

  final response = await http.get(url, headers: headers);

  if (response.statusCode != 200) {
    throw Exception(
        'Firestore error fetching sub-history for $clientId: ${response.body}');
  }

  final decoded = jsonDecode(response.body);
  final List documents = decoded['documents'] ?? [];

  return documents.map<Map<String, dynamic>>((doc) {
    final fields = doc['fields'] as Map<String, dynamic>;
    return _firestoreFieldsToJson(fields);
  }).toList();
}

/// Retry wrapper for fetching sub-history
Future<List<Map<String, dynamic>>> fetchSubHistoryWithRetry(
    String projectId, String clientId,
    {String? authToken, int retries = 3}) async {
  for (int attempt = 1; attempt <= retries; attempt++) {
    try {
      return await fetchSubHistoryForClient(projectId, clientId,
          authToken: authToken);
    } catch (e) {
      print('⚠️ Attempt $attempt failed for $clientId: $e');
      if (attempt == retries) rethrow;
      await Future.delayed(const Duration(seconds: 2));
    }
  }
  return [];
}

/// Full gggt pipeline
Future<void> gggt({
  String projectId = "heritage-soft",
  String collectionName = "Clients",
  String? authToken,
}) async {
  print('Started fetching clients...');

  final clientsMap = await getAllClients(
    projectId: projectId,
    collectionName: collectionName,
    authToken: authToken,
  );
  print('Clients fetched: ${clientsMap.length}');

  // Fetch sub-history in batches to avoid network timeout
  final batchSize = 10; // adjust depending on network
  final clientIds = clientsMap.keys.toList();

  for (int i = 0; i < clientIds.length; i += batchSize) {
    final batch = clientIds.sublist(
      i,
      i + batchSize > clientIds.length ? clientIds.length : i + batchSize,
    );

    final results = await Future.wait(batch.map((clientId) =>
        fetchSubHistoryWithRetry(projectId, clientId, authToken: authToken)));

    for (int j = 0; j < batch.length; j++) {
      clientsMap[batch[j]]!['sub_history'] = results[j];
    }

    print(
        'Fetched sub-history for clients ${i + 1} to ${i + batch.length} / ${clientIds.length}');
  }

  print('Saving JSON...');
  saveToJsonFile('./clients_export.json', clientsMap);
  print('✅ Done! JSON saved with all clients and sub-history.');
}
