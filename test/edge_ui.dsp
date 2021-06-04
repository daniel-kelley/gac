import("stdfaust.lib");

gac = library("gac.lib");

freq = hslider("freq",1,0.1,10,0.1);
slope = hslider("slope",0.5,0,1,0.05);

test(clk) =
   gac.edge(clk,slope),
   clk;

// inputs:
//   none
// outputs:
//   clk:edge
//   clk

process = gac.clock(freq) : test;
