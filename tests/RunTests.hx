package ;

using tink.CoreApi;

class RunTests {
  static function main() {
    trace(lix.Auth.isSignedIn());
    lix.Auth.getSession().handle(function(o) trace(o.isSuccess()));
  }
}