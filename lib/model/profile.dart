enum DocKeyProfile {
  playerID,
  username,
  creationDate,
  lifetimeScore,
  answersGuessed,
  wins,
  gamesPlayed,
  friends,
}

class Profile {
  static const PLAYER_ID = 'playerID';
  static const USERNAME = 'username';
  static const CREATION_DATE = 'creationDate';
  static const LIFETIME_SCORE = 'lifetimeScore';
  static const ANSWERS_GUESSED = 'answersGuessed';
  static const WINS = 'wins';
  static const GAMES_PLAYED = 'gamesPlayed';
  static const FRIENDS = 'friends';

  String? docID;
  late String playerID;
  late String username;
  DateTime? creationDate;
  late int lifetimeScore;
  late List<dynamic> answersGuessed;
  late int wins;
  late int gamesPlayed;
  late List<dynamic> friends;

  Profile({
    this.docID,
    this.playerID = '',
    this.username = '',
    this.creationDate,
    this.lifetimeScore = 0,
    List<dynamic>? answersGuessed,
    this.wins = 0,
    this.gamesPlayed = 0,
    List<dynamic>? friends,
  }) {
    this.answersGuessed = answersGuessed == null ? [] : [...answersGuessed];
    this.friends = friends == null ? [] : [...friends];
  }

  Profile.clone(Profile p) {
    docID = p.docID;
    playerID = p.playerID;
    username = p.username;
    creationDate = p.creationDate;
    lifetimeScore = p.lifetimeScore;
    answersGuessed = [...p.answersGuessed];
    wins = p.wins;
    gamesPlayed = p.gamesPlayed;
    friends = [...p.friends];
  }

  void assign(Profile p) {
    docID = p.docID;
    playerID = p.playerID;
    username = p.username;
    creationDate = p.creationDate;
    lifetimeScore = p.lifetimeScore;
    answersGuessed = [...p.answersGuessed];
    wins = p.wins;
    gamesPlayed = p.gamesPlayed;
    friends = [...p.friends];
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyProfile.playerID.name: playerID,
      DocKeyProfile.username.name: username,
      DocKeyProfile.creationDate.name: creationDate,
      DocKeyProfile.lifetimeScore.name: lifetimeScore,
      DocKeyProfile.answersGuessed.name: answersGuessed,
      DocKeyProfile.wins.name: wins,
      DocKeyProfile.gamesPlayed.name: gamesPlayed,
      DocKeyProfile.friends.name: friends,
    };
  }

  static Profile? fromFirestoreDoc(
      {required Map<String, dynamic> doc, required String docID}) {
    return Profile(
      docID: docID,
      playerID: doc[DocKeyProfile.playerID.name] ?? 'N/A',
      username: doc[DocKeyProfile.username.name] ?? 'N/A',
      creationDate: doc[DocKeyProfile.creationDate.name] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[DocKeyProfile.creationDate.name].millisecondsSinceEpoch,
            )
          : DateTime.now(),
      lifetimeScore: doc[DocKeyProfile.lifetimeScore.name] ?? 0,
      answersGuessed: doc[DocKeyProfile.answersGuessed.name] ?? [],
      wins: doc[DocKeyProfile.wins.name] ?? 0,
      gamesPlayed: doc[DocKeyProfile.gamesPlayed.name] ?? 0,
      friends: doc[DocKeyProfile.friends.name] ?? [],
    );
  }
}
