(
// setup
~freq = 400;
~just = [9/8, 5/4, 4/3, 3/2, 5/3, 15/8, 2];
s.waitForBoot {
	w = Window.new;
	w.bounds_(Rect(256,256,256,256));
	b = Buffer.alloc(s, 2048, 2);
	s.sync;
	k = ScopeView.new(w, 256@256);
	w.front;
	k.bufnum = b.bufnum;
	k.server = s;
	k.start;
	k.style = 2;
	k.background = Color.new255(122, 150, 233);
	k.waveColors = [Color.white];
	s.sync;
	{ ScopeOut2.ar(In.ar(0,2), b.bufnum, 2048, 2048) }.play;
	s.sync;
	{
		var ratios;
		ratios = Demand.kr(Impulse.kr(3), 0, Drand(~just, inf));
		SinOsc.ar(~freq * [ratios, 1], 0, 0.5)
	}.play;
	// cleanup
	CmdPeriod.doOnce { k.stop; w.close; b.free };
};
)