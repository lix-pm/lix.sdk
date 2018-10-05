package lix;

import haxe.DynamicAccess;
import tink.semver.Version;
import tink.semver.Resolve;
import tink.semver.Constraint;

typedef Manifest = {
	?owner:String,
	name:String,
	classPaths:Array<String>,
	version:Version,
	dependencies:DynamicAccess<Constraint>,
	haxe:Constraint,
	?authors:Array<String>,
	?license:String,
	?tags:Array<String>,
	?url:String,
	?description:String,
	?hooks:{
		?postInstall:String,
		?postDownload:String,
	}
}