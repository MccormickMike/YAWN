/////////////////////////////////////////////////YAWN Pdefs/////////////////////////////////////////////////

//bars of clicks
(
~bars = {
	arg tempo = 60;
	var dur,key;

	dur = tempo/60;
	key = "t%q1".format(tempo).asSymbol;

	if(Pdef.all.includesKey(key).not,{

		8.do({
			arg index;
			var array;

			if(index != 0,
				{
					array = (1!index).collect(
						{arg i,j; if(j == 0,{i * 2},{i})}
					);
			});

			if(array.isNil.not,{

				Pdef("t%q%".format(tempo,index).asSymbol,
					Pbind(
						\instrument, \click,
						\dur, Pseq([1],inf),
						\freq, Pseq(1000 * array,1),
						\tempo, Pseq([dur],inf),
						\amp, Pfunc({~busses["clickAmp"].getSynchronous}),
						\outBus, ~outputs["click"],
					)
				);

				Pdef("t%e%".format(tempo,index).asSymbol,
					Pbind(
						\instrument, \click,
						\dur, Pseq([1/2],inf),
						\freq, Pseq(1000 * array,1),
						\tempo, Pseq([dur],inf),
						\amp, Pfunc({~busses["clickAmp"].getSynchronous}),
						\outBus, ~outputs["click"],
					)
				);
			});
		});
		"% bpm".format(tempo).postln;
	},
	{"duplicate tempo".postln;})
};
"~bars function created".postln;
)