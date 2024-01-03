// import 'dart:async';
// import 'dart:ffi';
// import 'package:agent_dart/principal/utils/sha256.dart';
// import 'package:auth_counter/counter.dart';
// import 'counterUi.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:uni_links/uni_links.dart';
// import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
// // ---------------- New Imports ----------------
//
// import 'dart:convert';
// import 'counter.dart';
// import 'dart:developer';
// // import 'package:dson/dson.dart';
// import 'dart:typed_data';
// import 'package:agent_dart/agent_dart.dart';
// import 'package:webcrypto/webcrypto.dart' as webcrypto;
//
// // ---------------- Global Delegation Identity ----------------
// // DelegationIdentity? globalDelegationIdentity;
//
// void main() {
//   runApp(MyApp());
// }
//
// // ---------------- Router ----------------
// final _router = GoRouter(
//   initialLocation: '/',
//   routes: [
//     GoRoute(
//       name: 'home',
//       path: '/',
//       builder: (context, state) => MyHomePage(),
//     ),
//     GoRoute(
//       name: 'counter',
//       path: '/counter',
//       builder: (context, state) => CanisterApp(),
//     ),
//   ],
// );
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       routerConfig: _router,
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key}) : super(key: key);
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   String? _error;
//   StreamSubscription? _sub;
//   String? _principalIdentity;
//   bool _isLoggedIn = false;
//   // DelegationChain? _delegationChain;
//   // DelegationIdentity? _delegationIdentity;
//   var publicKeyString;
//   // P256Identity? _p256Identity;
//
//   @override
//   void initState() {
//     super.initState();
//     // ecdsaKey();
//     initUniLinks();
//   }
//
//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }
//
//   // ---------------- Handling Login ----------------
//   void handleLogin() async {
//     await authenticate();
//   }
//
//   // ---------------- Handling Logout ----------------
//   void handleLogout() {
//     setState(() {
//       _isLoggedIn = false;
//       _principalIdentity = null;
//     });
//   }
//
//   // ---------------- Receiving Query Params ----------------
//
//   Counter? counter;
//   String _decodedDelegation = '';
//   String _decodedIdentity = '';
//   AgentFactory? _agentFactory;
//   CanisterActor? get actor => newActor;
//   CanisterActor? newActor;
//   Future<void> initUniLinks() async {
//     _sub = uriLinkStream.listen((Uri? uri) {
//       if (uri != null && uri.scheme == 'auth' && uri.host == 'callback') {
//         var queryParams = uri.queryParameters;
//
//         String delegationString = queryParams['del'].toString();
//         String identityString = queryParams['id'].toString();
//         print("DeligationString: $delegationString");
//         print("IdentityString: $identityString");
//         _decodedDelegation = Uri.decodeComponent(delegationString);
//         _decodedIdentity = Uri.decodeComponent(identityString);
//
//         Identity? _newIden = Ed25519KeyIdentity.fromJSON(_decodedIdentity);
//
//         SignIdentity _inner = Ed25519KeyIdentity.fromJSON(_decodedIdentity);
//         DelegationChain _delegationChain =
//             DelegationChain.fromJSON(_decodedDelegation);
//
//         generateMnemonic();
//
//         DelegationIdentity _delegationIdentity =
//             DelegationIdentity.fromDelegation(_inner, _delegationChain);
//
//         print(_newIden.getPrincipal().toString());
//         print(_delegationIdentity.getPrincipal().toString());
//
//         print("Inner principal: ${_delegationIdentity.getInnerKey().getPrincipal().toString()}");
//
//         // var  = _delegationIdentity.sign(blobFromHex(bytesToHex(_delegationIdentity.getDelegation().delegations[0].signature)));
//
//         print("Inner principal: ${_delegationIdentity.getInnerKey().getPrincipal().toString()}");
//
//
//         // _delegationIdentity.sign(blobFromHex("302a300506032b65700321003b6a27bcceb6a42d62a3a8d02a6f0d73653215771de243a63ac048a18b59da29"));
//
//         HttpAgent newAgent = HttpAgent(
//           options: HttpAgentOptions(
//             identity: _delegationIdentity.getInnerKey(),
//           ),
//           defaultHost: 'localhost',
//           defaultPort: 8000,
//           defaultProtocol: 'http',
//         );
//
//         // Creating Canister Actor -----------------------
//         newActor = CanisterActor(
//             ActorConfig(
//               canisterId: Principal.fromText('bkyz2-fmaaa-aaaaa-qaaaq-cai'),
//               agent: newAgent,
//             ),
//             CounterMethod.idl);
//
//         counter = Counter(
//           canisterId: 'bkyz2-fmaaa-aaaaa-qaaaq-cai',
//           url: 'https://f48b-182-64-30-137.ngrok-free.app/',
//         );
//         counter?.setAgent(newIdentity: _delegationIdentity);
//         // counter?.whoamI();
//
//         var res = actor?.getFunc(CounterMethod.whoamI)?.call([]);
//         print("WhoAmI : $res");
//
//         // delegationIdentity(_newIden, _delegationChain);
//
//         // bool loginStatus = true;
//
//         // bool loginStatus = queryParams['status'] == 'true';
//         //
//         // if (loginStatus) {
//         //   processDelegation(queryParams);
//         // }
//
//         //     setState(() {
//         //       _isLoggedIn = loginStatus;
//         //       if (loginStatus) {
//         //         _principalIdentity = queryParams['principal'] ?? 'Not available';
//         //         _error = queryParams['error'] ?? '';
//         //       } else {
//         //         _principalIdentity = null;
//         //       }
//         //     });
//         //   }
//         // }, onError: (err) {
//         //   print('Error processing incoming URI: $err');
//       }
//     });
//   }
//
//   // ---------------- Generating Delegation Identity ----------------
//
//   // Future<void> delegationIdentity(newIdentity, delegationChain) async {
//   //   _delegationIdentity = DelegationIdentity.fromDelegation(newIdentity, delegationChain);
//   //
//   //
//   //
//   //   HttpAgent newAgent = HttpAgent(
//   //     options: HttpAgentOptions(
//   //       identity: await newIdentity,
//   //     ),
//   //     defaultHost: 'localhost',
//   //     defaultPort: 8000,
//   //     defaultProtocol: 'http',
//   //   );
//   //
//   //   // Creating Canister Actor -----------------------
//   //   newActor = CanisterActor(
//   //       ActorConfig(
//   //         canisterId: Principal.fromText('bkyz2-fmaaa-aaaaa-qaaaq-cai'),
//   //         agent: newAgent,
//   //         // effectiveCanisterId: Principal.fromText(_delegationIdentity!.getPrincipal().toString()),
//   //       ),
//   //       CounterMethod.idl);
//   //
//   //   // final verified = await cert.verify();
//   //
//   //   // counter = Counter(
//   //   //   canisterId: 'bkyz2-fmaaa-aaaaa-qaaaq-cai',
//   //   //   url: 'https://8c7b-182-64-30-137.ngrok-free.app/',
//   //   // );
//   //   // await counter?.setAgent(newIdentity: newIdentity);
//   //
//   //   var res = await actor?.getFunc(CounterMethod.whoamI)?.call([]);
//   //   print("WhoAmI : $res");
//   // }
//
//   webcrypto.KeyPair<webcrypto.EcdsaPrivateKey, webcrypto.EcdsaPublicKey>?
//       keyPair;
//
//   // Future<void> ecdsaKey() async {
//   //   keyPair = await webcrypto.EcdsaPrivateKey.generateKey(
//   //           webcrypto.EllipticCurve.p256);
//   //
//   //   webcrypto.EcdsaPrivateKey privateKey = keyPair!.privateKey;
//   //   webcrypto.EcdsaPublicKey publicKey = keyPair!.publicKey;
//   //
//   //   var spkiKey = await publicKey.exportSpkiKey();
//   //   print(spkiKey);
//   //   print(bytesToHex(spkiKey));
//   //   publicKeyString = bytesToHex(spkiKey);
//   // }
//
//   Future<void> whoamiii() async {
//     try {
//       var res = await newActor?.getFunc(CounterMethod.whoamI)?.call([]);
//       print(res);
//     } catch (e) {
//       print("error: $e");
//     }
//   }
//
//   // ---------------- Authentication ----------------
//   Future<void> authenticate() async {
//     try {
//       // ----- Port : 4943 -----
//       const baseUrl = 'https://79f1-182-64-30-137.ngrok-free.app/';
//       final url =
//           '$baseUrl?publicKey=$publicKeyString&canisterId=bd3sg-teaaa-aaaaa-qaaba-cai';
//       await launch(
//         url,
//         customTabsOption: CustomTabsOption(
//           toolbarColor: Theme.of(context).primaryColor,
//           enableDefaultShare: true,
//           enableUrlBarHiding: true,
//           showPageTitle: true,
//         ),
//         safariVCOption: SafariViewControllerOption(
//           preferredBarTintColor: Theme.of(context).primaryColor,
//           preferredControlTintColor: Colors.white,
//           barCollapsingEnabled: true,
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         _error = 'Failed to open URL: $e';
//       });
//     }
//   }
//
//   // ---------------- Counter Page Button Action ----------------
//   Widget buildMoveButton() {
//     return ElevatedButton(
//       onPressed: () {
//         // context.goNamed('counter', extra: _delegationIdentity);
//         // whoamiii();
//         // context.goNamed('counter');
//       },
//       child: Text(
//         'Counter Page ➡️',
//         style: TextStyle(fontSize: 18, color: Colors.white),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.blue,
//         padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(30),
//         ),
//       ),
//     );
//   }
//
//   // ---------------- UI ----------------
//   @override
//   Widget build(BuildContext context) {
//     var actionButton = _isLoggedIn
//         ? ElevatedButton(
//             onPressed: handleLogout,
//             child: Text(
//               'Logout',
//               style: TextStyle(fontSize: 18, color: Colors.white),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.pink,
//               padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//           )
//         : ElevatedButton(
//             onPressed: handleLogin,
//             child: Text(
//               'Login',
//               style: TextStyle(fontSize: 18, color: Colors.white),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.deepPurple,
//               padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//           );
//
//     return Scaffold(
//       body: Padding(
//         padding: EdgeInsets.all(20.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               SizedBox(
//                 width: 200,
//                 height: 100,
//                 child: Image(image: AssetImage('assets/images/logo.png')),
//               ),
//               SizedBox(height: 50),
//               Text(
//                 'Your principal id will appear below 👇',
//                 style: Theme.of(context).textTheme.bodyLarge,
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 10),
//               Text(
//                 _principalIdentity ?? 'Principal Identity not available',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 50),
//               if (_isLoggedIn) buildMoveButton(),
//               if (_isLoggedIn) SizedBox(height: 10),
//               actionButton,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:ffi';
// // import 'dart:html';
// // import 'package:agent_dart/bridge/ffi/ffi.dart';
// import 'package:agent_dart/principal/utils/sha256.dart';
// import 'package:auth_counter/counter.dart';
// // import 'package:pointycastle/key_generators/ec_key_generator.dart';
// import 'counterUi.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:uni_links/uni_links.dart';
// import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
//
// // ---------------- New Imports ----------------
//
// import 'dart:convert';
// import 'counter.dart';
// import 'dart:developer';
// import 'package:dson/dson.dart';
// // import 'dart:math';
// import 'dart:typed_data';
// import 'package:agent_dart/agent_dart.dart';
// // import 'package:pointycastle/export.dart' as pointy;
// // import 'package:asn1lib/asn1lib.dart';
//
// // import 'package:cryptography/cryptography.dart' as crypto;
// // import 'package:ecdsa/ecdsa.dart';
// // import 'package:elliptic/elliptic.dart';
// // import 'package:pointycastle/pointycastle.dart' as pointy;
// // import 'package:webcrypto/webcrypto.dart' as webcrypto;
// // import 'package:crypto_keys/crypto_keys.dart' as cr;
// // import 'package:crypton/crypton.dart' as cryp;
// // import 'package:agent_dart/authentication/authentication.dart';
//
// // ---------------- Global Delegation Identity ----------------
// // DelegationIdentity? globalDelegationIdentity;
//
// void main() {
//   runApp(MyApp());
// }
//
// // ---------------- Router ----------------
// final _router = GoRouter(
//   initialLocation: '/',
//   routes: [
//     GoRoute(
//       name: 'home',
//       path: '/',
//       builder: (context, state) => MyHomePage(),
//     ),
//     GoRoute(
//       name: 'counter',
//       path: '/counter',
//       builder: (context, state) => CanisterApp(),
//     ),
//   ],
// );
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       routerConfig: _router,
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key}) : super(key: key);
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   String? _error;
//   StreamSubscription? _sub;
//   String? _principalIdentity;
//   bool _isLoggedIn = false;
//   DelegationChain? _delegationChain;
//   DelegationIdentity? _delegationIdentity;
//   var publicKeyString;
//   P256Identity? _p256Identity;
//
//   @override
//   void initState() {
//     super.initState();
//     // generateEcKeyPair();
//     ecdsaKey();
//     initUniLinks();
//   }
//
//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }
//
//   // ---------------- Handling Login ----------------
//   void handleLogin() async {
//     await authenticate();
//   }
//
//   // ---------------- Handling Logout ----------------
//   void handleLogout() {
//     setState(() {
//       _isLoggedIn = false;
//       _principalIdentity = null;
//     });
//   }
//
//   // ---------------- Receiving Query Params ----------------
//
//   void printWrapped(String text) {
//     final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
//     pattern.allMatches(text).forEach((match) => print(match.group(0)));
//   }
//
//   String _decodedUri = '';
//   Identity? newIden;
//   void initUniLinks() {
//     _sub = uriLinkStream.listen((Uri? uri) {
//       if (uri != null && uri.scheme == 'auth' && uri.host == 'callback') {
//         var queryParams = uri.queryParameters;
//
//         String delegationString = queryParams['delegation'].toString();
//         printWrapped("DeligationString: $delegationString");
//         _decodedUri = Uri.decodeComponent(delegationString);
//
//         newIden = Ed25519KeyIdentity.fromJSON(_decodedUri);
//         print("newIden : $newIden");
//
//
//
//         // String in required deligation format
//         // _decodedUri = _decodedUri.substring(1, _decodedUri.length - 3);
//
//         processDelegation(jsonDecode(_decodedUri));
//
//         bool loginStatus = true;
//
//         // bool loginStatus = queryParams['status'] == 'true';
//         //
//         // if (loginStatus) {
//         //   processDelegation(queryParams);
//         // }
//
//         setState(() {
//           _isLoggedIn = loginStatus;
//           if (loginStatus) {
//             _principalIdentity = queryParams['principal'] ?? 'Not available';
//             _error = queryParams['error'] ?? '';
//           } else {
//             _principalIdentity = null;
//           }
//         });
//       }
//     }, onError: (err) {
//       print('Error processing incoming URI: $err');
//     });
//   }
//
//   // ---------------- New Deligation Chain ----------------
//
//   bool isDelegationValid(DelegationChain chain, DelegationValidChecks? checks) {
//     // Verify that the no delegation is expired.
//     // If any are in the chain, returns false.
//     for (final d in chain.delegations) {
//       final delegation = d.delegation!;
//       final exp = delegation.expiration;
//       final t = exp / BigInt.from(1000000);
//       // prettier-ignore
//       if (DateTime.fromMillisecondsSinceEpoch(t.toInt())
//           .isBefore(DateTime.now())) {
//         return false;
//       }
//     }
//
//     // Check the scopes.
//     final scopes = <Principal>[];
//     final maybeScope = checks?.scope;
//     if (maybeScope != null) {
//       if (maybeScope is List) {
//         scopes.addAll(
//           maybeScope
//               .map(
//                 (s) => s is String ? Principal.fromText(s) : (s as Principal),
//               )
//               .toList(),
//         );
//       } else {
//         scopes.addAll(
//           maybeScope is String ? Principal.fromText(maybeScope) : maybeScope,
//         );
//       }
//     }
//     for (final s in scopes) {
//       final scope = s.toText();
//       for (final d in chain.delegations) {
//         final delegation = d.delegation;
//         if (delegation == null || delegation.targets == null) {
//           continue;
//         }
//         bool none = true;
//         final targets = delegation.targets;
//         for (final target in targets!) {
//           if (target.toText() == scope) {
//             none = false;
//             break;
//           }
//         }
//         if (none) {
//           return false;
//         }
//       }
//     }
//     return true;
//   }
//
//   void processDelegation(queryParams) {
//     try {
//       _delegationChain = DelegationChain.fromJSON(queryParams);
//       print(isDelegationValid(_delegationChain!, null));
//       printWrapped("Delegation Chain: ${jsonEncode(_delegationChain)}");
//       delegationIdentity(_delegationChain);
//     } catch (e) {
//       print('Error processing delegation JSON: $e');
//     }
//   }
//
//   // ---------------- Generating ECDSAKey ----------------
//
//   // Future<pointy.AsymmetricKeyPair> generateEcdsaKeyPair() async {
//   //   var keyParams = pointy.ECKeyGeneratorParameters(pointy.ECCurve_secp256r1());
//   //
//   //   var random = pointy.FortunaRandom();
//   //   var seed = DateTime.now().millisecondsSinceEpoch.toString();
//   //   random.seed(pointy.KeyParameter(Uint8List.fromList(seed.codeUnits)));
//   //
//   //   var generator = pointy.KeyGenerator("EC")
//   //     ..init(pointy.ParametersWithRandom(keyParams, random));
//   //
//   //   var PointyKeyPair =  generator.generateKeyPair();
//   //   var publicKey = PointyKeyPair.publicKey;
//   //
//   //   return
//   // }
//
//   // var privateKeyHex;
//
//   // pointy.SecureRandom getSecureRandom() {
//   //   var secureRandom = pointy.FortunaRandom();
//   //   var random = Random.secure();
//   //   List<int> seeds = [];
//   //   for (int i = 0; i < 32; i++) {
//   //     seeds.add(random.nextInt(256));
//   //   }
//   //   secureRandom.seed(new pointy.KeyParameter(new Uint8List.fromList(seeds)));
//   //   return secureRandom;
//   // }
//
//   // pointy.AsymmetricKeyPair<pointy.PublicKey, pointy.PrivateKey> generateEcKeyPair() {
//   //   // Create an instance of the secure random number generator
//   //   final secureRandom = pointy.FortunaRandom();
//   //   final random = pointy.FortunaRandom();
//   //   var seed = Uint8List.fromList(List<int>.generate(32, (i) => Random.secure().nextInt(256)));
//   //   random.seed(pointy.KeyParameter(seed));
//   //
//   //   // Specify the curve parameters
//   //   final curve = pointy.ECCurve_secp256r1();
//   //   final ecParams = pointy.ECKeyGeneratorParameters(curve);
//   //
//   //   // Create the generator and initialize it
//   //   final generator = pointy.KeyGenerator("EC");
//   //   generator.init(pointy.ParametersWithRandom(ecParams, random));
//   //
//   //   // Generate the key pair
//   //   return generator.generateKeyPair();
//   // }
//
//   // Uint8List publicKeyToDer(pointy.ECPublicKey publicKey) {
//   //   var topLevel = new ASN1Sequence();
//   //
//   //   topLevel.add(ASN1Integer(decodeBigInt(publicKey.Q!.getEncoded(false))));
//   //   // topLevel.add(ASN1Integer(publicKey.exponent));
//   //
//   //   return topLevel.encodedBytes;
//   // }
//
//   // var publicKeyDer;
//   // var privateKeyByte;
//   // Uint8List? seed;
//   // webcrypto.KeyPair<webcrypto.EcdsaPrivateKey, webcrypto.EcdsaPublicKey>?
//   //     keyPair;
//   Ed25519KeyIdentity? _ed25519keyIdentity;
//   Future<void> ecdsaKey() async {
//     _ed25519keyIdentity = await Ed25519KeyIdentity.generate(null);
//
//     var publicKey = _ed25519keyIdentity!.getPublicKey();
//     print(publicKey);
//     var publicKeyDer = publicKey.toDer();
//     print(publicKeyDer);
//     publicKeyString = bytesToHex(publicKeyDer);
//     print(publicKeyString);
//     // final keyPair = generateEcKeyPair();
//     //
//     // final publicKey = keyPair.publicKey as pointy.ECPublicKey;
//     // final privateKey = keyPair.privateKey as pointy.ECPrivateKey;
//     //
//     //  publicKeyDer = publicKeyToDer(publicKey);
//     //
//     // // Use the generated keys as needed
//     // print("Public Key: ${publicKeyDer}");
//     // publicKeyString = bytesToHex(publicKeyDer);
//     // print(bytesToHex(publicKeyDer));
//     // // print("Private Key: ${privateKey.d!.toUnsigned(8).toRadixString(16).codeUnits}");
//     //
//     // var toplevel2 = ASN1Sequence();
//     // toplevel2.add(ASN1Integer(decodeBigInt(privateKey.d!.toUnsigned(8).toRadixString(16).codeUnits)));
//     //  privateKeyByte = toplevel2.encodedBytes;
//
//     // PointyCastle Package -----------------------------------------------------
//
//     //   var keyParams = pointy.ECKeyGeneratorParameters(pointy.ECCurve_secp256r1());
//     //
//     //   // Creating a seed with exactly 32 bytes (256 bits)
//     //   var random = pointy.FortunaRandom();
//     //   List<int> seeds = List<int>.generate(32, (_) => random.nextUint8());
//     //   random.seed(pointy.KeyParameter(Uint8List.fromList(seeds)));
//     //
//     //   var generator = pointy.KeyGenerator("EC")
//     //     ..init(pointy.ParametersWithRandom(keyParams, random));
//     //
//     //   var pointyKeyPair = generator.generateKeyPair();
//     //
//     //   var publicKey = pointyKeyPair.publicKey;
//     //   var privateKey = pointyKeyPair.privateKey;
//     //
//     //   print(publicKey);
//     //   print(privateKey);
//
//     // WebCrypto Package -----------------------------------------------------
//
//     // keyPair = await webcrypto.EcdsaPrivateKey.generateKey(
//     //         webcrypto.EllipticCurve.p256);
//     //
//     // webcrypto.EcdsaPrivateKey privateKey = keyPair!.privateKey;
//     // webcrypto.EcdsaPublicKey publicKey = keyPair!.publicKey;
//     //
//     // var spkiKey = await publicKey.exportSpkiKey();
//     // print(spkiKey);
//     // print(bytesToHex(spkiKey));
//     // publicKeyString = bytesToHex(spkiKey);
//
//     // PublicKey publicKey1 = P256PublicKey.fromRaw(spkiKey);
//     // print(publicKey1);
//
//     // var publicKeyDer = publicKey1.toDer();
//     // print(publicKeyDer);
//     // publicKeyString = bytesToHex(spkiKey);
//     // print(publicKeyString);
//     //
//     // var privateKeyByte = await privateKey.exportPkcs8Key();
//     //
//     _p256Identity = P256Identity.fromKeyPair(spkiKey, privateKeyByte);
//     print(_p256Identity);
//     print(_p256Identity!.getPrincipal().toString());
//
//     // seed = privateKeyByte;
//
//     // var messageBytes = utf8.encode(publicKeyString);
//     // const Hash sha256 = impl.sha256;
//     // privateKey.signBytes(messageBytes, );
//
//     // var newBlob = blobFromHex(publicKeyString);
//     //
//     // SigningFunc signingFunc = (blob, seed) async {
//     //   return seed;
//     // };
//     // signingFunc(newBlob, privateKeyByte);
//     // _p256Identity!.setSigningFunc(signingFunc);
//     // _p256Identity!.sign(newBlob);
//   }
//
//   // ---------------- Generating Delegation Identity ----------------
//   Counter? counter;
//   // AgentFactory? _agentFactory;
//   CanisterActor? get actor => newActor;
//   CanisterActor? newActor;
//
//   // Identity? get identity => _delegationIdentity;
//   Future<void> delegationIdentity(delegationChain) async {
//     print(
//         "App Identity principal: ${jsonEncode(_ed25519keyIdentity!.toJson())}");
//     _delegationIdentity = DelegationIdentity.fromDelegation(
//         _ed25519keyIdentity!, _delegationChain!);
//
//     _delegationIdentity!.sign(blobFromHex(publicKeyString));
//
//     print(bytesToHex(_delegationIdentity!.getPublicKey().toDer()));
//
//     print(
//         "Middle Identity principal: ${_delegationIdentity!.getPrincipal().toString()}");
//
//     // Creating Agent -----------------------
//     HttpAgent newAgent = await HttpAgent(
//       options: HttpAgentOptions(
//         identity: await newIden,
//       ),
//       defaultHost: 'localhost',
//       defaultPort: 8000,
//       defaultProtocol: 'http',
//     );
//
//
//     // Creating Canister Actor -----------------------
//     newActor = await CanisterActor(
//         ActorConfig(
//           canisterId: Principal.fromText('bkyz2-fmaaa-aaaaa-qaaaq-cai'),
//           agent: await newAgent,
//           // effectiveCanisterId: Principal.fromText(_delegationIdentity!.getPrincipal().toString()),
//         ),
//         CounterMethod.idl);
//
//     counter = await Counter(
//       canisterId: 'bkyz2-fmaaa-aaaaa-qaaaq-cai',
//       url: 'https://8c7b-182-64-30-137.ngrok-free.app/',
//     );
//     await counter?.setAgent(newIdentity: _delegationIdentity);
//     // counter?.whoamI();
//     var res = await actor?.getFunc(CounterMethod.whoamI)?.call([]);
//     print("WhoAmI : $res");
//   }
//
//   Future<void> whoamiii() async {
//     try {
//       var res = await newActor?.getFunc(CounterMethod.whoamI)?.call([]);
//       print(res);
//     } catch (e) {
//       print("error: $e");
//     }
//   }
//
//   // ---------------- Authentication ----------------
//   Future<void> authenticate() async {
//     try {
//       // ----- Port : 4943 -----
//       const baseUrl = 'https://eb65-182-64-30-137.ngrok-free.app/';
//       final url =
//           '$baseUrl?publicKey=$publicKeyString&canisterId=bd3sg-teaaa-aaaaa-qaaba-cai';
//       await launch(
//         url,
//         customTabsOption: CustomTabsOption(
//           toolbarColor: Theme.of(context).primaryColor,
//           enableDefaultShare: true,
//           enableUrlBarHiding: true,
//           showPageTitle: true,
//         ),
//         safariVCOption: SafariViewControllerOption(
//           preferredBarTintColor: Theme.of(context).primaryColor,
//           preferredControlTintColor: Colors.white,
//           barCollapsingEnabled: true,
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         _error = 'Failed to open URL: $e';
//       });
//     }
//   }
//
//   // ---------------- Counter Page Button Action ----------------
//   Widget buildMoveButton() {
//     return ElevatedButton(
//       onPressed: () {
//         // context.goNamed('counter', extra: _delegationIdentity);
//         // whoamiii();
//         // context.goNamed('counter');
//       },
//       child: Text(
//         'Counter Page ➡️',
//         style: TextStyle(fontSize: 18, color: Colors.white),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.blue,
//         padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(30),
//         ),
//       ),
//     );
//   }
//
//   // ---------------- UI ----------------
//   @override
//   Widget build(BuildContext context) {
//     var actionButton = _isLoggedIn
//         ? ElevatedButton(
//             onPressed: handleLogout,
//             child: Text(
//               'Logout',
//               style: TextStyle(fontSize: 18, color: Colors.white),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.pink,
//               padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//           )
//         : ElevatedButton(
//             onPressed: handleLogin,
//             child: Text(
//               'Login',
//               style: TextStyle(fontSize: 18, color: Colors.white),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.deepPurple,
//               padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//           );
//
//     return Scaffold(
//       body: Padding(
//         padding: EdgeInsets.all(20.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               SizedBox(
//                 width: 200,
//                 height: 100,
//                 child: Image(image: AssetImage('assets/images/logo.png')),
//               ),
//               SizedBox(height: 50),
//               Text(
//                 'Your principal id will appear below 👇',
//                 style: Theme.of(context).textTheme.bodyLarge,
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 10),
//               Text(
//                 _principalIdentity ?? 'Principal Identity not available',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 50),
//               if (_isLoggedIn) buildMoveButton(),
//               if (_isLoggedIn) SizedBox(height: 10),
//               actionButton,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }