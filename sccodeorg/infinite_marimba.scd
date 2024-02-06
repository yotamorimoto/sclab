// https://sccode.org/1-4SB#c1072
// by eli.fieldsteel
(
s = Server.local.waitForBoot({
	~bus = Bus.audio(s,2);
	SynthDef(\reverb_ef, {
		arg		amp=1, lPos=0, mix=0.085, revTime=1.8, preDel=0.1, in, out;
		var		sig, verbSig, totalSig, outSig;

		//no wacky values please
		mix = mix.clip(0,1);

		sig = In.ar(in, 2);

		//pre-delay
		verbSig = DelayN.ar(sig, preDel, preDel);

		totalSig = 0;
		12.do{
			verbSig = AllpassN.ar(verbSig, 0.06, {Rand(0.001,0.06)}!2, revTime);
			verbSig = LPF.ar(verbSig, 4500);
			totalSig = totalSig + verbSig;
		};

		//dry/wet mix
		totalSig = XFade2.ar(sig, totalSig, mix.linlin(0,1,-1,1));

		outSig = totalSig * amp;
		Out.ar(out, outSig);
	}).add;

	SynthDef(\filtSaw, {
		arg		freq=440, detune=3.0, atk=6, sus=4, rel=6, curve1=1, curve2=(-1),
				minCf=30, maxCf=6000, minRq=0.005, maxRq=0.04,
				minBpfHz=0.02, maxBpfHz=0.25,
				lowShelf=220, rs=0.85, db=6,
				gate=1, amp=1, spread=1.0, out=0;
		var sig, env;
		env = EnvGen.kr(Env([0,1,1,0],[atk,sus,rel],[curve1,0,curve2]), gate, levelScale:amp, doneAction:2);
		sig = Saw.ar(
			freq +
			LFNoise1.kr({LFNoise1.kr(0.5).range(0.15,0.4)}!8).range(detune.neg,detune));
		sig = BPF.ar(
			sig,
			LFNoise1.kr({LFNoise1.kr(0.13).exprange(minBpfHz,maxBpfHz)}!8).exprange(minCf, maxCf),
			LFNoise1.kr({LFNoise1.kr(0.08).exprange(0.08,0.35)}!8).range(minRq, maxRq)
		);
		sig = BLowShelf.ar(sig, lowShelf, rs, db);
		sig = SplayAz.ar(4, sig, spread);
		sig = sig * env * 2;
		Out.ar(out, sig);
	}).add;

	~cluster = {
		var trnsp, bund;
		bund = s.makeBundle(false, {});
		trnsp = rrand(-7,7);
		Array.fill(exprand(4,14).round.postln, {[1,2,3,4,6,8,12,16].wchoose([7,6,5,4,3,3,1].normalizeSum)}).do{
			|i|
			var cfLo;
			cfLo = (([23,35,47,50,52,59,61,63,64,76,78].choose) + trnsp).midicps * ((1..8).choose);

				bund = s.makeBundle(false, {
					Synth(
						\filtSaw,
						[
							\freq, i,
							\detune, 0,
							\minBpfHz, 0.01,
							\maxBpfHz,i.expexp(1.0,16.0,0.1,16.0),
							\minRq, 0.003,
							\maxRq, exprand(0.008,0.08),
							\minCf, cfLo,
							\maxCf, cfLo * [1,1.1,1.5].wchoose([0.87,0.1,0.03]),
							\amp, exprand(0.15,0.25),
							\atk, exprand(0.7,8),
							\rel, 5,
							\sus, rrand(6,10.0),
							\spread, exprand(1.5,8.0),
							\out, ~bus,
						],
					)
				},
				bund
			)
		};

		//schedule on an integer time value
		SystemClock.schedAbs(
			(thisThread.seconds+1.0).round(1.0),
			{
				bund = s.makeBundle(nil, {}, bund);
				nil;
			}
		);
	};
});
)

//start clusters
(
t = Task {
	//instantiate reverb synth
	Synth(\reverb_ef, [\in, ~bus, \out, 0]);

	{
		~cluster.value;
		rrand(5.5,12.0).wait;
	}.loop;
}.start;
)

//stop clusters
t.stop;