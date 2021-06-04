import("stdfaust.lib");
in = hslider("bp",0,0,1,0.001) * 4;

s = ba.listInterp((1.0,0.0,0.0,0.0,0.0),in): hbargraph("[style:numerical]s(bp)",0,1);
t = ba.listInterp((0.0,1.0,0.0,0.0,0.0),in): hbargraph("[style:numerical]t(bp)",0,1);
a = ba.listInterp((0.0,0.0,1.0,0.0,0.0),in): hbargraph("[style:numerical]a(bp)",0,1);
q = ba.listInterp((0.0,0.0,0.0,1.0,1.0),in): hbargraph("[style:numerical]q(bp)",0,1);
d = ba.listInterp((0.5,0.5,0.5,0.5,1.0),in): hbargraph("[style:numerical]d(bp)",0,1);

process = s,t,a,q,d;
