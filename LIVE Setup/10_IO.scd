/////////////////////////////////////////////////YAWN I/O/////////////////////////////////////////////////

//generate inputs
(
(
~inputs.size.do({ |index|

	case
	{~inputs[index][\inBus].size == 1}
	{
		Ndef(~inputs[index][\name],\input).play(group:~inGroup);
		Ndef(~inputs[index][\name]).set(\inBus,~inputs[index][\inBus],\outBus,~inputs[index][\outBus]);
	}
	{~inputs[index][\inBus].size == 2}
	{
		Ndef(~inputs[index][\name],\inputStereo).play(group:~inGroup);
		Ndef(~inputs[index][\name]).set(\inBus,~inputs[index][\inBus][0],\outBus,~inputs[index][\outBus]);
	}
	{~inputs[index][\inBus].size == 0}
	{"no hardware input specified on input %".format(index).warn}
	{~inputs[index][\inBus].size > 2}
	{"multichannel not supported on input %".format(index).warn};

})
);

(
Ndef(\output,\masterOut).play(~outputs["master"],group:~inGroup,addAction:\addToTail);
Ndef(\output).set(\inBus,~busses["masterOut"],\amp,0.7);
);

"inputs & outputs loaded".postln;
)
