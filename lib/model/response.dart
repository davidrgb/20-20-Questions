enum DocKeyResponse {
  responsePlayerUsername,
  response,
}

class Response {
  static const RESPONSE_PLAYER_USERNAME = 'responsePlayerUsername';
  static const RESPONSE = 'response';

  late String responsePlayerUsername;
  late String response;

  Response({
    required this.responsePlayerUsername,
    required this.response,
  });

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyResponse.responsePlayerUsername.name: responsePlayerUsername,
      DocKeyResponse.response.name: response,
    };
  }

  static Response? fromFirestoreDoc({
    required Map<String, dynamic> doc,
  }) {
    return Response(
      responsePlayerUsername: doc[DocKeyResponse.responsePlayerUsername.name] ?? 'N/A',
      response: doc[DocKeyResponse.response.name] ?? 'N/A',
    );
  }
}
