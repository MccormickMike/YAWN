/////////////////////////////////////////////////YAWN SynthDefs/////////////////////////////////////////////////

(
(
SynthDef(\click,{
	arg freq=840,atk=0.01,rls=0.05,curve=4,amp=0.5,pan=0,outBus;
	var sig,env,freqEnv;

	env = EnvGen.kr(Env.perc(atk,rls,1.0,curve),1,doneAction: 2);
	freqEnv = EnvGen.ar(Env([10,1],[0.03],\exp),timeScale: rls+atk);
	freq = freq + freq/2;

	sig = LFTri.ar(freq * freqEnv);
	sig = LPF.ar(sig,10000);
	sig = Pan2.ar(sig,pan,amp);
	Out.ar(outBus,sig*env);

}).add;

// needs to be \playbackMono, need to add \playbackStereo
// also, I need to figure something out with envelopes, no?
SynthDef(\playback,{
	arg bufnum,rate=1,amp=0.5,pan=0,outBus;
	var sig;

	sig = PlayBuf.ar(1,bufnum,BufRateScale.kr(bufnum) * rate,doneAction: 2);
	sig = Pan2.ar(sig,pan,amp);
	Out.ar(outBus,sig);

}).add;

SynthDef(\stille,{
	var bufnum = \bufnum.kr;
	var sig = PlayBuf.ar(2,bufnum,BufRateScale.kr(bufnum) * \detune.kr(1,1),doneAction:2);

	sig = sig * LFPulse.kr(\rate.kr(0.01,2),ExpRand(0.001,0.5),Rand(0.5,0.75)).range(0.0,1.0);

	sig = Balance2.ar(sig[0],sig[1],\pan.kr(0),\amp.kr(0.5));
	Out.ar(\outBus.kr(0),sig)

}).add;

SynthDef(\input,{
	arg inBus,compThresh=0.5,amp=1,outBus;
	var sig;

	sig = SoundIn.ar(inBus);
	sig = Compander.ar(sig,sig,compThresh,1,0.5,0.01,0.01);

	Out.ar(outBus,sig*amp);

}).add;

SynthDef(\inputStereo,{
	arg inBus,compThresh=0.5,amp=1,outBus;
	var sig;

	sig = SoundIn.ar([inBus,inBus+1]);
	sig = Compander.ar(sig,sig,compThresh,1,0.5,0.01,0.01);
	sig = sig.sum;

	Out.ar(outBus,sig*amp);

}).add;

SynthDef(\masterOut,{
	arg inBus,amp=1,outBus;
	var sig;

	sig = In.ar(inBus,2);
	sig = Compander.ar(sig,sig,0.5,1,0.5,0.01,0.01);
	Out.ar(outBus,sig*amp);

}).add;
);

(
~yawnSynths = Dictionary[

	"fftFreeze" -> {
		arg inBus,dustTrig,t_trig,amp=1.0;
		var chain,trig,env,sig;
		var frames=4096;

		sig = In.ar(inBus,1);
		trig = Dust.kr(dustTrig) + t_trig;
		trig = Trig.kr(trig,TRand.kr(0.3,0.5,trig));
		chain = FFT(LocalBuf(frames), sig, 0.5, 0, 1, frames);
		chain = PV_Freeze(chain,trig);
		sig = IFFT(chain);
		sig = Pan2.ar(sig*trig,TRand.kr(-1.0,1.0,trig),amp);
	},

	"brokenRecord" -> {
		arg inBus,t_trig,dustTrig,amp=0.8;
		var gate,rand,sig,sig1,trig;

		sig = In.ar(inBus,1);
		trig = Dust.kr(dustTrig) + t_trig;
		gate = EnvGen.ar(Env.sine(0.1),trig);
		rand = TExpRand.kr(0.05,0.3,t_trig);
		sig = CombC.ar(sig*gate,0.6,rand,Select.kr(Trig1.kr(trig,rand-0.01),[inf,0]));
		sig1 = DelayN.ar(sig,0.6,rand*7/5);
		sig = Pan2.ar(sig,LFNoise2.kr(0.2)) + Pan2.ar(sig1,LFNoise2.kr(0.2));
		sig*amp;
	},

	"percShiftDelay" -> { //freqDev=0.6,maxDev=0.3;freqDev=1,maxDev=1;freqDev=2,maxDev=3;
		arg inBus,freqDev,maxDev,t_trig,amp=1.0;
		var grainSize=0.5,mute,freq,hasFreq,sig;

		sig = In.ar(inBus,1);
		mute = ToggleFF.kr(t_trig);
		sig = sig*(1-mute) + LocalIn.ar(1);
		#freq, hasFreq = Pitch.kr(sig, ampThreshold: 0.05, median: 7);
		sig = sig*(1-hasFreq);
		sig = PitchShift.ar(sig,grainSize,freqDev.clip(0.5,4.0),maxDev.clip(0.0,3.0),grainSize/10);
		sig = LeakDC.ar(sig);
		LocalOut.ar(sig*(Select.kr(mute,[0.75,1])));
		sig = Pan2.ar(sig,TRand.kr(-1.0,1.0,1-hasFreq).lag(maxDev),amp);
	},

	"shiftDelay" -> {//speed,0.1,delay,0.3;speed,1,delay,0.8;speed,4,delay,1.5;
		arg inBus,speed,delay,amp=1,t_trig;
		var local,mute,sig;

		sig = In.ar(inBus,1);
		mute = ToggleFF.kr(t_trig);
		local = LocalIn.ar(2);
		sig = DelayC.ar((sig*(1-mute))+local,1.5,LFNoise1.ar((speed.clip(0.05,7))!2).range(0.2,delay.clip(0.3,1.5)));
		LocalOut.ar((sig.reverse)*Select.kr(mute,[0.75,1]));
		sig = LeakDC.ar(sig);
		sig = Splay.ar(sig,1,amp);
	},

	"bitz" -> {
		arg inBus=0,rate=1.0,bits=1.0,pan=0,amp=0.8;
		var sig;

		sig = In.ar(inBus,1);
		sig = Decimator.ar(sig,SampleRate.ir * rate.clip(0.0,1.0), 24 * bits.clip(0.0,1.0));
		sig = Pan2.ar(sig,pan,amp);
	},

	"morph" -> {
		arg inBus,gain=1,amp=0.5;
		var sig,freq,voices;

		voices = 10;
		freq = {500.exprand(1500.0)}!voices;

		sig = In.ar(inBus,1);

		sig = sig * LFNoise2.kr(0.5).range(0.8,1.2);

		sig = RLPF.ar(sig,freq*LFNoise2.kr({0.5.exprand(10.0)}!voices).range(0.5,2.0),0.08);
		sig = AllpassC.ar(sig,0.02,0.02,0.1);
		sig = (sig * gain).clip(-1.0,1.0);
		sig = Splay.ar(sig,1);
		sig = FreeVerb2.ar(sig[0],sig[1],0.3,100,0.4);
		sig = sig * amp * SinOsc.kr(LFNoise2.kr(1!2).range(2.0,8.0)).abs;
	},

	"grains" -> {
		arg bufnum = 0, posRate = 1, posDev = 0.01, trigRate = 100, grainDur = 0.1, rate = 1.0, amp = 0.1;
		var trig, pos, posLo, posHi, pan,bufDur, bufDurSection, posDif,sig;

		posLo = 0.0;
		posHi = 1.0;
		trig = Impulse.kr(trigRate);

		bufDur = BufDur.kr(bufnum);
		posDif = posHi - posLo;
		bufDurSection = bufDur * posDif;

		pos = posLo * bufDur +
		(Phasor.ar(0, BufRateScale.kr(bufnum) * posRate / SampleRate.ir,
			posLo * bufDur,
			posHi * bufDur)
		+
		(TRand.kr(-0.5 * posDev, 0.5 * posDev, trig) * bufDur)).mod(bufDurSection);

		pan = (TRand.kr(-1.0, 1.0, trig));
		sig = TGrains.ar(2,trig,bufnum,rate,pos,grainDur,pan,amp);

		Limiter.ar(sig);
	},

	"noizer" -> {
		arg freq=8,counter=0,bits=12,sampleRate=12,gate=1,amp=0.35,outBus=0;
		var sr = SampleRate.ir/sampleRate;
		var n = bits.clip(12,24); //bit resolution
		var t= Phasor.ar(1,freq*((2**n)/sr),0,((2**n)-1));
		var env = EnvGen.kr(Env.asr(releaseTime: 0.01),gate,doneAction:2);

		t = Select.ar(counter,[

			t*(((t>>64)|(t>>8))&(63&(t>>4))),
			t*(((t>>9)|(t>>13))&(25&(t>>6))),
			t*(((t>>5)|(t>>8)) & 63),
			t*(((t>>11)&(t>>8))&(123&(t>>3))),
			t*(t>>8*((t>>15)|(t>>8))&(20|(t>>19)*5>>t|(t>>3))),
			t*(t>>((t>>9)|(t>>8))&(63&(t>>4))),
			(t>>7|t|t>>6)*10+4*(t&t>>13|t>>6)
		]);

		t = t % (2**(n));// avoiding number beyond 2**(bit resolution)
		t = t*(0.5**(n-1)) - 1; //scaling to -1, 1
		t = Pan2.ar(t,Latch.kr(LFNoise2.kr(0.4).range(-0.8,0.8),Changed.kr(A2K.kr(t))),amp);
		t = LeakDC.ar(t);
		t = t*env;
	},

]
);
"synths loaded".postln;
)