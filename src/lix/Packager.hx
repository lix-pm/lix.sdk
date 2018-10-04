package lix;

import archive.*;
import archive.zip.Zip;

using tink.io.Source;

class Packager {
	var zip:Zip;
	var scanner:Scanner;
	
	public function new(zip, scanner) {
		this.zip = zip;
		this.scanner = scanner;
	}
	
	public function pack():RealSource {
		var entries = scanner.scan().filter(entry -> true); // TODO: filter with .lixignore
		return zip.pack(entries);
	}
}