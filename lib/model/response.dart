enum DocKeyResponse {
  responsePlayerID,
  response,
}

class Response {
  static const RESPONSE_PLAYER_ID = 'responsePlayerID';
  static const RESPONSE = 'response';

  late String responsePlayerID;
  late String response;

  Response({
    required this.responsePlayerID,
    required this.response,
  });

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyResponse.responsePlayerID.name: responsePlayerID,
      DocKeyResponse.response.name: response,
    };
  }

  static Response? fromFirestoreDoc({
    required Map<String, dynamic> doc,
  }) {
    return Response(
      responsePlayerID: doc[DocKeyResponse.responsePlayerID.name] ?? 'N/A',
      response: doc[DocKeyResponse.response.name] ?? 'N/A',
    );
  }
}
