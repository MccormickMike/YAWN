/////////////////////////////////////////////////YAWN MIDI Mapping/////////////////////////////////////////////////

(
var gitarInBus, snareInBus, bDrumInBus;

(
~inputs.do({ |input|

	switch(input[\name],

		\torfinnGitar,{ gitarInBus = input[\outBus] },
		\oskarSnare,{ snareInBus = input[\outBus] },
		\oskarBassTrigger,{ bDrumInBus = input[\outBus] },
	);
});
);

(
~functions = Dictionary[

	"numberOne" -> {
		72.do({ |i| ~miniAPC.noteOn(0,i,0)});
		[15,23,31].do({ |i| ~miniAPC.noteOn(0,i,5)});
		((8,16..56) ++ (9,17..57) ++ (10,18..58) ++ (14,22..62)).do({ |i| ~miniAPC.noteOn(0,i,5)});
		[28,29,39,55,60,61].do({ |i| ~miniAPC.noteOn(0,i,1)});
		((0..2)++(4..7)).do({ |i| ~miniAPC.noteOn(0,i,1);~miniAPC.noteOn(0,i+64,1)});

		MIDIdef.noteOn(\buttons,{ |val, num, chan, src|

			case
			// metronome
			{num == 7  and: {Pdef(\play1part1).isPlaying.not}}{Pdef(\play1part1).play;"metro 1 part 1 start".postln}
			{num == 15 and: {Pdef(\play1part1).isPlaying}}{~cues["numberOne"][\loop4cue] = false; "loop 4 cued".postln}
			{num == 23 and: {Pdef(\play1part1).isPlaying}}{~cues["numberOne"][\loop8cue] = false; "loop 8 cued".postln}
			{num == 31 and: {Pdef(\play1part1).isPlaying}}{~cues["numberOne"][\elevenRiffcue] = false; "eleven Riff cued".postln}
			{num == 39}{Pdef(\play1part1).stop; Pdef(\play1part2).play; "cue bombs".postln}
			{num == 55 and: {Pdef(\play1part3).isPlaying.not}}{Pdef(\play1part2).stop; Pdef(\play1part3).play;"metro 1 part 3 start".postln}
			{num == 71}{
				Pdef.all.keysDo({ |key|
					var playing = key.asString.contains("play1");

					if(playing and: {Pdef(key).isPlaying},{
						Pdef(key).stop;"metro 1 stop".postln
					})
				});
				"metro 1 stop".postln;
			}

			// granulator
			{num < 3 and: {Ndef(\grainer).isPlaying.not}}
			{
				Ndef(\grainer,~yawnSynths["grains"]).play(~busses["masterOut"],group: ~inGroup,addAction:\addToTail);
				Ndef(\grainer).set(\bufnum,~buffers[\water][4],\posRate,1,\posDev,0.01,\trigRate,0.2,\grainDur,0.8,\rate,1.0,\amp,0.7);
				"granulator ON".postln;
			}
			{num > 7 and: {num < 63} and: {num % 8 == 0} and: {Ndef(\grainer).isPlaying}}
			{
				var bufnum = num % 7;
				Ndef(\grainer).fadeTime =  2;
				Ndef(\grainer).xset(\bufnum,~buffers[\water][bufnum]);
				"granulator bufnum: %".format(bufnum).postln
			}

			// something here for the pads, \grainDur?
			{num > 7 and: {num < 63} and: {num % 8 == 1} and: {Ndef(\grainer).isPlaying}}
			{
				var grainSize = num.linexp(9,57,0.01,1);
				Ndef(\grainer).fadeTime =  2;
				Ndef(\grainer).xset(\grainDur,grainSize);
				"granulator grainDur: %".format(grainSize,round(0.01)).postln
			}

			{num > 7 and: {num < 63} and: {num % 8 == 2} and: {Ndef(\grainer).isPlaying}}
			{
				var posDev = num.linlin(10,58,0,1);
				Ndef(\grainer).fadeTime =  2;
				Ndef(\grainer).xset(\posDev,posDev);
				"granulator posDev: %".format(posDev.round(0.01)).postln
			}

			{num > 63 and: {num < 67} and: {Ndef(\grainer).isPlaying}}{Ndef(\grainer).end(0.8); "granulator OFF".postln}


			// gitar freeze & stutter
			{num == 4 and: {Ndef(\gitarFreeze).isPlaying.not} and: {Ndef(\gitarStutter).isPlaying.not}}
			{
				Ndef(\gitarFreeze,~yawnSynths["fftFreeze"]).play(~busses["masterOut"],group: ~inGroup,addAction:\addToTail);
				Ndef(\gitarFreeze).set(\inBus,gitarInBus,\dustTrig,1);
				"gitar freeze ON".postln;

				Ndef(\gitarStutter,~yawnSynths["brokenRecord"]).play(~busses["masterOut"],group: ~inGroup,addAction:\addToTail);
				Ndef(\gitarStutter).set(\inBus,gitarInBus,\dustTrig,1);
				"gitar stutter ON".postln;
			}
			{num == 68 and: {Ndef(\gitarFreeze).isPlaying} and: {Ndef(\gitarStutter).isPlaying}}
			{
				Ndef(\gitarFreeze).end;
				"gitar freeze OFF".postln;
				Ndef(\gitarStutter).end;
				"gitar stutter OFF".postln
			}
			{num == 28 and: {Ndef(\gitarFreeze).isPlaying}}{Ndef(\gitarFreeze).set(\t_trig,1);"gtr freeze trig".postln}
			{num == 60 and: {Ndef(\gitarStutter).isPlaying}}{Ndef(\gitarStutter).set(\t_trig,1);"gtr stutter trig".postln}


			// drum freeze & stutter
			{num == 5 and: {Ndef(\drumFreeze).isPlaying.not} and:{Ndef(\drumStutter).isPlaying.not}}
			{
				Ndef(\drumFreeze,~yawnSynths["fftFreeze"]).play(~busses["masterOut"],group: ~inGroup,addAction:\addToTail);
				Ndef(\drumFreeze).set(\inBus,snareInBus,\dustTrig,1);
				"drum freeze ON".postln;

				Ndef(\drumStutter,~yawnSynths["brokenRecord"]).play(~busses["masterOut"],group: ~inGroup,addAction:\addToTail);
				Ndef(\drumStutter).set(\inBus,snareInBus,\dustTrig,1);
				"drum stutter ON".postln;
			}
			{num == 69 and: {Ndef(\drumFreeze).isPlaying} and:{Ndef(\drumStutter).isPlaying}}
			{
				Ndef(\drumFreeze).end;
				"drum freeze OFF".postln;
				Ndef(\drumStutter).end;
				"drum stutter OFF".postln
			}
			{num == 29 and: {Ndef(\drumFreeze).isPlaying}}{Ndef(\drumFreeze).set(\t_trig,1);"drum freeze trig".postln}
			{num == 61 and: {Ndef(\drumStutter).isPlaying}}{Ndef(\drumStutter).set(\t_trig,1);"drum stutter trig".postln}


			// noize
			{num == 6 and: {Ndef(\noiseMakr).isPlaying.not}}
			{
				Ndef(\noiseMakr,~yawnSynths["noizer"]).play(~busses["masterOut"],group: ~inGroup,addAction:\addToTail);
				Ndef(\noiseMakr).set(\freq,4,\counter,3,\bits,12,\sampleRate,12,\amp,0.5);
				"noiseMakr ON".postln;
			}
			{num > 12 and: {num < 63} and: {num % 8 == 6} and: {Ndef(\noiseMakr).isPlaying}}{
				var count = num % 7;
				Ndef(\noiseMakr).set(\counter,count);
				"noiseMakr counter: %".format(count).postln
			}
			{num == 70 and: {Ndef(\noiseMakr).isPlaying}}{Ndef(\noiseMakr).end(10);"noiseMakr OFF".postln;}

		});

		MIDIdef.cc(\faders,{ |val, num, chan, src|
			var normLinVal,normExpVal;
			var sliderIndex,sliderVal;

			normLinVal = val.linlin(0,127,0,1);
			normExpVal = val.linexp(0,127,0.001,1);

			case
			{num == 48}{Ndef(\grainer).set(\trigRate,normExpVal.explin(0.001,1,0.25,250));"trigRate: %".format(normExpVal.explin(0.001,1,0.25,250).round(0.01)).postln}
			{num == 49}{Ndef(\grainer).set(\posRate,normExpVal.explin(0.001,1.0,0.5,2.0));"posRate: %".format(normExpVal.explin(0.001,1.0,0.5,2.0).round(0.01)).postln}
			{num == 50}{Ndef(\grainer).set(\rate,normLinVal.linlin(0,1,0.5,2.0));"rate: %".format(normLinVal.linlin(0,1,0.5,2.0).round(0.01)).postln}
			{num == 51}{"empty".postln}
			{num == 52}{Ndef(\gitarFreeze).set(\dustTrig,normLinVal * 4);Ndef(\gitarStutter).set(\dustTrig,normLinVal * 4);"dustTrigGitar: %".format((normExpVal * 4).round(0.01)).postln}
			{num == 53}{Ndef(\drumFreeze).set(\dustTrig,normLinVal * 4);Ndef(\drumStutter).set(\dustTrig,normLinVal * 4);"dustTrigDrum: %".format((normExpVal * 4).round(0.01)).postln}
			{num == 54}{Ndef(\noiseMakr).xset(\freq,(normExpVal * 100) % 0.9,\bits,normLinVal.linlin(0,1,12,16),\sampleRate,normLinVal.linlin(0,1,24,12));"noiseMakr val: %".format(normLinVal.round(0.01)).postln}
			{num == 55}{~busses["clickAmp"].set(normLinVal); "clickAmp: %".format(normLinVal.round(0.01)).postln}
			{num == 56}{Ndef(\output).set(\amp,normLinVal); "masterAmp: %".format(normLinVal.round(0.01)).postln};

			sliderIndex = (num - 48);
			sliderVal = normLinVal;
			~arrays["sliderVals"][sliderIndex] = sliderVal;

		});
	},

	"numberTwo" -> {
		72.do({ |i| ~miniAPC.noteOn(0,i,0)});
		[23,33,55].do({ |i| ~miniAPC.noteOn(0,i,1)});
		[39].do({ |i| ~miniAPC.noteOn(0,i,5)});
		8.do({ |i| ~miniAPC.noteOn(0,(i * 8) + 3,1)}); // buffers
		[5,67,68,69].do({ |i| ~miniAPC.noteOn(0,i,1)}); // reverb
		3.do({ |i|
			if(i < 2,{
				~miniAPC.noteOn(0,i,1);
				~miniAPC.noteOn(0,i + 64,1)
			},{
				~miniAPC.noteOn(0,7,1);
				~miniAPC.noteOn(0,71,1)
			});
		});

		MIDIdef.noteOn(\buttons,{ |val, num, chan, src|

			case
			// metronome
			{num == 7 and: {Pdef(\play2part1).isPlaying.not}}{
				var seconds = 15;

				Routine({
					seconds.wait;

					Pdef(\play2part1).play;

				}).play;

				"metro 2 part 1 starting in % seconds".format(seconds).postln;
			}
			{num == 23 and: {Pdef(\play2part2).isPlaying.not}}{Pdef(\play2part1).stop; Pdef(\play2part2).play;"metro 2 part 2 start".postln}
			{num == 55 and: {Pdef(\play2part3).isPlaying.not}}{Pdef(\play2part2).stop; Pdef(\play2part3).play;"metro 2 part 3 start".postln}

			{num == 71} //need a conditional statment here for \play2 patterns
			{
				Pdef.all.keysDo({ |key|
					var playing = key.asString.contains("play2");

					if(playing and: {Pdef(key).isPlaying},{Pdef(key).stop;"metro 2 stop".postln})
				});
				"metro 2 stop".postln
			}

			// cue
			{num == 39 and: {Pdef(\play2part2).isPlaying}}{~cues["numberTwo"][\open2cue] = false; "open 2 cued".postln}

			// eventually, guitar ducker...
			{num == 0}{"gitar ducker not installed".postln}

			// long delay
			{num == 1 and: {Ndef(\gitarDelay).isPlaying.not}}{
				Ndef(\gitarDelay,~yawnSynths["shiftDelay"]).play(~busses["masterOut"],group: ~inGroup,addAction:\addToTail);
				Ndef(\gitarDelay).set(\inBus,gitarInBus,\speed,0.1,\delay,0.3,\trig,0);
				"gitar delay ON".postln;
			}
			{num == 65 and: {Ndef(\gitarDelay).isPlaying}}{
				Ndef(\gitarDelay).end;
				"gitar delay OFF".postln;
			}
			// trig
			{num == 33 and: {Ndef(\gitarDelay).isPlaying}}{Ndef(\gitarDelay).set(\trig,1);"gitar delay trig".postln}

			//buffer playback
			{num % 8 == 3 and: {num < 67} and: {Ndef(\verb).isPlaying}}{
				var index = (num - 3) / 8;

				Synth(\stille,[\bufnum,~buffers[\harms][index],\pan,1.0.rand2,\amp,1,\outBus,~busses["reverbBus"],\detune,~busses["sliderControl"][4].getSynchronous],Ndef(\verb).nodeID,\addBefore)
				.map(\rate,~busses["sliderControl"][3]);
			}

			// reverb
			{num == 5 and: {Ndef(\verb).isPlaying.not}}{
				Ndef(\verb,{

					var sig = In.ar(\inBus.kr,2);
					var verb = HPF.ar(sig,600);
					verb = BHiShelf.ar(verb,2250,0.5,-12);
					verb = verb + CombC.ar(verb,1.0,1.0 * LFNoise2.ar(0.15).range(0.5,1.0),0.8,0.5);
					verb = FreeVerb2.ar(sig[0],sig[1],1,0.8,0.75);

					sig = XFade2.ar(sig,verb,\mix.kr(0.1) * 2 - 1);
				}).play(~busses["masterOut"],group: ~inGroup, addAction:\addToHead);

				Ndef(\verb).set(\inBus,~busses["reverbBus"]);
				"verb ON".postln;

			}
			{num == 69 and: {Ndef(\verb).isPlaying}}{
				Ndef(\verb).end;
				"verb OFF".postln;
			};

		});

		MIDIdef.cc(\faders,{ |val, num, chan, src|
			var normLinVal,normExpVal;
			var sliderIndex,sliderVal;

			normLinVal = val.linlin(0,127,0,1);
			normExpVal = val.linexp(0,127,0.001,1);

			case
			{num == 48}{"empty".postln}
			{num == 49}{Ndef(\gitarDelay).set(\amp,normLinVal);"delayAmp: %".format(normLinVal.round(0.01)).postln}
			{num == 50}{"empty".postln}
			{num == 51}{~busses["sliderControl"][3].set(normExpVal.explin(0.001,1,0.01,24.0)); "modRate: %".format(normExpVal.explin(0.001,1,0.01,24.0).round(0.01)).postln;}
			{num == 52}{~busses["sliderControl"][4].set(normExpVal.explin(0.001,1,0.97,0.97.reciprocal)); "detune: %".format(normExpVal.explin(0.001,1,0.97,0.97.reciprocal).round(0.01)).postln;}
			{num == 53}{Ndef(\verb).set(\mix,normLinVal); "verbMix: %".format(normLinVal.round(0.01)).postln;}
			{num == 54}{"empty".postln}
			{num == 55}{~busses["clickAmp"].set(normLinVal); "clickAmp: %".format(normLinVal.round(0.01)).postln}
			{num == 56}{Ndef(\output).set(\amp,normLinVal); "masterAmp: %".format(normLinVal.round(0.01)).postln};

			sliderIndex = (num - 48);
			sliderVal = normLinVal;
			~arrays["sliderVals"][sliderIndex] = sliderVal;
		})
	},

	"numberThree" -> {
		72.do({ |i| ~miniAPC.noteOn(0,i,0)});
		[6,70].do({ |i| ~miniAPC.noteOn(0,i,1)});
		~miniAPC.noteOn(0,39,5);
		3.do({ |i|
			if(i < 2,{
				~miniAPC.noteOn(0,i,1);
				~miniAPC.noteOn(0,i + 64,1)
			},{
				~miniAPC.noteOn(0,7,1);
				~miniAPC.noteOn(0,71,1)
			});
		});

		MIDIdef.noteOn(\buttons,{ |val, num, chan, src|

			case
			// metronome
			{num == 7 and: {Pdef(\play3).isPlaying.not}}{Pdef(\play3).play; "metro 3 start".postln}
			{num == 71 and: {Pdef(\play3).isPlaying}}{Pdef(\play3).stop; "metro 3 stop".postln}

			// cue
			{num == 39 and: {Pdef(\play3).isPlaying}}{~cues["numberThree"][\open3cue] = false; "open 3 cued".postln}

			// morph
			{num < 2 and: {Ndef(\gitarMorph).isPlaying.not}}
			{
				Ndef(\gitarMorph,~yawnSynths["morph"]).play(~busses["masterOut"], group:~inGroup, addAction:\addToTail);
				Ndef(\gitarMorph).set(\inBus,gitarInBus,\gain,1,\amp,0.001);
				"morph ON".postln;
			}
			{num > 63 and: {num < 66} and: {Ndef(\gitarMorph).isPlaying}}{Ndef(\gitarMorph).end; "morph OFF".postln}

			// intro track
			{num == 6}{
				var waitTime = 5;

				"intro starting in % seconds!!".format(waitTime).postln;

				Routine({
					waitTime.wait;
					Synth(\playbackMono,[\bufnum,~buffers[\intro],\amp,1,\outBus,~busses["masterOut"]]);
				}).play;
			}
			{num == 70 }{

				//figure out a way to stop the intro

				"doesn't work yet, use master volume".postln;
			}

		});

		MIDIdef.cc(\faders,{ |val, num, chan, src|
			var normLinVal,normExpVal;
			var sliderIndex,sliderVal;

			normLinVal = val.linlin(0,127,0,1);
			normExpVal = val.linexp(0,127,0.001,1);

			case
			{num == 48}{Ndef(\gitarMorph).set(\amp,normLinVal);"morphAmp: %".format(normLinVal.round(0.01)).postln}
			{num == 49}{Ndef(\gitarMorph).set(\gain,normLinVal.linlin(0.001,1,1.0,5.0));"morphGain: %".format(normLinVal.linlin(0.001,1,1.0,5.0).round(0.01)).postln}
			{num == 50}{"empty".postln}
			{num == 51}{"empty".postln}
			{num == 52}{"empty".postln}
			{num == 53}{"empty".postln}
			{num == 54}{"empty".postln}
			{num == 55}{~busses["clickAmp"].set(normLinVal); "clickAmp: %".format(normLinVal.round(0.01)).postln}
			{num == 56}{Ndef(\output).set(\amp,normLinVal); "masterAmp: %".format(normLinVal.round(0.01)).postln};

			sliderIndex = (num - 48);
			sliderVal = normLinVal;
			~arrays["sliderVals"][sliderIndex] = sliderVal;
		})
	},

	"numberFour" -> {
		72.do({ |i| ~miniAPC.noteOn(0,i,0)});
		~miniAPC.noteOn(0,39,5);
		~miniAPC.noteOn(0,6,1);
		4.do({ |i|
			if(i < 3,{
				~miniAPC.noteOn(0,i,1);
				~miniAPC.noteOn(0,i + 64,1)
			},{
				~miniAPC.noteOn(0,7,1);
				~miniAPC.noteOn(0,71,1)
			});
		});

		MIDIdef.noteOn(\buttons,{ |val, num, chan, src|

			case
			// metronome
			{num == 7 and: {Pdef(\play4).isPlaying.not}}{Pdef(\play4).play; "metro 4 start".postln}
			{num == 71 and: {Pdef(\play4).isPlaying}}{Pdef(\play4).stop; "metro 4 stop".postln}

			// cue
			{num == 39 and: {Pdef(\play4).isPlaying}}{~cues["numberFour"][\open4cue] = false; "open 4 cued".postln}

			// bit crusher
			{num < 3 and: {Ndef(\crusher).isPlaying.not}}
			{
				Ndef(\crusher,~yawnSynths["bitz"]).play(~busses["masterOut"], group: ~inGroup,addAction:\addToTail);
				Ndef(\crusher).set(\inBus,gitarInBus,\amp,0.3,\bits,1.0,\rate,1.0);
				"crusher ON".postln;
			}
			{num > 63 and: {num < 67} and: {Ndef(\crusher).isPlaying}}{Ndef(\crusher).end; "crusher OFF".postln}

			// bow
			{num == 6}{

				"bowing time in 15 seconds!!".postln;
				Routine({
					10.wait;
					Synth(\playbackMono,[\bufnum,~buffers[\bow],\amp,1,\outBus,~busses["masterOut"]]);
				}).play;

			};
		});

		MIDIdef.cc(\faders,{ |val, num, chan, src|
			var normLinVal,normExpVal;
			var sliderIndex,sliderVal;

			normLinVal = val.linlin(0,127,0,1);
			normExpVal = val.linexp(0,127,0.001,1);

			case
			{num == 48}{Ndef(\crusher).set(\amp,normLinVal); "crusherAmp: %".format(normLinVal.round(0.01)).postln}
			{num == 49}{Ndef(\crusher).set(\bits,normExpVal.clip(0.05,1.0)); "crusherBits: %".format(normExpVal.clip(0.05,1.0).round(0.01)).postln}
			{num == 50}{Ndef(\crusher).set(\rate,normExpVal); "crusherRate: %".format(normExpVal.round(0.01)).postln}
			{num == 51}{"empty".postln}
			{num == 52}{"empty".postln}
			{num == 53}{"empty".postln}
			{num == 54}{"empty".postln}
			{num == 55}{~busses["clickAmp"].set(normLinVal); "clickAmp: %".format(normLinVal.round(0.01)).postln}
			{num == 56}{Ndef(\output).set(\amp,normLinVal); "masterAmp: %".format(normLinVal.round(0.01)).postln};

			sliderIndex = (num - 48);
			sliderVal = normLinVal;
			~arrays["sliderVals"][sliderIndex] = sliderVal;
		});


	},

	"empty" -> {
		72.do({ |i| ~miniAPC.noteOn(0,i,0)});
		MIDIdef(\buttons).free;
		MIDIdef(\faders).free;
	},
];
);

"MIDI mapping loaded".postln;

)