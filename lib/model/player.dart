enum DocKeyPlayer {
  playerID,
  creationDate,
  lifetimeScore,
  answersGuessed,
  wins,
  gamesPlayed,
  friends,
}

class Player {
  static const PLAYER_ID = 'playerID';
  static const CREATION_DATE = 'creationDate';
  static const LIFETIME_SCORE = 'lifetimeScore';
  static const ANSWERS_GUESSED = 'answersGuessed';
  static const WINS = 'wins';
  static const GAMES_PLAYED = 'gamesPlayed';
  static const FRIENDS = 'friends';

  String? docID;
  late String playerID;
  DateTime? creationDate;
  late int lifetimeScore;
  late List<dynamic> answersGuessed;
  late int wins;
  late int gamesPlayed;
  late List<dynamic> friends;

  Player({
    this.docID,
    this.playerID = '',
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

  Player.clone(Player p) {
    docID = p.docID;
    playerID = p.playerID;
    creationDate = p.creationDate;
    lifetimeScore = p.lifetimeScore;
    answersGuessed = [...p.answersGuessed];
    wins = p.wins;
    gamesPlayed = p.gamesPlayed;
    friends = [...p.friends];
  }

  void assign(Player p) {
    docID = p.docID;
    playerID = p.playerID;
    creationDate = p.creationDate;
    lifetimeScore = p.lifetimeScore;
    answersGuessed = [...p.answersGuessed];
    wins = p.wins;
    gamesPlayed = p.gamesPlayed;
    friends = [...p.friends];
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyPlayer.playerID.name: playerID,
      DocKeyPlayer.creationDate.name: creationDate,
      DocKeyPlayer.lifetimeScore.name: lifetimeScore,
      DocKeyPlayer.answersGuessed.name: answersGuessed,
      DocKeyPlayer.wins.name: wins,
      DocKeyPlayer.gamesPlayed.name: gamesPlayed,
      DocKeyPlayer.friends.name: friends,
    };
  }

  static Player? fromFirestoreDoc(
      {required Map<String, dynamic> doc, required String docID}) {
    return Player(
      docID: docID,
      playerID: doc[DocKeyPlayer.playerID.name] ?? 'N/A',
      creationDate: doc[DocKeyPlayer.creationDate.name] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[DocKeyPlayer.creationDate.name].millisecondsSinceEpoch,
            )
          : DateTime.now(),
      lifetimeScore: doc[DocKeyPlayer.lifetimeScore.name] ?? 0,
      answersGuessed: doc[DocKeyPlayer.answersGuessed.name] ?? [],
      wins: doc[DocKeyPlayer.wins.name] ?? 0,
      gamesPlayed: doc[DocKeyPlayer.gamesPlayed.name] ?? 0,
      friends: doc[DocKeyPlayer.friends.name] ?? [],
    );
  }
}
