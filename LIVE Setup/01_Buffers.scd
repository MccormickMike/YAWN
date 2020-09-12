/////////////////////////////////////////////////YAWN Bufers/////////////////////////////////////////////////

(
var server = Server.default;

// this could surely be cleaner, no?
var path = PathName(PathName(thisProcess.nowExecutingPath).parentPath).parentPath +/+ "Samples";

~buffers = Dictionary[

	// cue bell
	\bell -> Buffer.readChannel(server,path +/+ "Bell.wav",channels: [0]),

	// intro track
	\intro -> Buffer.readChannel(server,path +/+ "Intro.wav",channels: [0]),

	// bow cue
	\bow -> Buffer.readChannel(server,path +/+ "Bukke.wav",channels: [0]),

	// #1
	\water -> PathName(path +/+ "Water/").entries.collect({
		arg sf;
		Buffer.readChannel(server,sf.fullPath,channels: [0])
	}),

	\harms -> PathName(path +/+ "Harm/").entries.collect({
		arg sf;
		Buffer.readChannel(server,sf.fullPath,channels: [0,1])
	}),
];

"buffers loaded".postln;
)