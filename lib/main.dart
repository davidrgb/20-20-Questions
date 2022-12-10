import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:twenty_twenty_questions/model/constant.dart';
import 'package:twenty_twenty_questions/view/guest_login_screen.dart';
import 'package:twenty_twenty_questions/view/home_screen.dart';
import 'package:twenty_twenty_questions/view/lobby_list_screen.dart';
import 'package:twenty_twenty_questions/view/player_login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const QuestionsApp());
}

class QuestionsApp extends StatelessWidget {
  const QuestionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '20/20 Questions',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.amber,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(170, 50),
              maximumSize: const Size(220, 90),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            ),
          ),
          textTheme: const TextTheme(
            button: TextStyle(fontSize: 18),
          ),
        ),
        initialRoute: HomeScreen.routeName,
        routes: {
          HomeScreen.routeName: (context) => const HomeScreen(),
          PlayerLoginScreen.routeName: (context) => const PlayerLoginScreen(),
          GuestLoginScreen.routeName: (context) => const GuestLoginScreen(),
          LobbyListScreen.routeName: (context) {
            Object? args = ModalRoute.of(context)?.settings.arguments;
            if (args == null) {
              print("ARGS IS NULL FOR LOBBY LIST SCREEN");
            }
            var arguments = args as Map;
            var player = arguments[ARGS.PLAYER];
            return LobbyListScreen(
              player: player,
            );
          },
        });
  }
}
