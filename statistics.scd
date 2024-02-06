(
SynthDef(\sine, { |freq=440,amp=0.3,pan=0|
	var sig, env;
	sig = FSinOsc.ar(freq, 2pi.rand);
	env = LFGauss.ar(0.01, 0.1, 0, 0, 2);
	sig = sig * env * amp;
	sig = Pan2.ar(sig, pan);
	OffsetOut.ar(0, sig)
}).add;
)
a = Pwhite.new.asStream;
a = Plprand.new.asStream;
a = Phprand.new.asStream;
a = Pmeanrand.new.asStream;
a = Pexprand.new.asStream;
a = Pbeta(0.0, 1.0, 0.1, 0.1, inf).asStream;
a = Pbeta(0.0, 1.0, 1.0, 1.0, inf).asStream;
a = Pbeta(0.0, 1.0, 3.0, 3.0, inf).asStream;
a = Pgauss(0.5, 0.5, inf).asStream;
a = Pcauchy(0.5, 0.5, inf).asStream;
(
{
	loop {
		s.makeBundle(0.2, {
			Synth(\sine, [\freq, a.next.linexp(0,1,200,1200)]);
		});
		0.01.wait;
	}
}.fork;
)