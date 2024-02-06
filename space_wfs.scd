~numSpeakers = 2;
~driverDistance = 0.3; // macbook pro
~driverDistance = 0.12; // head
~maxDistance = 400;
~speedOfSound = 344;
~maxDelay = ~maxDistance / ~speedOfSound;
~speakerArray = Array.fill(~numSpeakers, { |i| Point((i*2-1) * ~driverDistance, 0) });
(
{
	var sig, pos;
	pos = Point(MouseX.kr(-20,20), MouseY.kr(-20,20));
	sig = PinkNoise.ar(0.5) + SinOsc.ar(400, 0, 0.5) * Decay2.ar(Dust.ar(50), 0.005, 0.05);
	sig = Array.fill(~numSpeakers, { |i|
		var distance = pos.dist(~speakerArray[i]);
		var cuttoff = 100000 / distance;
		var lowPassed = OnePole.ar(sig, exp(-2pi * (cuttoff * SampleDur.ir)));
		DelayC.ar(lowPassed, ~maxDelay, distance/~speedOfSound, 1/distance.max(1))
	});
}.play;
)