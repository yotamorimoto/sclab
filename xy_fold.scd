(
~block = 2048;
s.waitForBoot {
	s.bind {
		a = 512;
		w = Window.new(bounds:a@a);
		w.bounds_(Rect(0,0,a,a));
		b = Buffer.alloc(s, ~block, 2);
		s.sync;
		k = ScopeView.new(w, a@a);
		w.front;
		k.bufnum = b.bufnum;
		k.server = s;
		k.start;
		k.style = 2;
		k.background = Color.white;
		k.waveColors = [Color.black];
		s.sync;
		{ ScopeOut2.ar(In.ar(0,2), b.bufnum, ~block, ~block) }.play;
		s.sync;
		{
			var sig, trig, fold;
			trig = Impulse.kr(3);
			fold = TRand.kr(0, 0.3, trig);
			sig = LFTri.ar(40, [0,3], 0.5);
			sig = sig + LocalIn.ar(2).fold2(fold);
			LocalOut.ar(sig);
			sig
		}.play;
		w.onClose = { k.stop; b.free };
		CmdPeriod.doOnce { w.close }
	}
};
)