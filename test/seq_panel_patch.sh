#!/bin/sh
# /top si "xmit" 0
# /top si "bundle" 0
# /top ss "desthost" "127.0.0.1"
# /top s "json"
# /top si "outport" 5511
# /top si "errport" 5512
# /top/lookup1/idx fff 0.000000 0.000000 256.000000
# /top/lookup1/freq fff 0.000000 0.000000 20000.000000
# /top/lookup1/run fff 0.000000 0.000000 1.000000
# /top/lookup1/wval fff 0.000000 0.000000 20000.000000
# /top/lookup1/widx fff 0.000000 0.000000 255.000000
# /top/lookup1/set fff 0.000000 0.000000 1.000000
# /top/lookup2/idx fff 0.000000 0.000000 256.000000
# /top/lookup2/val fff 0.000000 0.000000 10.000000
# /top/lookup2/run fff 0.000000 0.000000 1.000000
# /top/lookup2/wval fff 0.000000 0.000000 1.000000
# /top/lookup2/widx fff 0.000000 0.000000 255.000000
# /top/lookup2/set fff 0.000000 0.000000 1.000000
# /top/index1/clock1 fff 0.000000 0.000000 1.000000
# /top/index1/osh1 fff 0.000000 0.000000 1.000000
# /top/index1/len fff 0.000000 0.000000 255.000000
# /top/osc1/freq fff 0.000000 0.000000 20000.000000
# /top/osc1/lookup1_freq fff 0.000000 0.000000 1.000000
# /top/osc1/lookup2_freq fff 0.000000 0.000000 1.000000
# /top/osc1/ar1_freq fff 0.000000 0.000000 1.000000
# /top/osc1/shape fff 0.000000 0.000000 1.000000
# /top/osc1/lookup1_shape fff 0.000000 0.000000 1.000000
# /top/osc1/lookup2_shape fff 0.000000 0.000000 1.000000
# /top/osc1/ar1_shape fff 0.000000 0.000000 1.000000
# /top/clock1/run fff 0.000000 0.000000 1.000000
# /top/clock1/step fff 0.000000 0.000000 1.000000
# /top/clock1/freq fff 0.000000 0.000000 20000.000000
# /top/clock1/lookup1 fff 0.000000 0.000000 1.000000
# /top/clock1/lookup2 fff 0.000000 0.000000 1.000000
# /top/clock1/ar1 fff 0.000000 0.000000 1.000000
# /top/ar1/attack fff 0.000000 0.000000 1000.000000
# /top/ar1/lookup1_attack fff 0.000000 0.000000 1000.000000
# /top/ar1/lookup2_attack fff 0.000000 0.000000 1000.000000
# /top/ar1/release fff 0.000000 0.000000 1000.000000
# /top/ar1/lookup1_release fff 0.000000 0.000000 1000.000000
# /top/ar1/lookup2_release fff 0.000000 0.000000 1000.000000
# /top/ar1/clock1_gate fff 0.000000 0.000000 1.000000
# /top/ar1/osh1_gate fff 0.000000 0.000000 1.000000
# /top/osh1/dur fff 0.000000 0.000000 1000.000000
# /top/osh1/lookup1 fff 0.000000 0.000000 1000.000000
# /top/osh1/lookup2 fff 0.000000 0.000000 1000.000000
# /top/amp1/enable_osc1 fff 0.000000 0.000000 1.000000
# /top/amp1/gain fff 0.000000 0.000000 1.000000
# /top/amp1/lookup1 fff 0.000000 0.000000 1.000000
# /top/amp1/lookup2 fff 0.000000 0.000000 1.000000
# /top/amp1/ar1 fff 0.000000 0.000000 1.000000
# /top/output1/osc1 fff 0.000000 0.000000 1.000000
# /top/output1/amp1 fff 0.000000 0.000000 1.000000
# /top/output1/vol fff 0.000000 0.000000 1.000000

# oscsend localhost 5513 "/seq_ui/idx" f $1
send() {
    oscsend localhost 5513 $1 f $2
}

rcv() {
    oscsend localhost 5513 $1 f get
}

toggle() {
    send $1 1
    sleep 1
    send $1 0
}

send "/top/lookup1/widx" 0
send "/top/lookup1/wval" 440.0
toggle "/top/lookup1/set"
send "/top/lookup1/widx" 1
send "/top/lookup1/wval" 493.88
toggle "/top/lookup1/set"
send "/top/lookup1/widx" 2
send "/top/lookup1/wval" 554.36
toggle "/top/lookup1/set"
send "/top/lookup1/widx" 3
send "/top/lookup1/wval" 587.32
toggle "/top/lookup1/set"
send "/top/lookup1/run" 1

send "/top/lookup2/widx" 0
send "/top/lookup2/wval" 0
toggle "/top/lookup2/set"
send "/top/lookup2/widx" 1
send "/top/lookup2/wval" 0.2
toggle "/top/lookup2/set"
send "/top/lookup2/widx" 2
send "/top/lookup2/wval" 0.4
toggle "/top/lookup2/set"
send "/top/lookup2/widx" 3
send "/top/lookup2/wval" 0.6
toggle "/top/lookup2/set"
send "/top/lookup2/run" 1

send "/top/index1/clock1" 1
send "/top/index1/len" 4

send "/top/osc1/lookup1_freq" 1
send "/top/osc1/lookup2_shape" 1

send "/top/clock1/freq" 4
send "/top/clock1/run" 1

send "/top/ar1/attack" 0
send "/top/ar1/release" 0.12
send "/top/ar1/osh1_gate" 1

send "/top/osh1/dur" 0.12

send "/top/amp1/enable_osc1" 1
send "/top/amp1/ar1" 1

send "/top/output1/amp1" 1

#rcv
