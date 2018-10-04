package lix;

import archive.*;
import archive.zip.Zip;

using tink.CoreApi;
using tink.io.Source;
using tink.streams.RealStream;

class Packager {
	var zip:Zip;
	var scanner:Scanner;
	var ignore:Ignore;
	
	public function new(zip, scanner, ?options:PackagerOptions) {
		this.zip = zip;
		this.scanner = scanner;
		
		var patterns = switch options {
			case null | {ignore: null}: [];
			case {ignore: v}: v.split('\n');
		}
		patterns.push('.git');
		patterns.push('.DS_Store');
		ignore = new Ignore(patterns);
	}
	
	public function pack():RealSource {
		return zip.pack(scanner.scan().filter((entry:Entry<Error>) -> !ignore.ignores(entry.name)));
	}
}

class Ignore {
	var ignore:Dynamic;
	public inline function new(entries:Array<String>) {
		ignore = js.Lib.require('ignore')().add(entries);
	}
		
	public inline function ignores(path:String) {
		return ignore.ignores(path);
	}
}

typedef PackagerOptions = {
	?ignore:String,
}