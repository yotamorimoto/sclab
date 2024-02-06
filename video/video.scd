(
~bounds = 640@360; ~block = 512; a = 256;
w = Window(nil, ~bounds);
v = WebView(w, ~bounds);
k = ScopeView(w, ~bounds);
v.url = thisProcess.nowExecutingPath.dirname +/+ "index.html";
s.waitForBoot {
	b = Buffer.alloc(s, ~block, 2);
	s.sync;
	SynthDef(\scope, {
		var sig = In.ar(0,2).round(0.01)*3;
		ScopeOut2.ar(sig, b.bufnum, ~block, ~block);
	}).add;
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
	SynthDef(\fm, { |freq=440, amp=0.3, mod=1000|
		var sig, env, shape;
		shape = ExpRand(0.01, 0.3);
		freq = freq+(SinOsc.ar(freq*5,0,mod,1)*Env.perc(shape,0.31-shape).kr);
		sig = SinOsc.ar(freq);
		env = Env.perc.kr(2) * amp;
		sig = sig * env;
		sig = PanAz.ar(5, sig, Rand(-0.5, 0.5));
		Out.ar(0, Splay.ar(sig));
		Out.ar(~fxbus, sig);
	}).add;
	s.sync;
	k.bufnum = b.bufnum;
	k.server = s;
	k.start;
	k.style = 2;
	k.background = Color.grey(0,0);
	k.waveColors = [Color.white];
	k.xZoom = 1.5;
	k.yZoom = 1.5;
	s.sync;
	Synth.tail(s, \verb52, [bus:~fxbus, feedback:0.8]);
	Synth.tail(s, \scope);
	s.sync;
	x = Scale.phrygian;
	a = Ppoisson(5, inf).asStream;
	{
		1.wait;
		loop {
			var n = a.next.postln;
			var time = 3;
			var wait = Array.exprand(n,0.01,3).normalizeSum*time;
			if(n == 0, { time.wait });
			n.do { |i|
				Synth(\fm, [
					\freq, x.degreeToFreq(30.rand, 200, 0),
					\mod, 10.exprand(1000),
				]);
				wait[i].wait;
			};
		}
	}.fork;
};
CmdPeriod.doOnce { w.close };
w.onClose = { k.stop; b.free };
w.front;
)