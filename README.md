# SDK for the Lix Registry

## Usage Examples

#### Check if user is currently logged in

```haxe
var auth = new lix.Auth();
trace(auth.isSignedIn());
```

#### Get the current user session

```haxe
var auth = new lix.Auth();
auth.getSession().handle(function(o) trace(o.sure()));
```

#### Initiate tink_web Remote of the server API

```haxe
var auth = new lix.Auth();
var remote = new lix.Remote(
	#if (environment == "local") new NodeClient() #else new SecureNodeClient() #end, 
	() -> auth.getSession().next(session -> session.idToken)
);
// try it:
remote.version().handle(o -> trace(o.sure()));
```

#### Submit current directory to the Lix Registry

```haxe
var submitter = new lix.Submitter(remote, new archive.zip.NodeZip(), archive.scanner.AsysScanner.new.bind(_, ''));
submitter.submit(Sys.getCwd()).handle(o -> trace(o.sure()));
```