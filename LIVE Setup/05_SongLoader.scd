/////////////////////////////////////////////////YAWN MIDIDefs/////////////////////////////////////////////////

(
(
MIDIClient.init;
MIDIIn.connectAll;

~miniAPC = MIDIOut.newByName("APC MINI","APC MINI");
128.do({ |i| ~miniAPC.noteOn(0,i,0);});

);

(
MIDIdef.noteOn(\songLoader,{ |val, num, chan, src|

	case
	{num < 82 and: {~arrays["loadSong"][0].sum == 0}}
	{"load song first".warn}

	//load song column
	{num > 81 and: {num < 90}}
	{
		var songIndex = num - 82;

		// function
		~arrays["currentSong"] = ~setList[songIndex][\song];
		~arrays["loadSong"][1][songIndex].value;
		{~drawGui.value(~arrays["currentSong"], ~arrays["sliderVals"])}.defer;

		// lights
		case
		{~arrays["loadSong"][0].sum == 0}
		{
			8.do({ |i| ~miniAPC.noteOn(0,i+82,0)});
			~miniAPC.noteOn(0,num,1);
			~arrays["loadSong"][0][songIndex] = 1;
		}

		{~arrays["loadSong"][0].sum == 1 and: {~arrays["loadSong"][0][songIndex] == 0}}
		{
			~arrays["loadSong"][0].size.do({ |i| ~miniAPC.noteOn(0,82 + i,0)});
			~arrays["loadSong"][0].size.do({ |i| ~arrays["loadSong"][0][i] = 0});
			~arrays["loadSong"][0][songIndex] = 1;
			~miniAPC.noteOn(0,num,1);

		};
		"song % loaded".format(~setList[songIndex][\song]).postln;
	}

	// reset the board
	{num == 98}
	{
		128.do({ |i| ~miniAPC.noteOn(0,i,0) });
		~arrays["loadSong"][0] = Array.fill(8,{0});
		Pdef.all.keysDo({ |i| Pdef(i).stop});
		"controller reset".postln;

		(
			~cues = Dictionary.with(*[

				// this should be a function: ~cues.keysDo({arg key; key = true}) or something...avoid manual additions to this functions!
				// in order for that to work, I think the ~cues dictionary needs to be written differently...maybe not events?

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
	};

	// maybe this needs to reset all ndefs/pdefs?
	// can free all ndefs except inputs/output??

});
);

"MIDIdefs loaded".postln;
)