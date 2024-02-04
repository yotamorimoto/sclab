s.options.sampleRate = 48000;
s.reboot;
b = Buffer.read(s, "/Users/yota/Music/am_cpb/maison/nuit excerpt.wav");

// read
r = { PlayBuf.ar(2, b, loop: 1) }.play;

// write
(
w = {
	var trig, rate, pos, sig, rec;
	var scale = BufRateScale.ir(b);
	trig = Dust.ar(3);
	rate = TChoose.ar(trig, DC.ar([-2, 2, -3, -0.75, 0.89, 0.793, -0.749]));
	pos = TIRand.ar(0, BufFrames.ir(b), trig);
	sig = InFeedback.ar(0,2);
	rec = Phasor.ar(trig, rate*scale, 0, BufFrames.ir(b), pos);
	BufWr.ar(sig, b, rec);
	DC.ar(0);
}.play;
)
// wait...

// for

// changes

// then

// write
b.write("/Users/yota/Desktop/test.wav", "wav");


// free
w.free;b.free;