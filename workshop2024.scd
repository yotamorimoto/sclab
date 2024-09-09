(
~f = 48000 / 1024;
s.options.numWireBufs = 1024;
s.waitForBoot {
	var win, buf, sf;
	win = Window.new.bounds_(Rect(10,256,512,512));
	buf = Buffer.alloc(s, 512, 2);
	sf = { ScopeOut2.ar(In.ar(0,2), buf.bufnum, 2048, 2048) };
	s.sync;
	~scope = ScopeView.new(win, 512@512);
	~scope.bufnum = buf.bufnum;
	~scope.server = s;
	~scope.start;
	~scope.style = 2;
	~scope.background = Color.white;
	~scope.waveColors = [Color.black];
	s.sync;
	win.front;
	win.alwaysOnTop = true;
	sf.play(addAction:\addToTail);
	CmdPeriod.add { sf.play(addAction:\addToTail) };
	s.sync;
	a = Signal.sineFill(16384,[1]);
	b = Buffer.alloc(s,16384);
	b = b.loadCollection(a);
};
)
Ndef(\x).play(addAction:\addToHead);
Ndef(\x).fadeTime = 5;
(
Ndef(\x, { |cfreq=46.875, freq = 0.1|
	var sig;
	sig = Phasor.ar(0, BufFrames.ir(b) * (cfreq/SampleRate.ir), 0.0, BufFrames.ir(b));
	sig = sig.lincurve(0.0, BufFrames.ir(b), 0.0, BufFrames.ir(b), LFSaw.ar(freq * [1, 2]) * 100);
	sig = BufRd.ar(1, b, sig) * 0.6;
	LeakDC.ar(sig);
});
)
(
Ndef(\x, { |linkFreq=1.5, freq=15|
	var sig;
	sig = Phasor.ar(0, 8192 * (linkFreq / SampleRate.ir), 0.0, 8192 * [1, 2]);
	sig = sig.lincurve(0.0, 8182, 0.0, 8192, LFTri.ar(freq * [1, 2]).unipolar(1) * 500);
	sig = LeakDC.ar(sig);
	sig = SinOsc.ar(linkFreq + sig) * 0.5;
});
)
(
Ndef(\x, {
	var sig=LatoocarfianN.ar(
		SampleRate.ir/10,
		LFNoise2.kr(2,1.5,1.5),
		LFNoise2.kr(2,1.5,1.5),
		LFNoise2.kr(2,0.5,1.5),
		LFNoise2.kr(2,0.5,1.5)
	)*0.3;
	[Delay1.ar(sig), sig];
});
)
(
Ndef(\x, {
	var sig=FBSineN.ar(
		SampleRate.ir/10,
		LFNoise2.kr(1, 32, 33),
		LFNoise2.kr(1, 0.5),
		LFNoise2.kr(1, 0.05, 1.05),
		LFNoise2.kr(1, 0.3, 0.3)
	)*0.5;
	[Delay1.ar(sig),sig]
});
)
(
Ndef(\x, {
	var a = SinOsc.ar(400,0,0.5);
	var b = SinOsc.ar(400,0,0.5);
	Rotate2.ar(a,b,SinOsc.kr(0.1));
});
)
(
Ndef(\x, {
	var a = SinOsc.ar(401,0,0.5);
	var b = SinOsc.ar(400,0,0.5);
	Rotate2.ar(a,b,SinOsc.kr(0.1));
});
)
(
Ndef(\x, {
	var a = SinOsc.ar(400,0.5pi,0.5);
	var b = SinOsc.ar(400,0,0.5);
	Rotate2.ar(a,b,SinOsc.kr(1));
});
)
(
Ndef(\x, {
	var a = SinOsc.ar(410,0,0.5);
	var b = SinOsc.ar(400,0,0.5);
	#w,x,y = PanB2.ar(a, -0.5) + PanB2.ar(b, 0.5);
	#x,y = Rotate2.ar(x, y, SinOsc.kr(0.1));
	[x+w,y+w]
});
)
(
Ndef(\x, {
	var f = 48*20;
	var n = 50;
	var trig = CoinGate.kr(0.9,Impulse.kr(20));
	var sig = SinOsc.ar([f],[0,3pi/2]);
	var scale = 0.2;
	var lmin = 0.5;
	var lmax = TRand.kr(lmin,4,trig);
	var l = Array.fill(n,{TRand.kr(lmin,lmax,trig)});
	var d = Array.rand(n,1,100).normalizeSum;
	var shp= 4;
	sig = sig* BrownNoise.ar.range(0.2,0.4);
	sig = sig* DemandEnvGen.ar(Dseq(l,inf),Dseq(d*f.reciprocal,inf),shp )*scale;
	sig = sig * Decay2.kr(Trig.kr(trig,0.1),0.001,0.2,0.05) ;
	sig = sig.collect{|s| s + TRand.kr(-0.7,0.7,trig)};
	SendTrig.kr(trig);
	sig
});
)
(
Ndef(\x, {
	var f = 48*20;
	var n = 50;
	var trig = CoinGate.kr(0.9,Impulse.kr(20));
	var sig = SinOsc.ar([f],[0,3pi/2]);
	var scale = 0.2;
	var lmin = 0.5;
	var lmax = TRand.kr(lmin,4,trig);
	var l = Array.fill(n,{TRand.kr(lmin,lmax,trig)});
	var d = Array.rand(n,1,100).normalizeSum;
	var shp= 4;
	sig = sig*DemandEnvGen.ar(Dseq(l,inf),Dseq(d*f.reciprocal,inf),shp )*scale;
	sig = sig * Decay2.kr(Trig.kr(trig,0.1),0.001,0.2,0.05);
	sig = sig.collect{|s| s + TRand.kr(-0.7,0.7,trig)};
	SendTrig.kr(trig);
	sig.round(Demand.kr(trig,0, Drand([0,0.4,0.05,0.1],inf)));
});
)
(
Ndef(\x,{
	var a = SinOsc.ar(41,0,0.5);
	var b = SinOsc.ar(40,0,0.5);
	var sig = Rotate2.ar(a,b,SinOsc.kr(0.1));
	sig.round(Demand.kr(Impulse.kr(3),0,Dwhite(0,0.1,inf)))
});
)
(
Ndef(\x,{
	|f0 = 100, harm = 10, fmFreq=50.1, fmAmt = 3, fMod=100.1|
	var n, f, p, a, sig;
	n = 64;
	f = Array.fill(n, { |i| (i+1) * f0 });
	f = f.collect({ |item, i| item.trunc(0.1.rand * SinOsc.kr(3.0.rand).unipolar(1)) });
	p = 0;
	a = Array.fill(n, { 0.1.rand * SinOsc.ar(1.5.rand).unipolar(1) });
	a = a.collect({ |item| item * Blip.ar(fmFreq, harm, mul: fmAmt).unipolar(1) });
	sig = SinOsc.ar(f, p, a);
	sig = sig * ((1 - log2(f * Lag.kr(SinOsc.kr(0.01).range(0.0, 0.01), 0.1)).sin.abs) ** SinOsc.ar(fMod).unipolar(5));
	sig = sig[0,2..].sum + ([-1, 1] * sig[1,3..].sum) * 5.dbamp;
	sig = sig.fold2;
	Rotate2.ar(sig[0], sig[1], LFSaw.ar(0.3));
});
)
Ndef(\x).end(3);