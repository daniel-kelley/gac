import("stdfaust.lib");

gac = library("gac.lib");

freq = hslider("freq",100,20,4000,1) : si.smoo;
shape = hslider("shape",0.1,0.0,1,0.01) : si.smoo;
vol = hslider("volume [unit:dB]", -96, -96, 6, 0.1) : ba.db2linear : si.smoo;

process = gac.osc(freq,shape) * vol;
