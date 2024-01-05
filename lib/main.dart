import 'dart:async';
import 'dart:typed_data';
import 'package:auth_counter/counter.dart';
import 'counterUi.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:agent_dart/agent_dart.dart';
import 'dart:convert';
import 'package:webcrypto/webcrypto.dart';

void main() {
  runApp(MyApp());
}

// ---------------- Router ----------------
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
      builder: (context, state) => CanisterApp(),
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
  var publicKeyString;
  Counter? counter;
  String _decodedDelegation = '';
  String _decodedIdentity = '';
  AgentFactory? _agentFactory;
  CanisterActor? get actor => newActor;
  CanisterActor? newActor;

  @override
  void initState() {
    super.initState();
    ed25519();
    initUniLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ---------------- Handling Login ----------------
  void handleLogin() async {
    await authenticate();
  }

  // ---------------- Handling Logout ----------------
  void handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _principalIdentity = null;
    });
  }

  // ---------------- Receiving Query Params ----------------

  void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Future<void> initUniLinks() async {
    _sub = uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.scheme == 'auth' && uri.host == 'callback') {
        var queryParams = uri.queryParameters;

        String delegationString = queryParams['del'].toString();
        printWrapped("DelegationString: $delegationString");


        _decodedDelegation = Uri.decodeComponent(delegationString);
        printWrapped("Decoded DelegationString: $_decodedDelegation");

        DelegationChain _delegationChain =
            DelegationChain.fromJSON(jsonDecode(_decodedDelegation));

        // var appPublicKey = Ed25519PublicKey.fromDer(blobFromHex(publicKeyString));
        // var appPublicKeyTOstring = bytesToHex(appPublicKey.toDer());
        // print("appPublicKey: $appPublicKeyTOstring");
        //
        // var keyPair = newIdentity!.getKeyPair();
        // var publicKey = keyPair.publicKey;
        // var keyPairToJSON = keyPair.secretKey;
        // print("pub: $publicKey");
        // print("pri: $keyPairToJSON");
        //
        // var newKey = Ed25519KeyIdentity(publicKey, keyPairToJSON);

        DelegationIdentity _delegationIdentity =
            DelegationIdentity(newIdentity!, _delegationChain);

        // var authClient = AuthClient(
        //   scheme: 'https',
        //   authFunction: (AuthPayload payload) async {
        //     return 'Bearer ${payload.scheme}';
        //   },
        //   key: newIdentity,
        //   identity: ,
        //   chain: _delegationChain,
        // );
        //
        // print(authClient.getIdentity());


        // print("Delegation principal: ${_delegationIdentity.getPrincipal().toString()}");
        // print("Inner principal: ${_delegationIdentity.getInnerKey().getPrincipal().toString()}");
        // Principal(_delegationIdentity.getPrincipal().toUint8List()).toString();
        // print("Inner principal: ${_delegationIdentity.getInnerKey().getPrincipal().toString()}");
        // print("Inner principal: ${Principal(_delegationIdentity.getPrincipal().toUint8List()).toString()}");
        // newIdentity.setPrincipal(_principal);

        HttpAgent newAgent = HttpAgent(
          options: HttpAgentOptions(
            identity: _delegationIdentity,
          ),
          defaultHost: 'localhost',
          defaultPort: 4943,
          defaultProtocol: 'http',
        );

        // Creating Canister Actor -----------------------
        newActor = CanisterActor(
            ActorConfig(
              canisterId: Principal.fromText('br5f7-7uaaa-aaaaa-qaaca-cai'),
              agent: newAgent,
            ),
            CounterMethod.idl);

        // counter = Counter(
        //   canisterId: 'bkyz2-fmaaa-aaaaa-qaaaq-cai',
        //   url: 'https://bdd4-182-64-30-137.ngrok-free.app/',
        // );
        // // counter?.setAgent(newIdentity: _delegationIdentity);
        // counter?.whoamI();

        var res = await newActor?.getFunc(CounterMethod.whoamI)?.call([]);
        print("WhoAmI : $res");
        var res1 = await newActor?.getFunc(CounterMethod.increment)?.call([]);
        var res2 = await newActor?.getFunc(CounterMethod.getValue)?.call([]);
        print("getValue : $res2");

        // bool loginStatus = true;

        // bool loginStatus = queryParams['status'] == 'true';
        //
        // if (loginStatus) {
        //   processDelegation(queryParams);
        // }

        //     setState(() {
        //       _isLoggedIn = loginStatus;
        //       if (loginStatus) {
        //         _principalIdentity = queryParams['principal'] ?? 'Not available';
        //         _error = queryParams['error'] ?? '';
        //       } else {
        //         _principalIdentity = null;
        //       }
        //     });
        //   }
        // }, onError: (err) {
        //   print('Error processing incoming URI: $err');
      }
    });
  }

  // ---------------- Generating ED25519 Key ----------------
  Ed25519KeyIdentity? newIdentity;
  Future<void> ed25519() async {
    newIdentity = await Ed25519KeyIdentity.generate(null);
    Ed25519PublicKey publicKey = newIdentity!.getPublicKey();
    var publicKeyDer = publicKey.toDer();
    publicKeyString = bytesToHex(publicKeyDer);

    print("Public Key: $publicKeyString");
  }

  // ---------------- Authentication ----------------
  Future<void> authenticate() async {
    try {
      // ----- Port : 4943 -----
      const baseUrl = 'http://localhost:4943';
      // const baseUrl = 'http://10.0.2.2:4943';
      // const baseUrl = 'https://identity.ic0.app';
      // http://localhost:4943/?sessionkey=302a300506032b657003210066509bdbdeb9cd0a29b804a1fbb0bc4adeb8f1dab4e7e9a65dc6d65df8f09e5b&canisterId=bd3sg-teaaa-aaaaa-qaaba-cai
      // const baseUrl = 'https://7fbd-122-179-100-169.ngrok-free.app/';
      http://localhost:4943/?sessionkey=302a300506032b65700321002581d270561038cddad7536b81abe24a874e19478c51a571d19c43b11a3a01c3&canisterId=bkyz2-fmaaa-aaaaa-qaaaq-cai
      http://localhost:4943/?sessionkey=302a300506032b65700321002581d270561038cddad7536b81abe24a874e19478c51a571d19c43b11a3a01c3&canisterId=ahw5u-keaaa-aaaaa-qaaha-cai
      final url =
          '$baseUrl?sessionkey=$publicKeyString&canisterId=bd3sg-teaaa-aaaaa-qaaba-cai';
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

  // ---------------- Counter Page Button Action ----------------
  Widget buildMoveButton() {
    return ElevatedButton(
      onPressed: () {
        // context.goNamed('counter', extra: _delegationIdentity);
        // whoamiii();
        // context.goNamed('counter');
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

  // ---------------- UI ----------------
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
