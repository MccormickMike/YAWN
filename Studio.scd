

// 0 - snare
// 1 - rack tom
// 2 - floor tom L
// 3 - floor tom R
// 4 - OH L
// 5 - OH R


(
Ndef(\freezeStudio,{
	var sig = SoundIn.ar([0,1]);
	var trig = KeyState.kr(38,0,0.1,0.1);
	var buf = 4096/8;
	var pan = TRand.kr(-1.0,1.0,trig);

	sig = FFT(LocalBuf(buf), sig.sum);
	sig = PV_Freeze(sig,trig);
	sig = IFFT(sig);

	sig = Pan2.ar(sig*trig,pan);

}).play
)


64 * [2,4,8,16,32,64,128]
Ndef(\freezeStudio).clear

Ndef(\freezeStudio).set(\trig,1)


(
Ndef(\stutterStudio,{
	var sig = SoundIn.ar([0,1]);
	var trig = KeyState.kr(38,0,1,0.001);
	var gate = Env.sine(0.1).kr(gate:trig);
	var rand = TChoose.kr(trig,[0.05,0.075,0.1,0.15]); //0.15,0.1,
	// var env = Env.perc(1.5,0.01,1,2).kr(gate:trig);
	// rand = Env([0.005,rand],[1.5],\exp).kr(gate:trig);
	rand = SelectX.kr(LFNoise2.kr(rand.reciprocal/10).range(0,5).floor,[rand*2,rand,rand/2,rand/4]);

	sig = CombC.ar(sig*gate,1.2,rand,Select.kr(trig,[0,inf]));
	// sig = sig * env;

}).play
)

60/300

0.3/6

Ndef(\stutterStudio).clear

200.reciprocal

