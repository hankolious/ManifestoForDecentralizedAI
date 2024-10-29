import HashMap "mo:base/HashMap";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

actor {
  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };

// Manifesto Signatures from Website
  public type ManifestoSignee = {
    name: Text;
    emailAddress: Text;
    signedAt: Nat64;
  };

  public type SignUpFormInput = {
    name: Text;
    emailAddress: Text;
  };

  stable var signeesStorageStable : [(Text, ManifestoSignee)] = [];
  var signeesStorage : HashMap.HashMap<Text, ManifestoSignee> = HashMap.HashMap(0, Text.equal, Text.hash);

  private func putManifestoSignee(signee : ManifestoSignee) : Text {
    signeesStorage.put(signee.emailAddress, signee);
    return signee.emailAddress;
  };

  private func getManifestoSignee(emailAddress : Text) : ?ManifestoSignee {
    let result = signeesStorage.get(emailAddress);
    return result;
  };

  public func submit_signup_form(submittedSignUpForm : SignUpFormInput) : async Text {
    switch(getManifestoSignee(submittedSignUpForm.emailAddress)) {
      case null {
        // New signee
        let newSignee : ManifestoSignee = {
          emailAddress: Text = submittedSignUpForm.emailAddress;
          name: Text = submittedSignUpForm.name;
          signedAt: Nat64 = Nat64.fromNat(Int.abs(Time.now()));
        };
        let result = putManifestoSignee(newSignee);
        if (result != newSignee.emailAddress) {
          return "There was an error. Please try again.";
        };
        return "Successfully signed!";
      };
      case _ { return "Already signed!"; };
    };  
  };

  // Function for custodian to get all email subscribers
  public shared query ({ caller }) func get_manifesto_signees() : async [(Text, ManifestoSignee)] {
    // don't allow anonymous Principal
    if (Principal.isAnonymous(caller)) {
      return [];
		};
    // Only Principals registered as custodians can access this function
    if (Principal.isController(caller)) {
      return Iter.toArray(signeesStorage.entries());
    };
    return [];
  };

  // Function for custodian to delete an email subscriber
  public shared({ caller }) func delete_manifesto_signee(emailAddress : Text) : async Bool {
    // don't allow anonymous Principal
    if (Principal.isAnonymous(caller)) {
      return false;
		};
    // Only Principals registered as custodians can access this function
    if (Principal.isController(caller)) {
      signeesStorage.delete(emailAddress);
      return true;
    };
    return false;
  };

// Upgrade Hooks
  system func preupgrade() {
    signeesStorageStable := Iter.toArray(signeesStorage.entries());
  };

  system func postupgrade() {
    signeesStorage := HashMap.fromIter(Iter.fromArray(signeesStorageStable), signeesStorageStable.size(), Text.equal, Text.hash);
    signeesStorageStable := [];
  };
};
