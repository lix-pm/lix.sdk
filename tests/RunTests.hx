package ;

import tink.http.clients.*;

using tink.CoreApi;

class RunTests {
  static function main() {
    var auth = new lix.Auth();
    trace(auth.isSignedIn());
    auth.getSession().handle(function(o) trace(o.isSuccess()));
    var remote = new lix.Remote(new SecureNodeClient(), () -> auth.getSession().next(session -> session.idToken.jwtToken));
    remote.version().handle(function(o) trace(o));
  }
}