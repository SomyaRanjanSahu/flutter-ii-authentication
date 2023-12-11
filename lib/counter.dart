import 'package:agent_dart/agent_dart.dart';

/// motoko/rust function of the Counter canister
/// see ./dfx/local/counter.did
abstract class CounterMethod {
  /// use static const as method name
  static const increment = "increment";
  static const getValue = "getValue";

  /// you can copy/paste from .dfx/local/canisters/counter/counter.did.js
  static final ServiceClass idl = IDL.Service({
    CounterMethod.getValue: IDL.Func([IDL.Text], [IDL.Nat], ['query']),
    CounterMethod.increment: IDL.Func([IDL.Text], [], []),
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

  final String principalId;

  Counter(
      {required this.canisterId, required this.url, required this.principalId});

  // A future method because we need debug mode works for local development
  Future<void> setAgent(
      {String? newCanisterId,
      ServiceClass? newIdl,
      String? newUrl,
      Identity? newIdentity,
      bool? debug}) async {
    _agentFactory ??= await AgentFactory.createAgent(
        canisterId: newCanisterId ?? canisterId,
        url: newUrl ?? url,
        idl: newIdl ?? CounterMethod.idl,
        identity: newIdentity,
        debug: debug ?? true);
  }

  /// Call canister methods like this signature
  /// ```dart
  ///  CanisterActor.getFunc(String)?.call(List<dynamic>) -> Future<dynamic>
  /// ```

  Future<void> increment() async {
    try {
      await actor?.getFunc(CounterMethod.increment)?.call([principalId]);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getValue() async {
    try {
      var res =
          await actor?.getFunc(CounterMethod.getValue)?.call([principalId]);
      if (res != null) {
        return (res as BigInt).toInt();
      }
      throw "Cannot get count but $res";
    } catch (e) {
      rethrow;
    }
  }
}
