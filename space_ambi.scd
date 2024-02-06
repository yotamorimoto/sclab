// ambiX format experimentation
// ACN channel ordering with SN3D normalisation
// w,y,z,x
b = Buffer.read(s, "/Users/yota/Music/_smp/eau/strand4.2019.sg.wav");
{ Splay.ar(PlayBuf.ar(2,b,1,1,BufFrames.ir(b)*0.4)) }.play;
// w+z,y+x
{ var x = PlayBuf.ar(4,b); [x[0]+x[2], x[1]+x[3]] }.play;
// { var x = PlayBuf.ar(4,b); [x[0]+x[1], x[2]+x[3]] }.play;
// { var x = PlayBuf.ar(4,b); [x[0]+x[3], x[2]+x[1]] }.play;

// w+z,y+x
b = Buffer.read(s, "/Users/yota/Music/am_cpb/auvergne/h3vr/211020_001.WAV");
b = Buffer.read(s, "/Users/yota/Music/am_cpb/auvergne/h3vr/211020_002.WAV");
{ var x = PlayBuf.ar(4,b,1,1,BufFrames.ir(b)*0.1); [x[0]+x[2], x[1]+x[3]] }.play;
// { var x = PlayBuf.ar(4,b,1,1,BufFrames.ir(b)*0.1); [x[0]+x[1], x[2]+x[3]] }.play;
// { var x = PlayBuf.ar(4,b,1,1,BufFrames.ir(b)*0.1); [x[0]+x[3], x[2]+x[1]] }.play;
b.free;

// render?
(thisProcess.nowExecutingPath.dirname+/+"nrt_buf.scd").openOS;