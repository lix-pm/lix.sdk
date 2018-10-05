package ;

import archive.zip.*;
import archive.scanner.*;
import tink.http.clients.*;

using tink.io.Source;
using tink.CoreApi;

class RunTests {
  static function main() {
    var json:lix.Json = {
      name: 'name',
      license: 'license',
      tags: ['tags1', 'tags2'],
      classPaths: ['cp1', 'cp2'],
      authors: ['kevin'],
      version: '1.0.0',
      dependencies: {
        tink_core: '^1.0.0 || =0.1.0',
        tink_macro: '=1.0.0',
      },
      haxe: '^3.4.7',
      hooks:{
        postInstall: 'postInstall',
        postDownload: 'postDownload',
      }
    }
    
    // var s = tink.Json.stringify(json);
    // trace(haxe.Json.stringify(haxe.Json.parse(s), '  '));
    
    var auth = new lix.Auth();
    // // trace(auth.isSignedIn());
    // // auth.getSession().handle(function(o) trace(o.sure()));
    var remote = new lix.Remote(
      #if (environment == "local")
        new NodeClient(), () -> '2'
      #else
        new SecureNodeClient(), () -> auth.getSession().next(session -> session.idToken)
      #end
    );
    
    // remote.version().handle(function(o) switch o {
    //   case Success(v): trace(v.hash.substr(0, 8) + ' ' + v.buildDate);
    //   case Failure(e): trace(e);
    // });
    
    // remote.me().get()
    //   .flatMap(o -> switch o {
    //     case Success(user):
    //       Promise.lift(user);
    //     case Failure(e) if(e.code == 404):
    //       remote.users().create({username: 'lix'});
    //     case Failure(e):
    //       Promise.lift(e);
    //   })
    //   .handle(function(o) switch o {
    //     case Success(user): trace('Logged in as ${user.username}');
    //     case Failure(e): trace(e);
    //   });
    var submitter = new lix.Submitter(remote, new NodeZip(), AsysScanner.new.bind(_, ''));
    submitter.submit(Sys.getCwd()).handle(function(o) trace(o));
  }
}