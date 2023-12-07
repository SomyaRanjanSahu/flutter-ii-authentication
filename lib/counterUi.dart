import 'counter.dart';
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:agent_dart/agent_dart.dart";

class CanisterApp extends StatefulWidget {
  final String principalId;
  CanisterApp({Key? key, required this.principalId}) : super(key: key);

  @override
  _CanisterAppState createState() => _CanisterAppState();
}

class _CanisterAppState extends State<CanisterApp> {
  int _counter = 0;
  bool _loading = false;
  Counter? counter;

  @override
  void initState() {
    initCounter();
    super.initState();
  }

  Future<void> initCounter({Identity? identity}) async {
    counter = Counter(
        canisterId: 'bkyz2-fmaaa-aaaaa-qaaaq-cai',
        url: 'https://6773-171-78-253-193.ngrok-free.app',
        principalId: widget.principalId,);
    await counter?.setAgent();
    await getValue();
  }

  Future<void> getValue() async {
    var counterValue = await counter?.getValue();
    setState(() {
      _counter = counterValue ?? _counter;
      _loading = false;
    });
  }

  Future<void> _incrementCounter() async {
    setState(() {
      _loading = true;
    });
    await counter?.increment();
    await getValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter App'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'The canister counter is now:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              _loading ? 'loading...' : '$_counter',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
