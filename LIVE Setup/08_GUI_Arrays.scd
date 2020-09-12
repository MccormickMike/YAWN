/////////////////////////////////////////////////YAWN GUI Dictionary/////////////////////////////////////////////////

(
(
~setArray = Dictionary();

~setList.keysValuesDo({
	arg key,value;

	~setArray.put(value.song,key);
});
);

(
~guiInfo = Dictionary[

	"numberOne" -> (

		songButt: ~setArray["numberOne"],
		modButtsOn: [
			[4,3,"freeze \ntrig"],
			[4,7,"stutter \ntrig"],
			[5,3,"freeze \ntrig"],
			[5,7,"stutter \ntrig"],
			[7,4,"part 2 start"],
			[7,6,"part 3 start"]
		],
		modButtsMid:(
			7.collect({arg i;
				[0,i+1,"bufnum: %".format(i)]
			})
			++
			7.collect({arg i;
				[1,i+1,"grainDur: %".format(i)]
			})
			++
			7.collect({arg i;
				[2,i+1,"posDev: %".format(i)]
			})
			++
			7.collect({arg i;
				[6,i+1,"counter: %".format(i)]
			})
			++
			3.collect({ arg i;
				var cue = [4,8,11];
				[7,i+1,"loop cue: %".format(cue[i])]
			})
		),
		onButts: [[0,1,2,4,5,6,7],[0],["on"!6 ++ ["part 1 start"]].flatten(1)].flop,
		offButts: [0,1,2,4,5,6,7],
		labels: ["grainer\ntrigRate","grainer\nposRate","grainer\nrate",nil,"git frz/\nstutter","drum frz/\nstutter","noizMakr"],

	),

	"numberTwo" -> (

		songButt: ~setArray["numberTwo"],
		modButtsOn: [
			[1,4,"close gate"],
			[3,0,"F forward"],
			[3,1,"F# forward"],
			[3,2,"G# forward"],
			[3,3,"A forward"],
			[3,4,"F reverse"],
			[3,5,"F# reverse"],
			[3,6,"G# reverse"],
			[3,7,"A reverse"],
			[7,2,"part 2 start"],
			[7,6,"part 3 start"],
		],
		modButtsMid: [[7,4,"open 2 cue"]],
		onButts: [[0,1,5,7],[0],["on","on","verb\non","part 1 start"]].flop,
		offButts: [0,1,3,4,5,7],
		labels: ["ducker\n(not yet)","long\ndelay",nil,"ampMod\nRate","detune","verb\nmix",nil],
	),

	"numberThree" -> (

		songButt: ~setArray["numberThree"],
		modButtsMid: [[7,4,"open 3 cue"]],
		onButts: [[0,1,6,7],[0],["on","on","intro\ntrack","start"]].flop,
		offButts: [0,1,6,7],
		labels: ["morph\namp","morph\ngain"] ++ (nil!5),
	),

	"numberFour" -> (

		songButt: ~setArray["numberFour"],
		modButtsMid: [[7,4,"open 4 cue"]],
		onButts: [[0,1,2,6,7],[0],["on","on","on","bukke","start"]].flop,
		offButts: [0,1,2,7],
		labels: ["crusher\namp","crusher\nbits","crusher\nrate"] ++ (nil!4),
	),

	"empty" -> (
		labels: nil!8,

	),
]
);

"guiArrays loaded".postln;
)

[[3],(0..8),["F forward","F# forward","G# forward","A forward","F reverse","F# reverse","G# reverse","A reverse"]].flop