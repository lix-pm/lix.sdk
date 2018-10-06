package lix;

import haxe.DynamicAccess;
import tink.semver.Version;
import tink.semver.Constraint;

typedef Manifest = {
	?owner:String, // when omited, defaults to the current session's username
	name:String,
	classPaths:Array<String>,
	version:Version,
	dependencies:Array<Dependency>,
	haxe:Constraint,
	?authors:Array<String>,
	?license:String,
	?tags:Array<String>,
	?url:String,
	?description:String,
	?hooks:{
		?postInstall:String,
		?postDownload:String,
	},
	?custom:DynamicAccess<Dynamic>,
}

typedef Dependency = {
	name:String,
	version:Constraint,
}