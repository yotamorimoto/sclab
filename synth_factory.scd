(
// factory parts
e = (
	saw:{ |freq, env, vel|
		var x = Saw.ar(freq + LFNoise0.kr(100, freq*0.01));
		LPF.ar(x, env.exprange(80, vel.linexp(10,100,800,2000)));
	},
	varsaw:{ |freq, env, vel|
		var x = VarSaw.ar(freq, 0, LFNoise1.kr(2).range(0.2, 0.8));
		OnePole.ar(x, env.exprange(0.001, vel.linexp(10,100,0.9,0)));
	},
	pulse:{ |freq, env, vel|
		var x = Pulse.ar(freq, LFNoise1.kr(2, 0.05, 0.1));
		LPF.ar(x, env.exprange(80, vel.linexp(10,100,800,2000)));
	},
	strike: { |freq, env, vel|
		var del = freq.reciprocal;
		var e = Decay2.ar(Impulse.ar(0), 0.008, 0.04);
		var x = LFNoise1.ar(3000, e);
		x = OnePole.ar(x, env.exprange(0.001, vel.linexp(10,100,0.9,0)));
		CombL.ar(x, del, del, 6);
	},
	oneshot: { |freq, env, vel|
		freq = freq * 2;
		PlayBuf.ar(1, ~oneshot,
			(freq.cpsmidi - 95).midiratio * BufRateScale.ir(~oneshot),
		) * 3.dbamp;
	},
	fm:{ |freq, env, vel|
		var x = SinOsc.ar(freq*1.5, 0, Env.perc(0.01, 0.3).kr.range(0,vel.linexp(10,100,400,1000)));
		SinOsc.ar(freq + x, 0, 0.6);
	},
	fsine:{ |freq| FSinOsc.ar(freq*2, 0, 0.7) },
);

a = Ppoisson(5, inf).asStream;
x = Scale.phrygian;

s.waitForBoot {
	~oneshot = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "pf_95.wav");
	s.sync;
	// production line
	e.keysValuesDo { |name, func|
		SynthDef(name, { |out=0, bus, note, vel, pan, a=0.01, r=2|
			var sig, env;
			var freq = note.midicps;
			env = Env.perc(a,r).kr(2);
			sig = SynthDef.wrap(func, prependArgs:[freq, env, vel]);
			sig = sig * env * vel.linlin(10,100,-30,-6).dbamp;
			sig = Pan2.ar(sig, pan);
			Out.ar(out, sig);
			Out.ar(bus, sig);
		}).add;
	};
	s.sync;
	~fxbus = Bus.audio(s,2);
	SynthDef(\verb2, { |bus, decay=3, feedback=0.6|
		var sig, del, fbk;
		sig = In.ar(bus,2);
		sig = OnePole.ar(sig, 0.92);
		sig = AllpassC.ar(sig, 0.1, LFNoise1.kr(1).range(0.1,0.09), 3);
		fbk = LocalIn.ar(2);
		fbk = fbk.scramble;
		fbk = OnePole.ar(fbk, 0.2);
		fbk = fbk + sig;
		7.do { fbk = AllpassN.ar(fbk, 0.05, {0.050.rand}!2, decay) };
		LocalOut.ar(fbk * feedback);
		Out.ar(0, fbk);
	}).add;
	s.sync;
	Synth.tail(s, \verb2, [bus:~fxbus, feedback:0.8]);
	s.sync;
	{
		1.wait;
		loop {
			var n = a.next;
			var time = 3;
			var wait = Array.exprand(n,0.01,3).normalizeSum*time;
			if(n == 0, { time.wait });
			n.do { |i|
				var vel = 50.rrand(85);
				Synth(e.keys.choose.postln, [
					note: 0.rrand(20).degreeToKey(x) + 48,
					vel: vel,
					bus: ~fxbus,
					pan: 0.5.rand2,
				]);
				wait[i].wait;
			};
		}
	}.fork;
};
)
