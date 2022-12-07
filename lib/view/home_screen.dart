import 'package:flutter/material.dart';
import 'package:twenty_twenty_questions/view/guest_login_screen.dart';
import 'package:twenty_twenty_questions/view/player_login_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/homeScreen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late _Controller controller;

  void render(fn) => setState(fn);

  @override
  void initState() {
    super.initState();
    controller = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.only(
            top: 100,
            bottom: 100,
          ),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              const Text(
                "20/20 Questions",
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.amber,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: controller.goToPlayerLogin,
                      child: const Text(
                        'Log In',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: controller.goToGuestLogin,
                      child: const Text(
                        'Play As Guest',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _HomeScreenState state;
  _Controller(this.state);

  void goToPlayerLogin() async {
    await Navigator.pushNamed(
      state.context,
      PlayerLoginScreen.routeName,
    );
  }

  void goToGuestLogin() async {
    await Navigator.pushNamed(
      state.context,
      GuestLoginScreen.routeName,
    );
  }
}
