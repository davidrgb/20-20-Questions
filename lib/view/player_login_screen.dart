import 'package:flutter/material.dart';

class PlayerLoginScreen extends StatefulWidget {
  static const routeName = '/playerLoginScreen';

  const PlayerLoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerLoginScreenState();
}

class _PlayerLoginScreenState extends State<PlayerLoginScreen> {
  late _Controller controller;

  void render(fn) => setState(fn);

  @override
  void initState() {
    super.initState();
    controller = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(50),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Player Login Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Controller {
  late _PlayerLoginScreenState state;
  _Controller(this.state);
}
