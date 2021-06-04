//
// Handwritten GAC panel prototype
//

//import("stdfaust.lib");

gac = library("gac.lib");

// Control constants and converters
CONTROL_MIN = 0.0;
CONTROL_MAX = 1.0;
CONTROL_STEP = 0.01;
CONTROL_DEFAULT = CONTROL_MIN;
control2control(n) = n;

FREQ_MIN = 0.0;
FREQ_MAX = 20000.0;
FREQ_STEP = 0.01;
FREQ_DEFAULT = FREQ_MIN;
freq2control(n) = n/FREQ_MAX;
control2freq(n) = n*FREQ_MAX;

PERIOD_MIN = 0.0;
PERIOD_MAX = 1000.0;
PERIOD_STEP = 0.01;
PERIOD_DEFAULT = PERIOD_MIN;
period2control(n) = n/PERIOD_MAX;
control2period(n) = n*PERIOD_MAX;

Q_MIN = 0.0;
Q_MAX = 100.0;
Q_STEP = 0.01;
Q_DEFAULT = 1;
q2control(n) = n/Q_MAX;
control2q(n) = n*Q_MAX;

COUNT_MIN = 0;
COUNT_MAX = gac.N - 1;
COUNT_STEP = 1;
COUNT_DEFAULT = COUNT_MIN;
count2control(n) = n/COUNT_MAX;
control2count(n) = n*COUNT_MAX;


// Embed description and osc/midi controls
// ---
// desc:
//   outputs: 1
//   blocks:
//     - lookup
//     - lookup: freq
//     - index
//     - osc
//     - clock
//     - ar
//     - osh
//     - amp
// osc:
// midi:
// ...

///////////////////////////////////////////////////////////////////////////////
// lookup1 (freq)
//
// index1_out (forward reference)

lookup1(index1_out) = (lookup_table,
                       lookup_pgm_idx,
                       lookup_pgm_val,
                       lookup_pgm_we,
                       lookup_idx) : gac.lookup : hbargraph("[1][style:numerical]freq",0,FREQ_MAX)
with {

    // <block><block_idx>_<in_arg_typename>
    lookup_table = waveform{
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0.0 // dummy for write; float to force underlying waveform type
    };

    run = checkbox("[2]run");

    lookup_pgm_val =
        nentry("[3]wval",FREQ_DEFAULT,FREQ_MIN,FREQ_MAX,FREQ_STEP);
    lookup_pgm_idx_f =
        nentry("[4]widx",0,0,gac.N-1,1);
    lookup_pgm_we =
        button("[5]set");
    lookup_pgm_idx = int(floor(lookup_pgm_idx_f));

    // no mux so run_idx is just index1_out
    run_idx = index1_out;
    lookup_idx = select2(run, lookup_pgm_idx, run_idx) : hbargraph("[0][style:numerical]idx",0,gac.N);

};

///////////////////////////////////////////////////////////////////////////////
// lookup2
//
// ridx=index1_out (forward reference)

lookup2(index1_out) = (lookup_table,
                       lookup_pgm_idx,
                       lookup_pgm_val,
                       lookup_pgm_we,
                       lookup_idx) : gac.lookup : hbargraph("[1][style:numerical]val",0,CONTROL_MAX)
with {

     lookup_table = waveform{
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
         0.1 // dummy for write; float to force underlying waveform type, different to prevent waveform coelescing
     };

    run = checkbox("[2]run");

    lookup_pgm_val =
        nentry("[3]wval",CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);
    lookup_pgm_idx_f =
        nentry("[4]widx",0,0,gac.N-1,1);
    lookup_pgm_we =
        button("[5]set");
    lookup_pgm_idx = int(floor(lookup_pgm_idx_f));


    // no mux so run_idx is just index1_out
    run_idx = index1_out;
    lookup_idx = select2(run, lookup_pgm_idx, run_idx) : hbargraph("[0][style:numerical]idx",0,gac.N);
};

///////////////////////////////////////////////////////////////////////////////
// index1
//
// clock1_out (forward reference)
// osh1_out (forward reference)

index1(clock1_out,osh1_out) = (index_clk,index_len) : gac.index
with {
    // logic selector generated

    index_clk_sel_clock1_clk = checkbox("[0]clock1");
    index_clk_sel_osh1_clk = checkbox("[1]osh1");
    index_clk =
        (index_clk_sel_clock1_clk & clock1_out) |
        (index_clk_sel_osh1_clk & osh1_out);

    index_len =
        nentry("len",COUNT_DEFAULT,COUNT_MIN,COUNT_MAX,COUNT_DEFAULT);

};

