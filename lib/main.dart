import 'dart:async';
import 'counterUi.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

void main() {
  runApp(MyApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: 'home',
      path: '/',
      builder: (context, state) => MyHomePage(),
    ),
    GoRoute(
      name: 'counter',
      path: '/counter',
      builder: (context, state) {
        final principalId = state.extra as String? ?? '';
        return CanisterApp(principalId: principalId);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _error;
  StreamSubscription? _sub;
  String? _principalIdentity;
  bool _isLoggedIn = false;

  void handleLogin() async {
    await authenticate();
  }

  void handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _principalIdentity = null;
    });
  }

  @override
  void initState() {
    super.initState();
    initUniLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void initUniLinks() {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.scheme == 'auth' && uri.host == 'callback') {
        var queryParams = uri.queryParameters;
        bool loginStatus = queryParams['status'] == 'true';

        setState(() {
          _isLoggedIn = loginStatus;
          if (loginStatus) {
            _principalIdentity = queryParams['principal'] ?? 'Not available';
            _error = queryParams['error'] ?? '';
          } else {
            _principalIdentity = null;
          }
        });
      }
    }, onError: (err) {
      print('Error processing incoming URI: $err');
    });
  }

  Future<void> authenticate() async {
    try {
      const url =
          'https://a975-171-78-253-193.ngrok-free.app/?canisterId=bd3sg-teaaa-aaaaa-qaaba-cai';
      await launch(
        url,
        customTabsOption: CustomTabsOption(
          toolbarColor: Theme.of(context).primaryColor,
          enableDefaultShare: true,
          enableUrlBarHiding: true,
          showPageTitle: true,
        ),
        safariVCOption: SafariViewControllerOption(
          preferredBarTintColor: Theme.of(context).primaryColor,
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: true,
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to open URL: $e';
      });
    }
  }

  Widget buildMoveButton() {
    return ElevatedButton(
      onPressed: () {
        context.goNamed('counter', extra: _principalIdentity);
      },
      child: Text(
        'Counter Page ➡️',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var actionButton = _isLoggedIn
        ? ElevatedButton(
            onPressed: handleLogout,
            child: Text(
              'Logout',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          )
        : ElevatedButton(
            onPressed: handleLogin,
            child: Text(
              'Login',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          );

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 200,
                height: 100,
                child: Image(image: AssetImage('assets/images/logo.png')),
              ),
              SizedBox(height: 50),
              Text(
                'Your principal id will appear below 👇',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                _principalIdentity ?? 'Principal Identity not available',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 50),
              if (_isLoggedIn) buildMoveButton(),
              if (_isLoggedIn) SizedBox(height: 10),
              actionButton,
            ],
          ),
        ),
      ),
    );
  }
}
