


(
// var array = Array.geom(8,60,1.2) / 60;
var array = [50,60,80,90,120,150] / 60;

SynthDef(\click,{

	var env = EnvGen.kr(Env.perc(\atk.kr(0.01),\rls.kr(0.25),1.0,\curve.kr(-4)),1,doneAction: 2);
	var sig = LFTri.ar(\freq.kr(1000));
	sig = LPF.ar(sig,8000);
	sig = Pan2.ar(sig,\pan.kr(0),\amp.kr(0.5));
	Out.ar(\outBus.kr(0),sig*env);

}).add;

Pdef(\newIdea,
	Pbind(
		\instrument, \click,
		\dur,0.5,
		\dummy,Pseq([1,1.25,Pstutter(Pseq([6],1),0)],inf),
		\freq,1000 * (Pkey(\dummy) + 1),
		\amp,0.5,
		\tempo,Pclutch(Pxrand(array,inf),Pkey(\dummy,inf)),
)
)
);

Pdef(\newIdea).play
Pdef(\newIdea).stop
