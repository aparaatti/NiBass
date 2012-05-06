;
;License: GPLv3 http://www.gnu.org/licenses/gpl-3.0.txt
;
;My first csound synth inteted to be played and controlled
;with midi-keyboard (There is also a versions with csoundqt GUI available to 
;display used waveforms and controller changes). 
;
;I used M-audio AxiumPro49 so if you have one, you know you have enough buttons
;to control this :D. There probaply is stupid mistakes in there, and if you spot
;one I would be happy to become aware of such. So comments are welcome at 
;nikohuma <at> gmail <dot> com.
;
;Niko Humalamäki
;
<CsoundSynthesizer>
<CsInstruments>
sr=96000
ksmps=512
nchnls=2 

massign 1,1

instr 1 

knote cpsmidib 1
iveloc ampmidi 10000
iscale = 0.33 * iveloc
idur = 1

;attack, decay
iatt ctrl7 1, 73, 0.025, 2
idec ctrl7 1, 75, 0.01, 1

;on/off
inoise ctrl7 1, 68, 0, 1
isynth ctrl7 1, 69, 0, 1
;waves
iws ctrl7 1, 90, 1, 4
iws2 ctrl7 1, 91, 1, 4
iws3 ctrl7 1, 92, 1, 4
iwlfo ctrl7 1, 93, 1, 4

kpan ctrl7 1, 10, 1, 0
kvol ctrl7 1, 7, 0, 1
knoisegain ctrl7 1, 74, 0, 1
knoisenote ctrl7 1, 88, 0, 1
;chorus
kchor ctrl7 1, 66, 0, 1

; LFO
kfreq ctrl7 1, 76, 0, 1
klfos ctrl7 1, 65, 0, 1 ;vol lfo depth
kpanon ctrl7 1, 61, 0, 1
kpitch ctrl7 1, 63, 0, 1
kcuttlfo ctrl7 1, 62, 0, 1
kpitchdepth ctrl7 1, 77, 0, 1 ;depth for vol, pan and/or pitch

;LFO/cutt
kcuttdepth ctrl7 1, 78, 0, 127 ;depth for cutt lfo
ksteepness ctrl7 1, 72, 0, 1 ;steepness of the cutt

;not linear:
kchor=1.006^kchor-1
kvol=2^kvol-1
knoisegain=10^knoisegain-1
kfreq = 20^kfreq-1
ksteepness = 100^ksteepness
idec=5^idec-1

;Envelopet:
ak1 linenr	iscale, iatt, idec, 0.1
k1 linenr	iscale, iatt, idec, 0.1

amodu oscil	1, kfreq, iwlfo
kmodu downsamp amodu

if (isynth == 1 ) then
    if (kpitch == 1) then
	a3	oscil	ak1, (knote+amodu*kpitchdepth*10)*(1-kchor),iws2
	a2	oscil	ak1, (knote+amodu*kpitchdepth*10)*(1+kchor),iws3
	a1 	oscil	ak1, (knote+amodu*kpitchdepth*10), iws	
	a1 = a1 + a2 + a3
    else
	a3	oscil	ak1, knote*(1-kchor),iws2
	a2	oscil	ak1, knote*(1+kchor),iws3
	a1 	oscil	ak1, knote, iws	
	a1 = a1 + a2 + a3	
    endif
endif

if (inoise == 1) then ;noise
	ares random 50, 20000
	ares2 random 50, 20000
	ares3 random 50, 20000

	ares areson ares, knote, 128, 2, 0	
	ares2 areson ares2, knote, 128, 2, 0
	ares3 areson ares3, knote, 128, 2, 0
        ares = (ares+ares2+ares3) * 0.33
        
	if (kcuttlfo==0) then
           ares butterbp ares, knote, ksteepness*ksteepness
           ares2 butterbp ares, knote*2, ksteepness*ksteepness
           ares3 butterbp ares, knote*3, ksteepness*ksteepness
           ares = (ares + ares2 + ares3) * 0.33
	endif

        ares=ares*0.0001*knoisegain

        if (isynth == 1) then
           a1 = (1-knoisenote)*a1 + knoisenote*ares*ak1
       	else
	   a1 = ares * ak1
        endif
endif

if (kcuttlfo == 1) then
;                                                     |min=0||neg. when synth on|    |scale noise only-synth|    
	a1 butterbp a1, knote, ksteepness*ksteepness+(kmodu+1-0.5*isynth)*kcuttdepth*(0.05+isynth*2)
endif

;cutt below 50Hz
a1 butterhp a1, 50

; Different output kombinations:
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
f1 0 4096 10	1 ;sine
f2 0 4096 10	1 1 1 .7 .5 .3 .1     ;pulse
f3 0 4096 7	1 4096 -1 ;triangle
f4 0 4096 7	1 2048 1 0 -1 2048 -1 ;square
</CsoundSynthesizer>
