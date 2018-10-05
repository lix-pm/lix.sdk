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
		var manifest:Manifest = tink.Json.parse(content);
		var lixignore = @:await Path.join([directory, '.lixignore']).getContent().recover(_ -> cast Future.NULL);
		var packager = new Packager(zip, getScanner(directory), {ignore: lixignore});
		
		var me = @:await remote.me().get();
		var owner = manifest.owner == null ? me.username : manifest.owner;
		var slug = owner + '/' + manifest.name;
		
		// create project if not exists
		@:await remote.projects().byId(slug).info()
			.next(project -> Noise)
			.tryRecover(e -> {
				if(e.code == NotFound)
					remote.owners().byName(owner).projects().create(manifest);
				else
					e;
			});
		
		var version = @:await remote.projects().byId(slug).versions().create({
			version: manifest.version,
			dependencies: [for (dep in manifest.dependencies) {name: dep.name, constraint: dep.version}],
			haxe: manifest.haxe,
		});
		var request = @:await remote.projects().byId(slug).versions().ofVersion(manifest.version).upload();
		var response = @:await fetch(request.url, {
			method: request.method,
			body: packager.pack().idealize(_ -> Source.EMPTY),
		}).all();
		return Noise;
	}
}