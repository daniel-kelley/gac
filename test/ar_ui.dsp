import("stdfaust.lib");

gac = library("gac.lib");

freq = hslider("freq",1,0.1,10,0.1);
dur = hslider("dur",0.05,0,1,0.05);
attack = hslider("attack",0.05,0,1,0.05);
release = hslider("release",0.05,0,1,0.05);

test(clk) = gac.ar(attack,release,clk);
// inputs:
//   none
// outputs:
//   ar

process = gac.clock(freq) : test;
