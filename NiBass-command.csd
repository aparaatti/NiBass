; License: GPLv3 http://www.gnu.org/licenses/gpl - 3.0.txt
<CsoundSynthesizer>
<CsInstruments>
sr = 96000
ksmps = 128
nchnls = 2

massign 1,1

instr 1
  knote cpsmidib 1
  iscale ampmidi 10000

  ; MIDI            ch cc   min    max
  iatt        ctrl7 1, 73,  0.025, 2
  idec        ctrl7 1, 75,   0.01, 1

  isynth      ctrl7 1, 42,      1, 0
  ibasson     ctrl7 1, 60,      1, 0

  iws1        ctrl7 1, 90,      1, 16
  iws2        ctrl7 1, 91,      1, 16
  iws3        ctrl7 1, 92,      1, 16

  kpan        ctrl7 1, 10,      0, 1
  kvol        ctrl7 1, 7,       0, 4
  kchor       ctrl7 1, 66,      0, 1

  klfopanon   ctrl7 1, 61,      0, 1
  klfocuton   ctrl7 1, 62,      0, 1
  klfovolon   ctrl7 1, 63,      0, 1
  klfopitchon ctrl7 1, 64,      0, 1

  kfreq1      ctrl7 1, 76,      0, 1
  iwlfo1      ctrl7 1, 93,      1, 16
  kfreq2      ctrl7 1, 20,      0, 1
  iwlfo2      ctrl7 1, 5,      1, 16

  kpitchdepth ctrl7 1, 77,      0, 1
  kpandepth   ctrl7 1, 78,      0, 1
  kvoldepth   ctrl7 1, 79,      0, 1

  kcuttdepth  ctrl7 1, 80,      0, 127
  ksteepness  ctrl7 1, 81,      0, 1

  inoise      ctrl7 1, 43,      0, 1
  knoisegain  ctrl7 1, 74,      0, 1
  knoisenote  ctrl7 1, 88,      0, 1

  ; Non linear parameters ;
  kchor = 1.006^kchor - 1
  kvol = 2^kvol - 1
  knoisegain = 10^knoisegain - 1
  kfreq1 = 20^kfreq1 - 1
  kfreq2 = 20^kfreq2 - 1
  ksteepness = 100^ksteepness
  idec = 5^idec - 1

  aenvelope linenr iscale, iatt, (i(knote) < 221 && ibasson == 1 ? 0.02 : idec), 0.1
  a1 oscil aenvelope, knote, iws1

  amodu oscil  1, kfreq1, iwlfo1
  amodu2 oscil  1, kfreq2, iwlfo2

  if ( isynth == 1 ) then
    amodulate = amodu2 * kpitchdepth * 10 * klfopitchon

    an3 oscil aenvelope, (knote + amodulate) * (1 - kchor), iws2
    an2 oscil aenvelope, (knote + amodulate) * (1 + kchor), iws3
    an1 oscil aenvelope, knote + amodulate, iws1

    an = (an1 + an2 + an3) * 0.33
  endif

  if ( inoise == 1 ) then
    ares1 random 20, 20000
    ares2 random 20, 20000
    ares3 random 20, 20000

    ares1 areson ares1, knote, 128, 2, 0
    ares2 areson ares2, knote, 128, 2, 0
    ares3 areson ares3, knote, 128, 2, 0

    ares = (ares1 + ares2 + ares3) * 0.33
  endif

  ; COMBINE ;
  a0 = ( isynth == 1 ? an : a1 )
  a0 = ( inoise == 1 ? (a0 * knoisenote  + ares * ( knoisenote - 1 )) * 0.5 : a0 )

  ; FILTER ;
  a440   oscili   aenvelope, 69, 1

  a2 butterbp a0, knote,     ksteepness + ((1 + amodu * klfocuton) * kcuttdepth)
  a3 butterbp a0, knote * 2, ksteepness + ((1 + amodu * klfocuton) * kcuttdepth)
  a4 butterbp a0, knote * 3, ksteepness + ((1 + amodu * klfocuton) * kcuttdepth)
  a0 balance (a2 + a3 + a4), a440

