package lix;

import haxe.DynamicAccess;
import tink.semver.Version;
import tink.semver.Resolve;
import tink.semver.Constraint;

typedef Json = {
	name:String,
	license:String,
	tags:Array<String>,
	classPaths:Array<String>,
	contributors:Array<String>,
	releaseNote:String,
	version:Version,
	dependencies:DynamicAccess<Constraint>,
	haxe:Constraint,
	?hooks:{
		?postInstall:String,
		?postDownload:String,
	}
}