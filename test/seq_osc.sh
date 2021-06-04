#!/bin/sh


# /seq_ui/freq_s fff 100.000000 0.000000 1000.000000
# /seq_ui/shape_s fff 0.000000 0.000000 1.000000
# /seq_ui/widx fff 256.000000 0.000000 2000.000000
# /seq_ui/attack fff 0.050000 0.000000 1.000000
# /seq_ui/clock fff 1.000000 0.100000 200.000000
# /seq_ui/fval fff 20.000000 20.000000 2000.000000
# /seq_ui/idx fff 0.000000 0.000000 255.000000
# /seq_ui/len fff 4.000000 1.000000 256.000000
# /seq_ui/pgmf fff 0.000000 0.000000 1.000000
# /seq_ui/pgms fff 0.000000 0.000000 1.000000
# /seq_ui/release fff 0.050000 0.000000 1.000000
# /seq_ui/sval fff 0.000000 0.000000 1.000000
# /seq_ui/volume fff -96.000000 -96.000000 6.000000

# A  440
# Bb 466.1637615180899
# B  493.8833012561241
# C  523.2511306011974
# C# 554.3652619537443
# D  587.3295358348153
# D# 622.253967444162
# E  659.2551138257401
# F  698.456462866008
# F# 739.988845423269
# G  783.990871963499
# G# 830.6093951598907
# A  880.0000000000003


# oscsend localhost 5513 "/seq_ui/fval" f 440.0
# oscsend localhost 5513 "/seq_ui/idx" f 0
# oscsend localhost 5513 "/seq_ui/pgmf" f 1
# oscsend localhost 5513 "/seq_ui/pgmf" s get
# oscsend localhost 5513 "/seq_ui/pgmf" f 0
# oscsend localhost 5513 "/seq_ui/pgmf" s get

# oscsend localhost 5513 "/seq_ui/fval" f 440.0
# oscsend localhost 5513 "/seq_ui/idx" f 1
# oscsend localhost 5513 "/seq_ui/pgmf" f 1
# oscsend localhost 5513 "/seq_ui/pgmf" s get
# oscsend localhost 5513 "/seq_ui/pgmf" f 0
# oscsend localhost 5513 "/seq_ui/pgmf" s get

# oscsend localhost 5513 "/seq_ui/fval" f 440.0
# oscsend localhost 5513 "/seq_ui/idx" f 2
# oscsend localhost 5513 "/seq_ui/pgmf" f 1
# oscsend localhost 5513 "/seq_ui/pgmf" s get
# oscsend localhost 5513 "/seq_ui/pgmf" f 0
# oscsend localhost 5513 "/seq_ui/pgmf" s get

# oscsend localhost 5513 "/seq_ui/fval" f 440.0
# oscsend localhost 5513 "/seq_ui/idx" f 3
# oscsend localhost 5513 "/seq_ui/pgmf" f 1
# oscsend localhost 5513 "/seq_ui/pgmf" s get
# oscsend localhost 5513 "/seq_ui/pgmf" f 0
# oscsend localhost 5513 "/seq_ui/pgmf" s get

# oscsend localhost 5513 "/seq_ui/fval" f 440.0
# oscsend localhost 5513 "/seq_ui/idx" f 4
# oscsend localhost 5513 "/seq_ui/pgmf" f 1
# oscsend localhost 5513 "/seq_ui/pgmf" s get
# oscsend localhost 5513 "/seq_ui/pgmf" f 0
# oscsend localhost 5513 "/seq_ui/pgmf" s get

# oscsend localhost 5513 "/seq_ui/fval" f 493.88
# oscsend localhost 5513 "/seq_ui/idx" f 5
# oscsend localhost 5513 "/seq_ui/pgmf" f 1
# oscsend localhost 5513 "/seq_ui/pgmf" s get
# oscsend localhost 5513 "/seq_ui/pgmf" f 0
# oscsend localhost 5513 "/seq_ui/pgmf" s get

# oscsend localhost 5513 "/seq_ui/fval" f 554.36
# oscsend localhost 5513 "/seq_ui/idx" f 6
# oscsend localhost 5513 "/seq_ui/pgmf" f 1
# oscsend localhost 5513 "/seq_ui/pgmf" s get
# oscsend localhost 5513 "/seq_ui/pgmf" f 0

# oscsend localhost 5513 "/seq_ui/fval" f 587.32
# oscsend localhost 5513 "/seq_ui/idx" f 7
# oscsend localhost 5513 "/seq_ui/pgmf" f 1
# oscsend localhost 5513 "/seq_ui/pgmf" s get
# oscsend localhost 5513 "/seq_ui/pgmf" f 0
# oscsend localhost 5513 "/seq_ui/pgmf" s get

# oscsend localhost 5513 "/seq_ui/len" f 8

# oscsend localhost 5513 "/seq_ui/volume" f 0

if [ $# == 2 ]
then
    oscsend localhost 5513 "/seq_ui/idx" f $1
    oscsend localhost 5513 "/seq_ui/fval" f $2
    oscsend localhost 5513 "/seq_ui/pgmf" f 1
    oscsend localhost 5513 "/seq_ui/pgmf" s get
    oscsend localhost 5513 "/seq_ui/pgmf" f 0
    oscsend localhost 5513 "/seq_ui/pgmf" s get
    echo $*
else
    exit 1
fi
