; License: GPLv3 http://www.gnu.org/licenses/gpl - 3.0.txt
<CsoundSynthesizer>
<CsInstruments>
sr = 96000
ksmps = 9600
kr = 10
nchnls = 2

massign 1, 1

instr 1
  knote cpsmidib 1
  iveloc ampmidi 10000
  iscale = 0.33 * iveloc
  idur = 1

  iatt ctrl7 1, 73, 0.025, 2
  idec ctrl7 1, 75, 0.01, 1

  inoise ctrl7 1, 68, 0, 1
  isynth ctrl7 1, 69, 1, 0
  ibass ctrl7 1, 70, 1, 0 
  kpanon ctrl7 1, 61, 0, 1

  iws ctrl7 1, 90, 1, 16
  iws2 ctrl7 1, 91, 1, 16
  iws3 ctrl7 1, 92, 1, 16
  iwlfo ctrl7 1, 93, 1, 16

  kpan ctrl7 1, 10, 1, 0
  kvol ctrl7 1, 7, 0, 4 
  knoisegain ctrl7 1, 74, 0, 1
  knoisenote ctrl7 1, 88, 0, 1
  kchor ctrl7 1, 66, 0, 1

  kfreq ctrl7 1, 76, 0, 1
  klfos ctrl7 1, 65, 0, 1

  kpitch ctrl7 1, 63, 0, 1
  kcuttlfo ctrl7 1, 62, 0, 1
  kpitchdepth ctrl7 1, 77, 0, 1
  kcuttdepth ctrl7 1, 78, 0, 127
  ksteepness ctrl7 1, 72, 0, 1

  ; Non linear parameters ;
  kchor = 1.006^kchor - 1
  kvol = 2^kvol - 1
  knoisegain = 10^knoisegain - 1
  kfreq = 20^kfreq - 1
  ksteepness = 100^ksteepness
  idec = 5^idec - 1

  ak1 linenr iscale, iatt, ( i(knote) < 221 && ibass == 1 ) ? 0.01 : idec, 0.1
  
  ; LFO ;
  amodu oscil  1, kfreq, iwlfo
  kmodu downsamp amodu

  ; SYNTH ;
  if ( isynth == 1 ) then
    if ( kpitch == 1 ) then
      an3 oscil ak1, (knote + amodu * kpitchdepth * 10) * (1 - kchor), iws2
      an2 oscil ak1, (knote + amodu * kpitchdepth * 10) * (1 + kchor), iws3
      an1 oscil ak1, (knote + amodu * kpitchdepth * 10), iws
    else
      an3 oscil ak1, knote * (1 - kchor), iws2
      an2 oscil ak1, knote * (1 + kchor), iws3
      an1 oscil ak1, knote, iws
    endif

    an = (an1 + an2 + an3) * 0.33
  endif

  ; NOISE ;
  if ( inoise == 1 ) then
    ares1 random 20, 20000
    ares2 random 20, 20000
    ares3 random 20, 20000

    ares1 areson ares1, knote, 128, 2, 0
    ares2 areson ares2, knote, 128, 2, 0
    ares3 areson ares3, knote, 128, 2, 0

    ares1 = (ares1 + ares2 + ares3)
  endif

  a440   oscili   ak1, 69, 1

  if ( kcuttlfo == 1 ) then
    a2 butterbp ares1, knote, ksteepness + (1 + kmodu) * kcuttdepth
    a3 butterbp ares1, knote * 2, ksteepness + (1 + kmodu) * kcuttdepth
    a4 butterbp ares1, knote * 3, ksteepness + (1 + kmodu) * kcuttdepth
    a1 balance (a2 + a3 + a4), a440
  else
    ares1 butterbp ares1, knote, ksteepness
    ares2 butterbp ares1, knote * 2, ksteepness
    ares3 butterbp ares1, knote * 3, ksteepness

    ares1 = (ares1 + ares2 + ares3) * ak1

    a1 balance ares1, a440
  endif

  ; OUTPUT ;
  if( isynth == 1) then
    a1 = (inoise == 1 ? (a1 * knoisenote  + an * (knoisenote - 1)) * 0.5 : an)
  endif

  a1 eqfil a1, 40, 100, 6
  a1 pareq a1, 200, 0.2, 0.707, 2
  a1 eqfil a1, 1000, 700, 0.8 
  a1 eqfil a1, 3000, 1000, 2
  a1 = a1 * kvol

  amod1 = (1 - amodu * kpitchdepth) 
  amod2 = (kpanon == 1 ? (1 + amodu * kpitchdepth) : amod1)

  outs a1 * amod1 * kpan, a1 * amod2 * (1 - kpan)
endin
</CsInstruments>

<CsScore>
f0 30000000
f1 0 4096   10  1 ; sine
f2 0 4096   10  1 1 1 .7 .5 .3 .1     ; pulse
f3 0 4096   7  1 4096 -1 ; triangle
f4 0 4096   7  1 2048 1 0 -1 2048 -1 ;square
f5 0 64 5  1 2 120 60 1 1 0.001 1 ; exp decay
;http://www.csounds.com/ezine/spectra/
; Partials No. 1     2   3  4   5  6  7   8  9  10  11 12   13 14  15  6  17  18  19  20  21
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
