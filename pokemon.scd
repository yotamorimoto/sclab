// ターミナルから起動
~sc = "/Applications/SuperCollider.app/Contents/Resources/";
~supernova = "supernova -u 30000 -B 0.0.0.0 -i 0 -o 4";
~scsynth = "scsynth -u 30000 -B 0.0.0.0 -i 0 -o 4";

// 通信トレース
OSCFunc.trace;

// Node.jsのダミー
s = NetAddr("localhost", 30000);

// 書出し先
// ~path = "~/Desktop/".standardizePath;
~path = "/tmp/";


// シンセ書出し
(
SynthDef(\test, { |out=0, fxout=8|
	var sig = SinOsc.ar*0.3*Env.perc.kr(2);
	OffsetOut.ar(out, sig);
	OffsetOut.ar(fxout, sig*0.5);
}).writeDefFile(~path);

SynthDef(\playbuf, { |buf, loop=0, out=0, fxout=8, amp=1, fxamp=0.5|
	var rate = BufRateScale.ir(buf);
	var sig = PlayBuf.ar(1, buf, rate, loop:loop, doneAction:2);
	sig = sig * amp;
	OffsetOut.ar(out, sig);
	OffsetOut.ar(fxout, sig*fxamp);
}).writeDefFile(~path);

SynthDef(\reverb, { |out=0, in=8, room=1, damp=0.5|
	Out.ar(out, FreeVerb.ar(In.ar(in), 1, room, damp));
}).writeDefFile(~path);

SynthDef(\master, { |out=0, in=0, gain=1, on=1, fadetime=1|
	var sig = In.ar(in);
	sig = sig * gain;
	sig = Limiter.ar(sig);
	sig = sig * Ramp.kr(on, fadetime);
	ReplaceOut.ar(out, sig);
}).writeDefFile(~path);
)

// シンセ読込
//  [/done, /d_load]
s.sendMsg("/d_load", "/tmp/*.scsyndef");

// テスト・トーン
// cmd, name, id, action (0:head 1:tail), target, args
s.sendMsg("/s_new", "test", -1, 1);

// テスト・トーン
// サンプル単位で揃える（要OffsetOut）
(
s.sendBundle(0.2,
	["/s_new", "test", -1,0,0, "out", 0],
	["/s_new", "test", -1,0,0, "out", 1]
);
)

// ----------------------------------- サウンド・ファイル
// シンセ生成
// (cmd, defname, id, action (0:head 1:tail), target, args)
s.sendMsg("/s_new", "reverb", 1010, 1, 0, "out", 0, "in", 8);
s.sendMsg("/s_new", "reverb", 1011, 1, 0, "out", 1, "in", 9);

s.sendMsg("/s_new", "master", 1012, 1, 0, "out", 0, "in", 0);
s.sendMsg("/s_new", "master", 1013, 1, 0, "out", 1, "in", 1);


// シンセシス・ノードのツリーを確認
// [/g_queryTree.reply, tree ...]
s.sendMsg("/g_queryTree", 0);

// パラメタ変更
s.sendMsg("/n_set", 1010, "room", 0.9, "damp", 0);
s.sendMsg("/n_set", 1011, "room", 0.9, "damp", 0);

// パラメタ変更
s.sendMsg("/n_set", 1012, "gain", 3.dbamp);
s.sendMsg("/n_set", 1013, "gain", 3.dbamp);

// ノード解放
s.sendMsg("/n_free", 1010);

// 全てのノードを解放
s.sendMsg("/g_freeAll", 0);

// サウンド・ファイル読込
// [/done, /b_allocReadChannel, id]
// cmd, id, path, 0, -1, chan0, chan1, chan2, ...
s.sendMsg("/b_allocReadChannel", 0, Platform.resourceDir +/+ "sounds/a11wlk01.wav", 0,-1, 0);

// サウンド・ファイル情報取得
// [/b_info, bufnum, numFrames, numChannels, sampleRate]
// cmd, id
s.sendMsg("/b_query", 0);

(
s.sendBundle(0.2,
	["/s_new", "playbuf", -1,0,0, "buf", 0, "out", 0, "fxout", 8],
	["/s_new", "playbuf", -1,0,0, "buf", 1, "out", 1, "fxout", 9]
);
)

// master on/off fadetime
(
s.sendMsg("/n_set", 1012, "on", 0, "fadetime", 2);
s.sendMsg("/n_set", 1013, "on", 0, "fadetime", 2);
)

// バッファ解放
// [/done, /b_free, id]
// cmd, id
s.sendMsg("/b_free", 0);

// サーバ・ステータス
// [/status.reply, 1, numUGens, numSynth, numGroups, numSynthDefs, avgCPU, peakCPU, nominalSampleRate, actualSampleRate]
s.sendMsg("/status");

// サーバ終了
// [/done, /quit]
s.sendMsg("/quit");