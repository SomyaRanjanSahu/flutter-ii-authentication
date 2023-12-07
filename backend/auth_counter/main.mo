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
    var map = HashMap.HashMap<Text, Nat>(0, Text.equal, Text.hash);
    stable var userData : [(Text, Nat)] = [];

    system func preupgrade() {
        userData := Iter.toArray(map.entries());
    };

    system func postupgrade() {
        map := HashMap.fromIter<Text, Nat>(userData.vals(), 1, Text.equal, Text.hash);
        userData := [];
    };

    public func increment(principalId : Text) : async () {
        if (principalId == "2vxsx-fae") {
            throw Error.reject("Principal is not authenticated");
        } else {
            let currentCount = switch (map.get(principalId)) {
                case (?count) count;
                case null 0;
            };
            map.put(principalId, currentCount + 1);
        }
    };

    public query func getValue(principalId: Text) : async Nat {
         return switch (map.get(principalId)) {
            case (?count) count;
            case null throw Error.reject("Principal not found");
        };
    };

};