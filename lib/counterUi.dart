import "package:flutter/material.dart";
import "package:agent_dart/agent_dart.dart";
import "counter.dart";

void main() {
  runApp(CanisterApp());
}

class CanisterApp extends StatefulWidget {
  CanisterApp({key}) : super(key: key);

  @override
  _CanisterAppState createState() => _CanisterAppState();
}

class _CanisterAppState extends State<CanisterApp> {
  int _counter = 0;
  bool _loading = false;
  String? _error;
  String? _status;
  Counter? counter;
  Identity? _identity;

  @override
  void initState() {
    initCounter();
    super.initState();
  }

  Future<void> initCounter({Identity? identity}) async {
    counter = Counter(
        cansiterId: "rrkah-fqaaa-aaaaa-aaaaq-cai",
        url: "http://loaclhost:8000");
    // await if user is logged in and principal identity is fetched
    await getValue();
  }

  Future<void> getValue() async {
    var counterValue = await counter?.getValue();
    setState(() {
      _error = null;
      _counter = counterValue ?? _counter;
      _loading = false;
    });
  }

Future<void> _incrementCounter() async {
  setState(() {
    _loading = true;
  });
  try {
    await counter?.increment();
    await getValue();
  } catch (e) {
    setState(() {
      _error = e.toString();
      _loading = false;
    });
  }
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Counter App'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _status ?? '',
          ),
          Text(
            _error ?? 'The canister counter is now:',
          ),
          Text(
            _loading ? 'loading...' : '$_counter',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _incrementCounter,
      tooltip: 'Increment',
      child: Icon(Icons.add),
    ), // This trailing comma makes auto-formatting nicer for build methods.
  );
}}