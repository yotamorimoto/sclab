/* a light-weight physical model piano from:

https://github.com/catfact/zebra/blob/master/lib/Engine_DreadMoon.sc#L20-L41

super nice!
*/
(
SynthDef.new(\comb_piano, {
	arg out=0, amp=0.125, hz=220,
	noise_hz = 4000, noise_attack=0.002, noise_decay=0.06,
	tune_up = 1.0005, tune_down = 0.9996, string_decay=6.0,
	lpf_ratio=2.0, lpf_rq = 4.0, hpf_hz = 40, damp=0, damp_time=0.1;

	var noise, string, delaytime, lpf, noise_env, snd, damp_mul;

	damp_mul = LagUD.ar(K2A.ar(1.0 - damp), 0, damp_time);
	noise_env = Decay2.ar(Impulse.ar(0));
	noise = LFNoise2.ar(noise_hz) * noise_env;
	delaytime = 1.0 / (hz * [tune_up, tune_down]);
	string = Mix.new(CombL.ar(noise, delaytime, delaytime, string_decay * damp_mul));
	snd = RLPF.ar(string, lpf_ratio * hz, lpf_rq) * amp;
	snd = HPF.ar(snd, hpf_hz);
	Out.ar(out, snd.dup);
	DetectSilence.ar(snd, doneAction:2);
}).add;
)
(
Synth(\comb_piano, [amp:0.01.rrand(0.1), hz:30.rrand(80).midicps]);
Synth(\comb_piano, [amp:0.01.rrand(0.1), hz:30.rrand(80).midicps]);
)