///////////////////////////////////////////////////////////////////////////////
// osc1
//
// lookup1_out
// lookup2_out
// ar1_out (forward reference)

osc1(lookup1_out, lookup2_out, ar1_out) = (osc_freq, osc_shape) : gac.osc
with {
    osc_freq_knob =
        nentry("[0]freq",FREQ_DEFAULT,FREQ_MIN,FREQ_MAX,FREQ_STEP);
    osc_lookup1_input_freq_knob =
        nentry("[1]lookup1_freq",
                  CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);
    osc_lookup2_input_freq_knob =
        nentry("[2]lookup2_freq",
                  CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);
    osc_ar1_input_freq_knob =
        nentry("[3]ar1_freq",
                 CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);

    osc_freq =
        (lookup1_out * osc_lookup1_input_freq_knob) +
        (control2freq(lookup2_out) * osc_lookup2_input_freq_knob) +
        (control2freq(ar1_out) * osc_ar1_input_freq_knob) +
        osc_freq_knob
    ;

    osc_shape_knob =
        nentry("[4]shape",
                 CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);

    osc_lookup1_input_shape_knob =
        nentry("[5]lookup1_shape",
                CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);
    osc_lookup2_input_shape_knob =
        nentry("[6]lookup2_shape",
                CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);
    osc_ar1_input_shape_knob =
               nentry("[7]ar1_shape",
                       CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);
    osc_shape =
        (freq2control(lookup1_out) * osc_lookup1_input_shape_knob) +
        (lookup2_out * osc_lookup2_input_shape_knob) +
        (ar1_out * osc_ar1_input_shape_knob) +
        osc_shape_knob
    ;


};

///////////////////////////////////////////////////////////////////////////////
// clock1
//
// lookup1_out
// lookup2_out
// ar1_out (forward reference)

clock1(lookup1_out, lookup2_out, ar1_out) = select2(run, step_clock, gac.clock(clock_freq))
with {
    run = checkbox("[0]run");
    step = button("[1]step");
    clock_freq_knob =
        nentry("[2]freq",FREQ_DEFAULT,FREQ_MIN,FREQ_MAX,FREQ_STEP);
    clock_lookup1_input_freq_knob =
        nentry("[3]lookup1",
                CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);
    clock_lookup2_input_freq_knob =
        nentry("[4]lookup2",
                CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);
    clock_ar1_input_freq_knob =
        nentry("[5]ar1",
                CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);

    clock_freq =
        (lookup1_out * clock_lookup1_input_freq_knob) +
        (control2freq(lookup2_out) * clock_lookup2_input_freq_knob) +
        (control2freq(ar1_out) * clock_ar1_input_freq_knob) +
        clock_freq_knob
    ;

    step_clock = gac.osh(1.0/clock_freq_knob, step);
};



///////////////////////////////////////////////////////////////////////////////
// ar1
//
//
ar1(lookup1_out, lookup2_out, clock1_out, osh1_out) = (ar_attack, ar_release, ar_gate) : gac.ar
with {
  ar_lookup1_input_attack_knob =
      nentry("[1]lookup1_attack",
              PERIOD_DEFAULT,PERIOD_MIN,PERIOD_MAX,PERIOD_STEP);
  ar_lookup2_input_attack_knob =
      nentry("[2]lookup2_attack",
              PERIOD_DEFAULT,PERIOD_MIN,PERIOD_MAX,PERIOD_STEP);
  ar_attack_knob =
      nentry("[0]attack",
              PERIOD_DEFAULT,PERIOD_MIN,PERIOD_MAX,PERIOD_STEP);

  ar_attack =
      (control2period(freq2control(lookup1_out)) * ar_lookup1_input_attack_knob) +
      (control2period(lookup2_out) * ar_lookup2_input_attack_knob) +
      ar_attack_knob
  ;

  ar_lookup1_input_release_knob =
      nentry("[4]lookup1_release",
              PERIOD_DEFAULT,PERIOD_MIN,PERIOD_MAX,PERIOD_STEP);
  ar_lookup2_input_release_knob =
      nentry("[5]lookup2_release",
              PERIOD_DEFAULT,PERIOD_MIN,PERIOD_MAX,PERIOD_STEP);
  ar_release_knob =
      nentry("[3]release",
              PERIOD_DEFAULT,PERIOD_MIN,PERIOD_MAX,PERIOD_STEP);

  ar_release =
      (control2period(freq2control(lookup1_out)) * ar_lookup1_input_release_knob) +
      (control2period(lookup2_out) * ar_lookup2_input_release_knob) +
      ar_release_knob
  ;

  ar_gate_sel_clock1 =
      checkbox("[6]clock1_gate");
  ar_gate_sel_osh1 =
      checkbox("[7]osh1_gate");
  ar_gate =
  (ar_gate_sel_clock1 & clock1_out) |
  (ar_gate_sel_osh1 & osh1_out);

};

