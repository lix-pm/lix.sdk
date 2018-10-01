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
    
    remote.version().handle(function(o) switch o {
      case Success(v): trace(v.hash.substr(0, 8) + ' ' + v.buildDate);
      case Failure(e): trace(e);
    });
    
    remote.me().get()
      .flatMap(o -> switch o {
        case Success(user):
          Promise.lift(user);
        case Failure(e) if(e.code == 404):
          remote.users().create({username: 'lix'});
        case Failure(e):
          Promise.lift(e);
      })
      .handle(function(o) switch o {
        case Success(user): trace('Logged in as ${user.username}');
        case Failure(e): trace(e);
      });
  }
}