package lix;

import archive.*;
import archive.zip.*;
import tink.http.Client.*;

using asys.io.File;
using haxe.io.Path;
using tink.CoreApi;
using tink.io.Source;

@:await
class Submitter {
	
	var remote:Remote;
	var zip:Zip;
	var getScanner:(directory:String)->Scanner;
	
	public function new(remote, zip, getScanner) {
		this.remote = remote;
		this.zip = zip;
		this.getScanner = getScanner;
	}
	
	@:async public function submit(?directory:String) {
		if(directory == null) directory = Sys.getCwd();
		var content = @:await Path.join([directory, 'lix.json']).getContent();
		var json:Json = tink.Json.parse(content);
		var lixignore = @:await Path.join([directory, '.lixignore']).getContent().recover(_ -> cast Future.NULL);
		var packager = new Packager(zip, getScanner(directory), {ignore: lixignore});
		var version = @:await remote.projects().byId(json.name).versions().create({
			version: json.version,
			dependencies: [for(lib in json.dependencies.keys()) {name: lib, constraint: json.dependencies[lib]}],
			haxe: json.haxe,
		});
		var request = @:await remote.projects().byId(json.name).versions().ofVersion(json.version).upload();
		var response = @:await fetch(request.url, {
			method: request.method,
			body: packager.pack().idealize(_ -> Source.EMPTY),
		}).all();
		return Noise;
	}
}