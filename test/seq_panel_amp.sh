#!/bin/sh

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

send "/top/osc1/freq" 1000

send "/top/amp1/enable_osc1" 1
send "/top/amp1/gain" 1

send "/top/output1/amp1" 1

#rcv
