;
;License: GPLv3 http://www.gnu.org/licenses/gpl-3.0.txt
;
;A csound synth inteted to be played and controlled
;with midi-keyboard (There is also a versions with csoundqt GUI available to 
;display used waveforms and controller changes, and there'll be a version
;with GUI controls only.)
;
;I used M-audio AxiumPro49 so if you have one, you know you have enough buttons
;to control this :D. There probaply is mistakes in there, and if you spot
;one I would be happy to become aware of such. So comments are welcome at 
;nikohuma <at> gmail <dot> com.
;
;thanks to rgareus @ LAD for pointing stuff out
<CsoundSynthesizer>
<CsInstruments>
sr=96000
ksmps=9600
kr=10
nchnls=2 

massign 1,1

instr 1 

knote cpsmidib 1
iveloc ampmidi 10000
iscale = 0.33 * iveloc
idur = 1

#include "midibindings.csd"

;non linear:
kchor=1.006^kchor-1
kvol=2^kvol-1
knoisegain=10^knoisegain-1
kfreq = 20^kfreq-1
ksteepness = 100^ksteepness
idec=5^idec-1

;Envelopes; 
ak1	linenr iscale, iatt, idec, 0.1
ak2 linenr iscale, iatt, 0.01, 0.1

;Shorter decay for bass
if (knote < 221 && ibass == 1) then
	ak1=ak2
endif

amodu oscil	1, kfreq, iwlfo
kmodu downsamp amodu

;adjust vol to 400Hz sine
a440   oscili   ak1, 69, 1

;if synth on or noise off --> synth
if ( isynth == 1 || inoise == 0 ) then
    if (kpitch == 1) then ;värinä
	an3	oscil	ak1, (knote+amodu*kpitchdepth*10)*(1-kchor),iws2
	an2	oscil	ak1, (knote+amodu*kpitchdepth*10)*(1+kchor),iws3
	an1 oscil	ak1, (knote+amodu*kpitchdepth*10), iws
    else
	an3	oscil	ak1, knote*(1-kchor),iws2
	an2	oscil	ak1, knote*(1+kchor),iws3
	an1 oscil	ak1, knote, iws	
    endif

    an = (an1+an2+an3) * 0.33
endif

;if noise on or synth off --> noise
if ( inoise == 1 || isynth == 0 ) then ;noise
	ares random 20, 20000
	ares2 random 20, 20000
	ares3 random 20, 20000

	ares areson ares, knote, 128, 2, 0	
	ares2 areson ares2, knote, 128, 2, 0
	ares3 areson ares3, knote, 128, 2, 0
        ares = ares+ares2+ares3
        
    ;if no cutt lfo --> do filttering here
	if (kcuttlfo==0) then
            ares butterbp ares, knote, ksteepness
            ares2 butterbp ares, knote*2, ksteepness
            ares3 butterbp ares, knote*3, ksteepness
    endif

    ares = (ares + ares2 + ares3) *  ak1
endif

;if cuttlfo, filter
if (kcuttlfo == 1) then
	a2 butterbp ares, knote, ksteepness+(1+kmodu)*kcuttdepth
    a3 butterbp ares, knote*2, ksteepness+(1+kmodu)*kcuttdepth
    a4 butterbp ares, knote*3, ksteepness+(1+kmodu)*kcuttdepth
	a1 balance (a2 + a3 + a4), a440
else
	a1 balance ares, a440
endif

;If noise and synth on --> combine
if( isynth == 1 && inoise == 1) then
	a1 = (a1 * knoisenote  + an * (knoisenote - 1)) * 0.5
endif

;If noise not on --> synth only
if( isynth == 1 && inoise == 0) then
	a1 = an
endif

;sort of so so equal-loudness thingy
a1 eqfil a1, 40, 100, 6
a1 pareq a1, 200, 0.2, 0.707, 2
a1 eqfil a1, 1000, 700, 0.8 
a1 eqfil a1, 3000, 1000, 2


; Different output combinations:
if (klfos == 1 && kfreq > 0.0015) then
    a1 = a1 * kvol *(1-amodu*kpitchdepth)

	outs a1*kpan, a1* (1-kpan)
elseif kpanon ==1 then
    a1 = a1 * kvol

	outs  a1*(1-amodu*kpitchdepth)*kpan, a1*(1+amodu*kpitchdepth)*(1-kpan)
else
    a1 = a1 * kvol

	outs a1*kpan, a1*(1-kpan)
endif

endin

</CsInstruments>

<CsScore>
f0 30000000
f1 0 4096 	10	1 ;sine
f2 0 4096 	10	1 1 1 .7 .5 .3 .1     ;pulse
f3 0 32 7	1 2 0.7 2 1 2 0.6 2 1 2 0.4 2 1 2 0.2 2 1 2 0.5 2 0.1 2 0 2 1.2 5 0.4 5 ;harsh 1
f4 0 32 7	0 2 1.2 5 0.4 5 0.1 2 0 2 1.2 5 0.4 5	;harsh 2
f5 0 32 7	1 2 0.7 2 1 2 0.6 2 1 2 0.4 2 0.9 2 0.2 2 0.8 2 0.15 2 0.7 2 0 2 0.6 2 0 2 0.5 2 0.2 2 ;harsh 3
f6 0 64 5	1 2 120 60 1 1 0.001 1 ;exp decay
f7 0 4096 	7	1 4096 -1 ;triangle
f8 0 4096 	7	1 2048 1 0 -1 2048 -1 ;square
f9 0 32 7	1 2 0.4 1.5 1 1.5 0.6 2 1 2 0.4 2 0.9 2 0.2 2 0.8 2 0.15 2 0.7 2 0 2 0.6 2 0.2 0.5 0.2 0.5 0.2 ;harsh 4
;f10     0	0 	23	1	"aa-ni1.flac"		0		0		0
;http://www.csounds.com/ezine/spectra/
;- Partial No.  1    2   3   4  5   6  7  8   9  10  11 12  13  14  15  6  17  18  19  20  21
f10 0 16384 10	0    .8  .5  0  .3  0  0  .2  0  0   0  0   .1
f11 0 16384 10	1.3  .8  .5  0  .3  0  0  .2  0  0   0  0   .1  0   0   0   0   0   0   0  .1
; Fibonacci Partials 1.3        2.1        3.4        5.5        8.9        14.4        23.3
f12 0 16384 9	130 .89 0  210 .55 0  340 .34 0  550 .21 0  890 .13 0  1440 .05 0  233 .05 0
; Lucas Partials     1.1      1.8        2.9        4.7        7.6        12.3        19.9 
f13 0 16384 9	110 1 0  180 .89 0  290 .55 0  470 .34 0  760 .21 0  1230 .13 0  1990 .08 0
f14 0 1024 10 1 1 1 1 1 1
f15 0 1024 	7 0 10 1 236 1	10 0.8 125 0.8 	10 -0.7 180 -0.7 	10 0.5 50 0.5	11 -0.2 600 -0.2 20 0 
f16 0 1024 	5 1 256 1	2 0.8 256 0.8 	2 0.7 100 0.7 	2 0.5 300 0.5 
</CsScore>
</CsoundSynthesizer>
