import("stdfaust.lib");

gac = library("gac.lib");

freq = hslider("freq",1,0.1,10,0.1);
dur = hslider("dur",0.5,0,1,0.05);

test(clk) =
   gac.osh(dur,clk),
   clk;

// inputs:
//   none
// outputs:
//   clk:osh
//   clk

process = gac.clock(freq) : test;
