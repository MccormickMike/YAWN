/////////////////////////////////////////////////YAWN Startup/////////////////////////////////////////////////

(
var server = Server.default;

server.waitForBoot({
	Pdef.all.clear;
	MIDIdef.all.clear;
	Ndef.all.clear;
	server.freeAll;

	server.sync;

	PathName(PathName(thisProcess.nowExecutingPath).parentPath +/+ "LIVE Setup/").entries.do({ |entry|

		if(entry.isFile,{
			entry.fullPath.load;
		},{
			entry.entries.do({ |click|
				click.fullPath.load;
			})
		});
		server.sync;
	});

	// also, make a folder with the setlist and maybe the dictionary files -> the only ones that need to be accessed to change ins/outs, set order, etc.
	// also, add a command to load a server meter in the top right hand corner of the screen! Or add it to GUI?

	"\n\nYAWN Live Setup Ready".postln;

});
)

START CUE BETWEEN FIRE & TRE


