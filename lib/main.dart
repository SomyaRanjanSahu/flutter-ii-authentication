import 'dart:async';
import 'dart:typed_data';
import 'package:agent_dart/agent/agent/http/fetch.dart';
import 'package:auth_counter/counter.dart';
import 'counterUi.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:agent_dart/agent_dart.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:pointycastle/pointycastle.dart' as pointy ;
import 'dart:math';
import "package:pointycastle/random/fortuna_random.dart";
import "package:pointycastle/key_generators/ec_key_generator.dart";
import "package:pointycastle/ecc/curves/secp256k1.dart";

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
  // String _decodedIdentity = '';
  // AgentFactory? _agentFactory;
  // CanisterActor? get actor => newActor;
  CanisterActor? newActor;

  // static const whoamI = "whoami";

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

  Future<Map<String, dynamic>> _newFetch({
    required String endpoint,
    String? host,
    FetchMethod method = FetchMethod.post,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    // Ensure the host has a fallback value
    host ??= 'http://localhost:8000/';

    // Build the full endpoint URL
    String fullEndpoint = '$host$endpoint';

    // Perform the fetch using the defaultFetch function from agent_dart package
    return await defaultFetch(
      endpoint: 'api/v2/canister',
      host: host,
      method: method,
      headers: headers,
      body: body,
    );
  }

  Future<void> initUniLinks() async {
    _sub = uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.scheme == 'auth' && uri.host == 'callback') {
        var queryParams = uri.queryParameters;

        String delegationString = queryParams['del'].toString();
        printWrapped("DelegationString: $delegationString");

        _decodedDelegation = Uri.decodeComponent(delegationString);
        printWrapped("Decoded DelegationString: $_decodedDelegation");

        // Creating chain
        DelegationChain _delegationChain =
            DelegationChain.fromJSON(jsonDecode(_decodedDelegation));

        // Creating Identity
        DelegationIdentity _delegationIdentity =
            DelegationIdentity(newIdentity!, _delegationChain);

        // inspect(_delegationIdentity);

        // New HttpAgent
        HttpAgent newAgent = HttpAgent(
          options: HttpAgentOptions(
            identity: _delegationIdentity,
          ),
          defaultHost: 'localhost',
          defaultPort: 8000,
          defaultProtocol: 'http',
        );

        // newAgent.fetchRootKey();

        // newAgent.setFetch(_newFetch);

        // newAgent.call(
        //   Principal.fromText('bkyz2-fmaaa-aaaaa-qaaaq-cai'),
        //   CallOptions(
        //     methodName: CounterMethod.whoamI,
        //     arg: Uint8List(0),
        //   ),
        //   _delegationIdentity,
        // );

        newActor = CanisterActor(
            ActorConfig(
              agent: newAgent,
              canisterId: Principal.fromText('bkyz2-fmaaa-aaaaa-qaaaq-cai'),
              effectiveCanisterId: Principal.fromText('bkyz2-fmaaa-aaaaa-qaaaq-cai'),
                callTransform: (String methodName, List args, CallConfig callConfig) {
                  methodName = CounterMethod.whoamI;
                  args = Uint8List(0);
                  return callConfig;
                },),
            CounterMethod.idl);


        // whoamiii(newAgent, _delegationIdentity);

        // newAgent.setIdentity(_delegationIdentity);
        // newAgent.setFetch(({
        //   dynamic body,
        //   String endpoint = '/api/v2/canister:',
        //   Map<String, String>? headers,
        //   String? host,
        //   FetchMethod method = FetchMethod.post,
        // }) async {
        //   // Default host if not provided
        //   host = host ?? 'http://localhost:8000';
        //   Uri url = Uri.parse('$host$endpoint');
        //
        //   http.Response response;
        //
        //   try {
        //     // Log the request details for debugging
        //     print('Request URL: $url');
        //     print('HTTP Method: $method');
        //     if (headers != null) {
        //       print('Headers: $headers');
        //     }
        //     if (body != null) {
        //       print('Body: $body');
        //     }
        //
        //     switch (method) {
        //       case FetchMethod.get:
        //         response = await http.get(url, headers: headers);
        //         break;
        //       case FetchMethod.post:
        //         response = await http.post(url, headers: headers, body: json.encode(body));
        //         break;
        //     // Handle other HTTP methods as needed
        //       default:
        //         throw Exception('Unsupported HTTP method: $method');
        //     }
        //
        //     // Log the response status code
        //     print('Response Status Code: ${response.statusCode}');
        //
        //     if (response.statusCode == 200) {
        //       // Process the successful response
        //       return json.decode(response.body);
        //     } else {
        //       // Log the response body for non-200 responses
        //       print('Response Body: ${response.body}');
        //       throw Exception('Failed with status code: ${response.statusCode}');
        //     }
        //   } catch (e) {
        //     // Log the error
        //     print('Error: $e');
        //     throw Exception('Failed to load data: $e');
        //   }
        // });

        // New Canister Actor

        // counter = Counter(
        //   canisterId: 'bkyz2-fmaaa-aaaaa-qaaaq-cai',
        //   url: 'https://bdd4-182-64-30-137.ngrok-free.app/',
        // );
        // // counter?.setAgent(newIdentity: _delegationIdentity);
        // counter?.whoamI();

        var res = newActor?.getFunc(CounterMethod.whoamI)?.call([]);
        print("WhoAmI : $res");
        // newAgent.
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

  // Future<void> whoamiii(newAgentt, newId) async {
  //   try {
  //
  //     var response = await newAgentt.call(
  //       Principal.fromText('bkyz2-fmaaa-aaaaa-qaaaq-cai'), // Canister ID
  //       CallOptions(
  //         methodName: CounterMethod.whoamI,
  //         arg: Uint8List(0),  // BinaryBlob argument
  //       ),
  //       newId,  // Identity for authentication
  //     );
  //
  //     // Handle the response
  //     print("Call response: $response");
  //   } catch (e) {
  //     // Handle exceptions
  //     print("Error during canister call: $e");
  //   }
  // }

  // ---------------- Generating ED25519 Key ----------------

  // Uint8List _seed() {
  //   var random = Random.secure();
  //   var seed = List<int>.generate(32, (_) => random.nextInt(256));
  //   return Uint8List.fromList(seed);
  // }

  // pointy.AsymmetricKeyPair<pointy.PublicKey, pointy.PrivateKey> _secp256k1KeyPair() {
  //   var keyParams = pointy.ECKeyGeneratorParameters(ECCurve_secp256k1());
  //
  //   var random = FortunaRandom();
  //   random.seed(pointy.KeyParameter(_seed()));
  //
  //   var generator = ECKeyGenerator();
  //   generator.init(pointy.ParametersWithRandom(keyParams, random));
  //
  //   return generator.generateKeyPair();
  // }

  // Ed25519KeyIdentity? newIdentity;
  Secp256k1KeyIdentity? newIdentity;
  Future<void> ed25519() async {
    // newIdentity = await Ed25519KeyIdentity.generate(null);
    // Ed25519PublicKey publicKey = newIdentity!.getPublicKey();
    // var publicKeyDer = publicKey.toDer();
    // publicKeyString = bytesToHex(publicKeyDer);
    //
    // print("Public Key: $publicKeyString");
    //
    // var keyPair = _secp256k1KeyPair();
    // pointy.ECPrivateKey privateKey = keyPair.privateKey as  pointy.ECPrivateKey;
    // print(privateKey.d);
    //
    // pointy.ECPublicKey publicKey = keyPair.publicKey as pointy.ECPublicKey;
    // print(publicKey.Q);

    newIdentity = await Secp256k1KeyIdentity.generate(null);
    Secp256k1PublicKey _publicKey = newIdentity!.getPublicKey();
    var publicKeyDer = _publicKey.toDer();
    publicKeyString = bytesToHex(publicKeyDer);
    print("Public Key: $publicKeyString");

  }

  // ---------------- Authentication ----------------
  Future<void> authenticate() async {
    try {
      // ----- Port : 4943 -----
      const baseUrl = 'https://7b5a-171-76-59-100.ngrok-free.app/';
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
