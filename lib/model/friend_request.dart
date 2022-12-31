enum DocKeyFriendRequest {
  senderID,
  receiverID,
  response,
}

class FriendRequest {
  static const SENDER_ID = 'senderID';
  static const RECEIVER_ID = 'receiverID';
  static const RESPONSE = 'response';

  late String senderID;
  late String receiverID;
  late bool response;

  FriendRequest({
    required this.senderID,
    required this.receiverID,
    required this.response,
  });

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyFriendRequest.senderID.name: senderID,
      DocKeyFriendRequest.receiverID.name: receiverID,
      DocKeyFriendRequest.response.name: response,
    };
  }

  static FriendRequest? fromFirestoreDoc({
    required Map<String, dynamic> doc,
  }) {
    return FriendRequest(
      senderID: doc[DocKeyFriendRequest.senderID.name] ?? 'N/A',
      receiverID: doc[DocKeyFriendRequest.receiverID.name] ?? 'N/A',
      response: doc[DocKeyFriendRequest.response.name] ?? false,
    );
  }
}
