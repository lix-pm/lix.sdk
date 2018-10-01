package ;

import tink.http.clients.*;

using tink.CoreApi;

class RunTests {
  static function main() {
    var auth = new lix.Auth();
    // trace(auth.isSignedIn());
    // auth.getSession().handle(function(o) trace(o.sure()));
    var remote = new lix.Remote(
      #if (environment == "local") new NodeClient() #else new SecureNodeClient() #end, 
      () -> auth.getSession().next(session -> session.idToken)
    );
    remote.version().handle(function(o) trace(o));
    remote.me().get().handle(function(o) trace(o));
  }
}