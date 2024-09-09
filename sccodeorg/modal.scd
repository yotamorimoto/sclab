// 1. define the synth
(
SynthDef(\bell, {
	|fs=1, t60=1, pitchy=1, amp=0.25, gate=1|
	var sig, exciter;
	// exciter = Impulse.ar(0,0,0.1);
	exciter = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.05), gate) * 0.05;
	// exciter = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.05), gate) * 0.05;
	sig = Klank.ar(
		`[
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // freqs
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]*t60     // ring times
		],
		exciter,
		freqscale:fs*pitchy);
	DetectSilence.ar(sig, 0.001, 0.5, doneAction:2);
	Out.ar(0, sig!2);
}).add
)


// 2. Test a single note
x = Synth(\bell, [\fs, 60.midicps, \t60, 9.177, \pitchy, 8]);


// 3. Test different textures

// glokenspiel
(
Pbind(
	\instrument, \bell,
	\fs, Pseq( (60..72), 1).midicps,
	\t60, 6,
	\pitchy, 4,
	\dur, 0.25
).play;
)

// tubular bells
(
Pbind(
	\instrument, \bell,
	\fs, Pseq( (60..72), 1).midicps,
	\t60, 9,
	\pitchy, 1,
	\dur, 1
).play;
)

// xilophone
(
Pbind(
	\instrument, \bell,
	\fs, Pseq( (60..72), 1).midicps,
	\t60, 1,
	\pitchy, 4,
	\dur, 0.25
).play;
)

// marimba
(
Pbind(
	\instrument, \bell,
	\fs, Pseq( (60..72), 1).midicps,
	\t60, 0.5,
	\pitchy, 1,
	\dur, 0.25
).play;
)

// rnd
(
Pbind(
	\instrument, \bell,
	\fs, Pseq([40, 41, 43, 45, 47, 48, 50], inf).midicps,
	\t60, Pseq([0.5, 1, 6, 9], inf),
	\pitchy, Pseq([1, 4, 6], inf),
	\dur, 0.25
).play;
)