;  a0 eqfil a0, 40, 100, 6
;  a0 pareq a0, 200, 0.2, 0.707, 2
;  a0 eqfil a0, 1000, 700, 0.8
;  a0 eqfil a0, 3000, 1000, 2

  ; OUTPUT ;
  amplitudeMod1 = (1 - amodu2 * kvoldepth * klfovolon)
  aPanAmplitudeMod1 = (amplitudeMod1 * (1 - amodu * kpandepth * klfopanon))
  aPanAmplitudeMod2 = (amplitudeMod1 * (1 + amodu * kpandepth * klfopanon))

  aleft = (a0 * aPanAmplitudeMod1 * kpan * kvol)
  aright = (a0 * aPanAmplitudeMod2 * (1 - kpan) * kvol)

  outs aleft,aright

  ; GUI
  prints "\033c"
  prints "                  ______________________\n"
  prints "           ,=====/ PAN: %03.1f = VOL: %04.1f \\\\=====.\n", kpan, kvol
  prints "           ▏ SYNTH: [ %02i %02i %02i ]  C: %0.3f %s ▕\n", iws1, iws2, iws3, kchor,
    (isynth == 1 ? "🟢" : "🔴")
  prints "           ▏ LFO 01:   [ %02i ]      Fq: %05.2f  ▕\n", iwlfo1, kfreq1
  prints "           ▏   PAN     %3.2f                %s ▕\n", kpandepth,
    (klfopanon   == 1 ? "🟢" : "🔴")
  prints "           ▏   CUT     %03i %06.3f          %s ▕\n", kcuttdepth,  ksteepness,
    (klfocuton   == 1 ? "🟢" : "🔴")
  prints "           ▏ LFO 02:   [ %02i ]      Fq: %05.2f  ▕\n", iwlfo2, kfreq2
  prints "           ▏   VOL     %3.2f                %s ▕\n", kvoldepth,
    (klfovolon   == 1 ? "🟢" : "🔴")
  prints "           ▏   PITCH   %3.2f                %s ▕\n", kpitchdepth,
    (klfopitchon == 1 ? "🟢" : "🔴")
  prints "           ▏ NOISE:    %02.1f %03.2f            %s ▕\n", knoisegain*inoise, knoisenote,
    (inoise == 1 ?  "🟢" : "🔴")
  prints "           `=====\\\\ A:%03.1f D:%03.1f%s %05.1f /====='\n", iatt, idec,
    (ibasson == 1 ? "🟢" : "🔴"), iscale
  prints "                  ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔\n"
endin
</CsInstruments>

<CsScore>
  f0 30000000
  f1 0 4096   10  1                      ; sine
  f2 0 4096   10  1 1 1 .7 .5 .3 .1      ; pulse
  f3 0 4096   7  1 4096 -1               ; triangle
  f4 0 4096   7  1 2048 1 0 -1 2048 -1   ; square
  f5 0 64 5  1 2 120 60 1 1 0.001 1      ; exp decay

  ; Partials No. 1     2   3  4   5  6  7   8  9  10  11 12   13 14  15  6  17  18  19  20  21
  ; http://www.csounds.com/ezine/spectra/
  f6 0 16384 10  0    .8  .5  0  .3  0  0  .2  0  0   0  0   .1
  f7 0 16384 10  1.3  .8  .5  0  .3  0  0  .2  0  0   0  0   .1  0   0   0   0   0   0   0  .1
  ; Fibonacci Partials
  f8 0 16384 9  130 .89 0  210 .55 0  340 .34 0  550 .21 0  890 .13 0  1440 .05 0  233 .05 0
  ; Lucas Partials
  f9 0 16384 9  110 1 0  180 .89 0  290 .55 0  470 .34 0  760 .21 0  1230 .13 0  1990 .08 0

  f10 0 32 7  1 2 0.7 2 1 2 0.6 2 1 2 0.4 2 1 2 0.2 2 1 2 0.5 2 0.1 2 0 2 1.2 5 0.4 5
  f11 0 32 7  0 2 1.2 5 0.4 5 0.1 2 0 2 1.2 5 0.4 5
  f12 0 32 7  1 2 0.7 2 1 2 0.6 2 1 2 0.4 2 0.9 2 0.2 2 0.8 2 0.15 2 0.7 2 0 2 0.6 2 0 2 0.5 2 0.2 2
  f13 0 32 7  1 2 0.4 1.5 1 1.5 0.6 2 1 2 0.4 2 0.9 2 0.2 2 0.8 2 0.15 2 0.7 2 0 2 0.6 2 0.2 0.5 0.2 0.5 0.2
  f14 0 1024 10 1 1 1 1 1 1
  f15 0 1024   7 0 10 1 236 1  10 0.8 125 0.8   10 -0.7 180 -0.7   10 0.5 50 0.5  11 -0.2 600 -0.2 20 0
  f16 0 1024   5 1 256 1  2 0.8 256 0.8   2 0.7 100 0.7   2 0.5 300 0.5
</CsScore>
</CsoundSynthesizer>
