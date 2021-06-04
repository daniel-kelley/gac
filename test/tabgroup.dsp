import("stdfaust.lib");

saw(f,g) = os.sawtooth(f)*g;

saw1 = saw(f,g)
with {
  q(x) = vgroup("saw1", x);
  f = q(hslider("freq",440,50,1000,0.1));
  g = q(hslider("gain",0,0,1,0.01));
};

saw2 = saw(f,g)
with {
  q(x) = vgroup("saw2", x);
  f = q(hslider("freq",440,50,1000,0.1));
  g = q(hslider("gain",0,0,1,0.01));
};

process = tgroup("TG",saw1,saw2);


//Fader(in)               = ba.db2linear(vslider("Input %in", -10, -96, 4, 0.1));
//Mixer(N,out)    = hgroup("Output %out", par(in, N, *(Fader(in)) ) :> _ );
//Matrix(N,M)     = tgroup("Matrix %N x %M", par(in, N, _) <: par(out, M, Mixer(N, out)));
//
//process = Matrix(8, 8);
