import Principal "mo:base/Principal";
import Error "mo:base/Error";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Float "mo:base/Float";
import List "mo:base/List";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Debug "mo:base/Debug";

actor {
    var map = HashMap.HashMap<Principal, Nat>(0, Principal.equal, Principal.hash);
    stable var userData : [(Principal, Nat)] = [];

    system func preupgrade() {
        userData := Iter.toArray(map.entries());
    };

    system func postupgrade() {
        map := HashMap.fromIter<Principal, Nat>(userData.vals(), 1, Principal.equal, Principal.hash);
        userData := [];
    };

    public shared (msg) func whoami() : async Text {
        Debug.print(debug_show(msg.caller));
        Principal.toText(msg.caller);
    };

    public shared (msg) func increment() : async () {
        let anon = Principal.fromText("2vxsx-fae");
        Debug.print(debug_show(msg.caller));
        if (Principal.equal(anon, msg.caller)) {
            throw Error.reject("Principal is not authenticated");
        } else {
            let currentCount = switch (map.get(msg.caller)) {
                case (?count) count;
                case null 0;
            };
            map.put(msg.caller, currentCount + 1);
        }
    };

    public query (msg) func getValue() : async Nat {
         return switch (map.get(msg.caller)) {
            case (?count) count;
            case null throw Error.reject("Principal not found");
        };
    };

};