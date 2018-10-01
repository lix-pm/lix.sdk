package ;

import tink.http.clients.*;

using tink.CoreApi;

class RunTests {
  static function main() {
    trace(lix.Auth.isSignedIn());
    lix.Auth.getSession().handle(function(o) trace(o.isSuccess()));
    var remote = new lix.Remote(new SecureNodeClient(), () -> lix.Auth.getSession().next(session -> session.idToken.jwtToken));
    remote.version().handle(function(o) trace(o));
  }
}