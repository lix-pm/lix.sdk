package lix;

import tink.http.Client;
import tink.http.Response;
import tink.http.Request;
import tink.http.Header;
import tink.web.proxy.Remote.RemoteEndpoint;
import lix.util.Config.*;

using tink.CoreApi;

@:forward
abstract Remote(tink.web.proxy.Remote<lix.api.Root>) {
	public inline function new(client, ?getIdToken) {
		this = new tink.web.proxy.Remote<lix.api.Root>(
			getIdToken == null ? client : new AuthedClient(client, getIdToken), 
			new RemoteEndpoint(API_SERVER_HOST)
		);
	}
}

class AuthedClient implements ClientObject {
	var proxy:Client;
	var getIdToken:Void->Promise<String>;
	
	static inline var AUTH_SCHEME =
	#if (environment == "local") 'Direct'
	#else 'Berar'
	#end ;
	
	public function new(proxy, getIdToken) {
		this.proxy = proxy;
		this.getIdToken = getIdToken;
	}
	
	public function request(req:OutgoingRequest):Promise<IncomingResponse> {
		return getIdToken()
			.next(token -> proxy.request(new OutgoingRequest(
				req.header.concat([new HeaderField(AUTHORIZATION, '$AUTH_SCHEME $token')]),
				req.body
			)));
	}
}