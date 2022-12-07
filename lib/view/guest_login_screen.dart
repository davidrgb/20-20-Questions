import 'package:flutter/material.dart';

class GuestLoginScreen extends StatefulWidget {
  static const routeName = '/guestLoginScreen';

  const GuestLoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GuestLoginScreenState();
}

class _GuestLoginScreenState extends State<GuestLoginScreen> {
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
              child: const Text('Guest Login Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Controller {
  late _GuestLoginScreenState state;
  _Controller(this.state);
}
