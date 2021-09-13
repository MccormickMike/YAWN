/////////////////////////////////////////////////YAWN SynthDefs/////////////////////////////////////////////////

(
(
SynthDef(\click,{
	var env = Env.perc(\atk.kr(0.01),\rls.kr(0.25),1.0,\curve.kr(-4)).kr(2);
	var sig = LFTri.ar(\freq.kr(1000));
	sig = LPF.ar(sig,8000);
	sig = Pan2.ar(sig,\pan.kr(0),\amp.kr(0.5));
	Out.ar(\outBus.kr(0),sig*env);

}).add;

// needs to be \playbackMono, need to add \playbackStereo
// also, I need to figure something out with envelopes, no?

SynthDef(\playbackMono,{
	var bufnum = \bufnum.kr;
	var sig = PlayBuf.ar(1,bufnum,BufRateScale.kr(bufnum) * \rate.kr(1),doneAction: 2);
	sig = Pan2.ar(sig,\pan.kr(0),\amp.kr(1));
	Out.ar(\outBus.kr,sig);
}).add;

SynthDef(\stille,{
	var bufnum = \bufnum.kr;
	var sig = PlayBuf.ar(2,bufnum,BufRateScale.kr(bufnum) * \detune.kr(1,1),doneAction:2);
	sig = sig * LFPulse.kr(\rate.kr(0.01,2),ExpRand(0.001,0.5),Rand(0.5,0.75)).range(0.0,1.0);
	sig = Balance2.ar(sig[0],sig[1],\pan.kr(0),\amp.kr(0.5));
	Out.ar(\outBus.kr(0),sig)
}).add;

SynthDef(\newGrains,{
	var bufnum = \bufnum.kr;
	var jitter = \jitter.kr(0).linlin(0,1,0,0.001);
	var frames = BufFrames.kr(bufnum);
	var pos = Phasor.ar(0,BufRateScale.kr(bufnum) * \rate.kr(1),\start.kr(0) * frames, \end.kr(1) * frames);
	var sig = BufRd.ar(1,bufnum,pos + (LFNoise1.kr(100).range(jitter.neg,jitter) * frames));
	sig = sig * Env.asr(\atk.kr(0.01),1,\rls.kr(0.01),\curve.kr(-4)).kr(2,\gate.kr(1));
	sig = Pan2.ar(sig, \pan.kr(0),\amp.kr(1));
	Out.ar(\outBus.kr(0),sig)
}).add;

SynthDef(\input,{
	var sig = SoundIn.ar(\inBus.kr);
	sig = Compander.ar(sig,sig,\compThresh.kr(0.5),1,0.5,0.01,0.01);
	Out.ar(\outBus.kr,sig * \amp.kr(1));
}).add;

SynthDef(\inputStereo,{
	var inBus = \inBus.kr;
	var sig = SoundIn.ar([inBus,inBus+1]);
	sig = Compander.ar(sig,sig,\compThresh.kr(0.5),1,0.5,0.01,0.01);
	sig = sig.sum;
	Out.ar(\outBus.kr,sig * \amp.kr(1));
}).add;

SynthDef(\masterOut,{
	var sig = In.ar(\inBus.kr,2);
	sig = Compander.ar(sig,sig,0.5,1,0.5,0.01,0.01);
	Out.ar(\outBus.kr,sig * \amp.kr(1));
}).add;
);

(
~yawnSynths = Dictionary[

	"fftFreeze" -> {
		var frames = 2048;
		var sig = In.ar(\inBus.kr,1);
		var trigFreq = \dustTrig.kr().clip(0.75,4);
		var trig = Dust.kr(trigFreq) + \trig.tr;
		trig = Trig.kr(trig,trigFreq.reciprocal);
		sig = FFT(LocalBuf(frames),sig);
		sig = PV_Freeze(sig,trig);
		sig = IFFT(sig);
		sig = Pan2.ar(sig * trig,TRand.kr(-1.0,1.0,trig),\amp.kr(1));
	},

	"brokenRecord" -> {
		var sig = In.ar(\inBus.kr,1);
		var trig = Dust.kr(\dustTrig.kr) + \trig.tr;
		var gate = Env.sine(0.1).kr(gate:trig);
		var rand = TRand.kr(0.01,0.6,trig);
		sig = CombC.ar(sig * gate,0.6,rand,Select.kr(1 - Trig1.kr(trig,0.01),[0,inf]));
		sig = Pan2.ar(sig,TRand.kr(-1.0,1.0,trig),\amp.kr(1));
	},

	"shiftDelay" -> {
		var sig = In.ar(\inBus.kr,1);
		var mute = ToggleFF.kr(\trig.tr);
		var local = LocalIn.ar(2);
		sig = DelayC.ar((sig*(1-mute))+local,1.5,LFNoise1.ar((\speed.kr.clip(0.05,7))!2).range(0.2,\delay.kr.clip(0.3,1.5)));
		LocalOut.ar((sig.reverse)*Select.kr(mute,[0.75,1]));
		sig = LeakDC.ar(sig);
		sig = Splay.ar(sig,1,\amp.kr(1));
	},

	"bitz" -> {
		var sig = In.ar(\inBus.kr,1);
		sig = Decimator.ar(sig,SampleRate.ir * \rate.kr(1), 24 * \bits.kr(1));
		sig = Pan2.ar(sig,\pan.kr(0),\amp.kr(0.8));
	},

	"morph" -> {
		var voices = 10;
		var freq = {500.exprand(1500.0)}!voices;
		var sig = In.ar(\inBus.kr,1);

		sig = sig * LFNoise2.kr(0.5).range(0.8,1.2);

		sig = RLPF.ar(sig,freq*LFNoise2.kr({0.5.exprand(10.0)}!voices).range(0.5,2.0),0.08);
		sig = AllpassC.ar(sig,0.02,0.02,0.1);
		sig = (sig * \gain.kr(1)).clip(-1.0,1.0);
		sig = Splay.ar(sig,1);
		sig = FreeVerb2.ar(sig[0],sig[1],0.3,100,0.4);
		sig = sig * \amp.kr(0.5) * SinOsc.kr(LFNoise2.kr(1!2).range(2.0,8.0)).abs;
	},

	"grains" -> {
		var bufnum = \bufnum.kr;
		var posDev = \posDev.kr(0.01);

		var posLo = 0.0;
		var posHi = 1.0;
		var trig = Impulse.kr(\trigRate.kr(1));

		var bufDur = BufDur.kr(bufnum);
		var posDif = posHi - posLo;
		var bufDurSection = bufDur * posDif;

		var pos = posLo * bufDur +
		(Phasor.ar(0, BufRateScale.kr(bufnum) * \posRate.kr(1) / SampleRate.ir,
			posLo * bufDur,
			posHi * bufDur)
		+
		(TRand.kr(-0.5 * posDev, 0.5 * posDev, trig) * bufDur)).mod(bufDurSection);

		var pan = (TRand.kr(-1.0, 1.0, trig));
		var sig = TGrains.ar(2,trig,bufnum,\rate.kr(1),pos,\grainDur.kr(0.1),pan,\amp.kr(1));

		Limiter.ar(sig);
	},

	"newGrains" -> {
		var bufnum = \bufnum.kr;
		var jitter = \jitter.kr().linlin(0,1,0,0.0005);
		var frames = BufFrames.kr(bufnum);
		var pos = Phasor.ar(0,BufRateScale.kr(bufnum) * \rate.kr(1),\start.kr(0) * frames, \end.kr(1) * frames);
		var sig = BufRd.ar(1,bufnum,pos + LFNoise1.kr(1).range(jitter.neg,jitter));
		sig = sig * Env.asr(\atk.kr(0.01),1,\rls.kr(0.01),\curve.kr(-4)).kr(2,\gate.kr(1));
		sig = Pan2.ar(sig, \pan.kr(0),\amp.kr(1));
	},

	"noizer" -> {
		var sr = SampleRate.ir / \sampleRate.kr(12);
		var n = \bits.kr(12).clip(12,24); //bit resolution
		var t= Phasor.ar(1,\freq.kr(8) * ((2**n)/sr),0,((2**n)-1));
		var env = Env.asr(releaseTime: 0.01).kr(2,\gate.kr(1));

		t = Select.ar(\counter.kr(0),[

			t*(((t>>64)|(t>>8))&(63&(t>>4))),
			t*(((t>>9)|(t>>13))&(25&(t>>6))),
			t*(((t>>5)|(t>>8)) & 63),
			t*(((t>>11)&(t>>8))&(123&(t>>3))),
			t*(t>>8*((t>>15)|(t>>8))&(20|(t>>19)*5>>t|(t>>3))),
			t*(t>>((t>>9)|(t>>8))&(63&(t>>4))),
			(t>>7|t|t>>6)*10+4*(t&t>>13|t>>6)
		]);

		t = t % (2**(n)); // avoiding number beyond 2**(bit resolution)
		t = t*(0.5**(n-1)) - 1; // scaling to -1, 1
		t = LeakDC.ar(t);
		Pan2.ar(t * env,0,\amp.kr(0.3));
	},

]
);
"synths loaded".postln;
)