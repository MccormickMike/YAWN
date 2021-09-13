/////////////////////////////////////////////////YAWN Data/////////////////////////////////////////////////
(
var server = Server.default;

//can be used to slow everything down for rehearsals...?
TempoClock.default.tempo_(60/60); // can be removed?
Ndef.all.fadeTime = 3.0; // also change / remove

( // make this a dictionary as well...perhaps in the dictionary below?
~inGroup = Group(s,\addToHead);
~outGroup = Group(s,\addToTail);
);

(
~arrays = Dictionary[

	//Also, "loadSong" can be a 1D array filled with the fuction below and then !2, right?

	"loadSong" -> Array.fill2D(2,8,{0}), // this could be cleaner..integrate .do function below, but maybe there's a better way to have a flexible setlist?

	//this is for GUI stuff! Might not be needed evenutally....
	"currentTime" -> [0,0],
	"sliderVals" -> Array.fill(9,{0}),
	"currentSong" -> [0],
]
);

(
~arrays["loadSong"][1].size.do({ |i|
	~arrays["loadSong"][1][i] = {~functions[(~setList[i][\song])].value};
})
);

(
~busses = Dictionary.with(*[

	"sends" -> Array.fill(8,{Bus.audio(server,1)}),
	"sliderControl" -> Array.fill(8,{Bus.control(server,1)}),

	"masterOut" -> Bus.audio(server,2),
	"reverbBus" -> Bus.audio(server,2),
	"clickAmp" -> Bus.control(server,1).set(0.25),

]);
);

// define hardware inputs/outputs
(
~inputs = Dictionary.with(*[

	0 -> (
		inBus: [0,1],
		name: \torfinnGitar,
		outBus:~busses["sends"][0]
	),

	1 -> (
		inBus: [2],
		name: \oskarBassTrigger,
		outBus:~busses["sends"][1]
	),

	2 -> (
		inBus: [3],
		name: \oskarSnare,
		outBus:~busses["sends"][2]
	),
]);
);

(
~cues = Dictionary.with(*[

	"numberOne" -> (

		loop4cue: true,
		loop8cue: true,
		elevenRiffcue: true,
	),

	"numberTwo" -> (
		open2cue: true,
	),

	"numberThree" -> (
		open3cue: true,
	),

	"numberFour" -> (
		open4cue: true,
	),
]);
);

(
~outputs = Dictionary.with(*[

	"master" -> 0,
	"click" -> 2,

]);
);

"\ndata/dictionaries loaded".postln;
)