///////////////////////////////////////////////////////////////////////////////
// osh1
osh1(lookup1_out, lookup2_out, clock1_out) = (osh_dur, osh_gate) : gac.osh
with {

    osh_lookup1_input_dur_knob =
        nentry("[1]lookup1",
                PERIOD_DEFAULT,PERIOD_MIN,PERIOD_MAX,PERIOD_STEP);
    osh_lookup2_input_dur_knob =
        nentry("[2]lookup2",
                PERIOD_DEFAULT,PERIOD_MIN,PERIOD_MAX,PERIOD_STEP);
    osh_dur_knob =
        nentry("[0]dur",
                PERIOD_DEFAULT,PERIOD_MIN,PERIOD_MAX,PERIOD_STEP);

    osh_dur =
        (control2period(freq2control(lookup1_out)) * osh_lookup1_input_dur_knob) +
        (control2period(lookup2_out) * osh_lookup2_input_dur_knob) +
        osh_dur_knob
    ;

    // Only one possibility
    osh_gate = clock1_out;
};


///////////////////////////////////////////////////////////////////////////////
// amp1
amp1(osc1_out, lookup1_out, lookup2_out, ar1_out) = (amp_gain,amp_input) : gac.amp
with {

    amp_input_enable = checkbox("[0] enable osc1");
    amp_input = select2(amp_input_enable, 0, osc1_out);

    amp_lookup1_input_gain_knob =
        nentry("[1]lookup1",
                CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);
    amp_lookup2_input_gain_knob =
        nentry("[2]lookup2",
                CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);
    amp_ar1_input_gain_knob =
        nentry("[3]ar1",
                CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);
    amp_gain_knob =
        nentry("[0]gain",
                CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);

    amp_gain =
        (freq2control(lookup1_out) * amp_lookup1_input_gain_knob) +
        (lookup2_out * amp_lookup2_input_gain_knob) +
        (ar1_out * amp_ar1_input_gain_knob) +
        amp_gain_knob
    ;

};

///////////////////////////////////////////////////////////////////////////////
// output1

output1(osc1_out, amp1_out) = out
with {
    output_osc1_knob =
        nentry("[0]osc1",
                CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);
    output_amp1_knob =
        nentry("[1]amp1",
                CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);
    vol =
        nentry("[2]vol",
                CONTROL_DEFAULT,CONTROL_MIN,CONTROL_MAX,CONTROL_STEP);

    in =
        (osc1_out * output_osc1_knob) +
        (amp1_out * output_amp1_knob);

    out = in * vol;

};

panel(lookup1_out,
    lookup2_out,
    index1_out,
    osc1_out,
    clock1_out,
    ar1_out,
    osh1_out,
    amp1_out,
    output1_out) = tgroup("top",
       vgroup("[0]lookup1", lookup1(index1_out)),
       vgroup("[1]lookup2", lookup2(index1_out)),
       vgroup("[2]index1", index1(clock1_out, osh1_out)),
       vgroup("[3]osc1", osc1(lookup1_out, lookup2_out, ar1_out)),
       vgroup("[4]clock1", clock1(lookup1_out, lookup2_out, ar1_out)),
       vgroup("[5]ar1", ar1(lookup1_out, lookup2_out, clock1_out, osh1_out)),
       vgroup("[6]osh1", osh1(lookup1_out, lookup2_out, clock1_out)),
       vgroup("[7]amp1", amp1(osc1_out, lookup1_out, lookup2_out, ar1_out)),
       vgroup("[8]output1", output1(osc1_out,amp1_out)));

// copy input to output to facilitate forward referencing
copy(lookup1_out,
    lookup2_out,
    index1_out,
    osc1_out,
    clock1_out,
    ar1_out,
    osh1_out,
    amp1_out,
    output1_out) =
   (lookup1_out,
    lookup2_out,
    index1_out,
    osc1_out,
    clock1_out,
    ar1_out,
    osh1_out,
    amp1_out,
    output1_out);

// manage final outputs
output(lookup1_out,
    lookup2_out,
    index1_out,
    osc1_out,
    clock1_out,
    ar1_out,
    osh1_out,
    amp1_out,
    output1_out) = (output1_out);

process = (panel ~ copy) : output;
