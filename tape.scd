s.options.sampleRate = 48000;
s.reboot;

// ---------------------------------------------------------------- test-sum
b = Buffer.read(s, "/Users/yota/Music/am_cpb/maison/nuit excerpt.wav");


// read
r = { PlayBuf.ar(2, b, loop: 1) }.play;

// write
(
w = { |buf|
	var trig, rate, pos, sig, rec;
	var scale = BufRateScale.ir(buf);
	trig = Dust.ar(3);
	rate = TChoose.ar(trig, DC.ar([-2, 2, -3, -0.75, 0.89, 0.793, -0.749]));
	pos = TIRand.ar(0, BufFrames.ir(buf), trig);
	sig = InFeedback.ar(0,2);
	rec = Phasor.ar(trig, rate*scale, 0, BufFrames.ir(buf), pos);
	BufWr.ar(sig, buf, rec);
	DC.ar(0);
}.play;
)

// write
b.write("/Users/yota/Desktop/test.wav", "wav");


// free
b.free;