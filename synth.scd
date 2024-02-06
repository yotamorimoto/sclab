(
a = Ppoisson(6, inf).asStream;
x = Scale.phrygian;
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
	fm:{ |freq, env, vel|
		var x = SinOsc.ar(freq*1.5, 0, Env.perc(0.01, 0.3).kr.range(0,vel.linexp(10,100,400,1000)));
		SinOsc.ar(freq + x, 0, 0.3);
	},
	fsine:{ |freq| FSinOsc.ar(freq*2, 0, 0.5) },
);
s.waitForBoot {
	e.keysValuesDo { |name, func|
		SynthDef(name, { |note, vel, pan, a=0.01, r=2|
			var sig, env;
			var freq = note.midicps;
			env = Env.perc(a,r).kr(2);
			sig = SynthDef.wrap(func, prependArgs:[freq, env, vel]);
			sig = sig * env * vel.linlin(10,100,-30,-6).dbamp;
			sig = PanAz.ar(5, sig, pan);
			Out.ar(0, Splay.ar(sig));
			Out.ar(~fxbus, sig);
		}).add;
	};
	s.sync;
	~fxbus = Bus.audio(s,5);
	SynthDef(\verb52, { |bus, decay=3, feedback=0.6|
		var sig, del, fbk;
		sig = In.ar(bus,5);
		sig = OnePole.ar(sig, 0.92);
		sig = AllpassC.ar(sig, 0.1, LFNoise1.kr(1).range(0.1,0.09), 3);
		fbk = LocalIn.ar(5);
		fbk = fbk.scramble;
		fbk = OnePole.ar(fbk, 0.2);
		fbk = fbk + sig;
		7.do { fbk = AllpassN.ar(fbk, 0.05, {0.050.rand}!5, decay) };
		LocalOut.ar(fbk * feedback);
		sig = Splay.ar(fbk, 1);
		Out.ar(0, fbk);
	}).add;
	s.sync;
	Synth.tail(s, \verb52, [bus:~fxbus, feedback:0.8]);
	s.sync;
	{
		1.wait;
		loop {
			var n = a.next.postln;
			var time = 3;
			var wait = Array.exprand(n,0.01,3).normalizeSum*time;
			if(n == 0, { time.wait });
			n.do { |i|
				var vel = 40.rrand(80);
				Synth(e.keys.choose, [
					note: 0.rrand(20).degreeToKey(x) + 50,
					vel: vel,
					bus: ~fxbus,
					pan: 0.3.rand2,
				]);
				wait[i].wait;
			};
		}
	}.fork;
};
)
