import 'package:agent_dart/agent_dart.dart';

abstract class CounterMethod {
  static const increment = "increment";
  static const getValue = "getValue";
  static const whoamI = "whoami";

  /// you can copy/paste from .dfx/local/canisters/counter/counter.did.js
  static final ServiceClass idl = IDL.Service({
    CounterMethod.getValue: IDL.Func([], [IDL.Nat], ['query']),
    CounterMethod.increment: IDL.Func([], [], []),
    CounterMethod.whoamI: IDL.Func([], [IDL.Text], []),
  });
}

/// Counter class, with AgentFactory within
class Counter {
  /// AgentFactory is a factory method that creates Actor automatically.
  /// Save your strength, just use this template
  AgentFactory? _agentFactory;

  /// CanisterActor is the actor that make all the request to Smart contract.
  CanisterActor? get actor => _agentFactory?.actor;
  final String canisterId;
  final String url;

  // final DelegationIdentity? identity;

  Counter(
      {required this.canisterId, required this.url});
  // A future method because we need debug mode works for local development
  Future<void> setAgent(
      {String? newCanisterId,
      ServiceClass? newIdl,
      String? newUrl,
      DelegationIdentity? newIdentity,
      bool? debug}) async {
    _agentFactory ??= await AgentFactory.createAgent(
        canisterId: canisterId,
        url: url,
        idl: CounterMethod.idl,
        identity: newIdentity,
        debug: debug ?? true);
  }

  // Future<void> setAgent() async {
  //   _agentFactory ??= await AgentFactory.createAgent(
  //       canisterId: canisterId,
  //       url: url,
  //       idl: CounterMethod.idl,
  //       identity: identity,
  //       debug: true);
  // }

  /// Call canister methods like this signature
  /// ```dart
  ///  CanisterActor.getFunc(String)?.call(List<dynamic>) -> Future<dynamic>
  /// ```
  ///
  Future<String> whoamI() async {
    try {
      var res = await actor?.getFunc(CounterMethod.whoamI)!([]);
      print("WhoAmI : $res");
      if (res != null) {
        return (res as String);
      }
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> increment() async {
    try {
      await actor?.getFunc(CounterMethod.increment)?.call([]);

    } catch (e) {
      rethrow;
    }
  }

  Future<int> getValue() async {
    try {
      var res = await actor?.getFunc(CounterMethod.getValue)!([]);
      print(res);
      if (res != null) {
        return (res as BigInt).toInt();
      }
      throw "Cannot get count but $res";
    } catch (e) {
      rethrow;
    }
  }
}
