package lix;

import lix.util.Config.*;
import lix.util.OAuthHelper;
import tink.http.containers.*;
import tink.http.Response;
import tink.web.routing.*;
import js.node.Fs;
import js.node.Os;
import haxe.Json;

using haxe.io.Path;
using sys.io.File;
using sys.FileSystem;
using tink.CoreApi;

class Auth {
	var auth:CognitoAuth;
	public function new()
		auth = new CognitoAuth();
		
	public inline function isSignedIn():Bool
		return auth.isSignedIn;
	
	public function getSession():Promise<Session> {
		return Future.async(function(cb) {
			// start a web server to handle oauth callback
			var container = new NodeContainer(51379);
			var router = new Router<Root>(new Root(auth));
			container.run(req -> router.route(Context.ofRequest(req)).recover(OutgoingResponse.reportError))
				.handle(function(o) switch o {
					case Running(state):
						auth.result.next(_ -> state.shutdown(false)).eager();
					case Shutdown:
						cb(Failure(new Error('Unreachable')));
					case Failed(e):
						cb(Failure(e));
				});
			
			auth.result.handle(cb);
			auth.getSession();
		});
	}
	
	public function clearSession():Promise<Noise> {
		Path.join([Os.homedir(), '.lix/session']).saveContent('{}');
		return Noise;
	}
}

class Root {
	var auth:CognitoAuth;
	public function new(auth)
		this.auth = auth;
	
	@:get
	@:html(_ -> '<script>window.location.href = window.location.href.replace("/callback#","/done?")</script>')
	public function callback():Promise<Noise> {
		return Noise;
	}
	
	@:get
	@:html(_ -> '<script>window.close()</script>')
	public function done(query:TokenResponse):Promise<Noise> {
		auth.handleToken(query);
		return Noise;
	}
}

@:keep
class FileStorage {
	var path:String;
	
	public function new(path) {
		this.path = path;
		path.directory().createDirectory();
	}
		
	public function getItem(k)
		return Reflect.field(read(), k);
		
	public function setItem(k, v) {
		var obj = read();
		Reflect.setField(obj, k, v);
		write(obj);
	}
	
	public function removeItem(k) {
		var obj = read();
		Reflect.deleteField(obj, k);
		write(obj);
	}
	
	public function clear()
		write({});
	
	function read():{} return try Json.parse(Fs.readFileSync(path).toString()) catch(e:Dynamic) {};
	function write(v:{}) Fs.writeFileSync(path, Json.stringify(v));
}

class CognitoAuth {
	public var result:Promise<Session>;
	public var isSignedIn(get, never):Bool;
	var impl:aws.cognito.CognitoAuth;
	
	public function new() {
		// Some hacks to make the cognito library work in nodejs
		js.Node.global.atob = (str:String) -> js.node.Buffer.from(str, 'base64').toString('binary');
		js.Node.global.window = {open: url -> js.Lib.require('opn')(url, {wait: false})}
		
		impl = new aws.cognito.CognitoAuth({
			ClientId: 'fvrf50i7h5od9nr1bq4pefcg3',
			AppWebDomain: 'login.lix.pm',
			RedirectUriSignIn: 'http://localhost:51379/callback',
			RedirectUriSignOut: 'http://localhost:51379/logout',
			TokenScopesArray: ['openid'],
			UserPoolId: 'us-east-2_qNnxj1mU1',
			Storage: new FileStorage(Path.join([Os.homedir(), '.lix/session'])),
		});
		
		result = Future.async(function(cb) {
			impl.userhandler = {
				onSuccess: session -> cb(Success({
					idToken: session.idToken.jwtToken,
					accessToken: session.accessToken.jwtToken,
					refreshToken: session.refreshToken.refreshToken,
					scopes: session.tokenScopes.tokenScopes,
				})),
				onFailure: e -> cb(Failure(Error.ofJsError(e))),
			}
		});
		
	}
	
	public inline function getSession() {
		impl.getSession();
	}
	
	public inline function signOut() {
		impl.signOut();
	}
	
	public inline function handleToken(token:TokenResponse)
		impl.parseCognitoWebResponse('http://localhost:51379#' + tink.QueryString.build(token));
		
	inline function get_isSignedIn() return impl.isUserSignedIn();
}

typedef Session = {
	idToken:String,
	accessToken:String,
	refreshToken:String,
	scopes:Array<String>,
}