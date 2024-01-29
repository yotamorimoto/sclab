// multichannel reverb
// n = number of output
n = 30;
s.options.numOutputBusChannels = n;
s.reboot;
(
SynthDef(\verb ++ n, { |decay=3, feedback=0.9|
	var sig, fbk;
	sig = In.ar(0, n);
	sig = OnePole.ar(sig, 0.72);
	sig = AllpassC.ar(sig, 0.3, LFNoise1.kr(1).range(0.3,0.29), 3);
	fbk = LocalIn.ar(n);
	(n > 1).if({ fbk = fbk.scramble });
	fbk = OnePole.ar(fbk, 0.2);
	fbk = fbk + sig;
	7.do { fbk = AllpassN.ar(fbk, 0.05, {0.050.rand}!n, decay) };
	LocalOut.ar(fbk * feedback);
	Out.ar(\out.ir, fbk);
}).add;
)
// test
(
// force n-channel into stereo for monitoring
Synth.tail(s, \verb ++ n, [feedback: 0.8]);
r {
	loop {
		{
			PanAz.ar(n,
				SinOsc.ar(200.exprand(2000), 0, 0.5) * Env.perc.kr(2),
				1.0.rand2
			)
		}.play;
		0.1.exprand(3).wait;
	}
}.play;
{ ReplaceOut.ar(0, Splay.ar(In.ar(0, n))) }.play(s,addAction:'addToTail');
)