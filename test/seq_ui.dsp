import("stdfaust.lib");

gac = library("gac.lib");

// controls

// sequencer controls and programming
freq_c = hslider("clock",1,0.1,200,0.1);
len = hslider("len",4,1,gac.N,1);
widx = hslider("idx",0,0,gac.N-1,1);
fval = hslider("fval",20,20,2000,1);
sval = hslider("sval",0,0,1,0.01);
pgmf = button("pgmf");
pgms = button("pgms");

// signal
attack = hslider("attack",0.05,0,1,0.05);
release = hslider("release",0.05,0,1,0.05);

// final output
vol = hslider("volume [unit:dB]", -96, -96, 6, 0.1) : ba.db2linear : si.smoo;

// data

// fixed
freq_s_data = waveform{
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,
440.0,440.0,440.0,440.0,440.0,523.3,587.3,659.3,

0 // dummy for write
};

// "half sine wave" for size-1 entries.
shape_s_func(size) = float(ba.time)*2.0*(2.0*ma.PI)/float(size-1) : sin;


//
// blocks
//

// *** sequencer
clk = gac.clock(freq_c);
ridx = gac.index(clk,len);
freq_s = (freq_s_data, widx, fval, pgmf, ridx) : gac.lookup;
shape_s = (gac.N+1, shape_s_func(gac.N+1), widx, sval, pgms, ridx) : gac.lookup;

// *** signal
osc = gac.osc(freq_s, shape_s);
gate = gac.ar(attack,release,gac.osh(attack,clk));

process = osc * gate * vol;
