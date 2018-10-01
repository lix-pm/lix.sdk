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
	public inline function new(client, getIdToken) {
		this = new tink.web.proxy.Remote<lix.api.Root>(
			new AuthedClient(client, getIdToken), 
			new RemoteEndpoint(API_SERVER_HOST)
		);
	}
}

class AuthedClient implements ClientObject {
	var proxy:Client;
	var getIdToken:Void->Promise<String>;
	
	public function new(proxy, getIdToken) {
		this.proxy = proxy;
		this.getIdToken = getIdToken;
	}
	
	public function request(req:OutgoingRequest):Promise<IncomingResponse> {
		return getIdToken()
			.next(token -> proxy.request(new OutgoingRequest(
				req.header.concat([new HeaderField(AUTHORIZATION, 'Bearer $token')]),
				req.body
			)));
	}
}