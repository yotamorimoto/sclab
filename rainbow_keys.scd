(
var nodes = Array.newClear(128);
var key_width = 20;
var key_height = 40;
var key_range = (21..108);
var key_offset = key_range[0];
var numkeys = key_range.size;
var bw = [1,0,1,1,0,1,0,1,1,0,1,0];
var space = [0,0.5,1,2,2.5,3,3.5,4,5,5.5,6,6.5];
var color = [Color.black, Color.white];
var font = Font.monospace(9);
var win, keys;
MIDIIn.connectAll;
win = Window("keys", 1056@(2*key_height+5)).front;
keys = key_range.collect { |i|
	var x = i - 21;
	var ki = bw[x%12];
	Button(win, Rect(
		(space[x%12]+(floor(x/12)*7))*key_width+5, [0,key_height][ki],
		key_width, key_height))
	.font_(font)
	.states_([
		[i, color[1-ki], color[ki]],
		[i, color[1-ki], Color.hsv(x/numkeys,1,1)],
	])
	.action_({ |b|
		if(b.value == 1, {
			i.midicps.postln;
			{Saw.ar(i.midicps, 0.3)*Env.perc.kr(2)}.play;
			r{0.3.wait;b.value=0;}.play(AppClock)
		});
	});
};
MIDIdef.noteOn(\keyOn, {|v,n|
	{keys[n - key_offset].value=1}.defer;
	nodes[n] = Synth(\simple, [freq:n.midicps, amp:v.linlin(10,120,-40,-3).dbamp]);
});
MIDIdef.noteOff(\keyOff, {|v,n|
	{keys[n - key_offset].value=0}.defer;
	nodes[n].release;
});
s.waitForBoot {
	SynthDef(\simple, { |gate=1, freq, amp|
		var sig, env;
		sig = Saw.ar(freq,1.3);
		env = Env.adsr.kr(2, gate);
		sig = RLPF.ar(sig, env.exprange(400, 3500));
		sig = sig * env * amp;
		sig = Pan2.ar(sig);
		Out.ar(0, sig);
	}).add;
}
)