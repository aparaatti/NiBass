;
;License: GPLv3 http://www.gnu.org/licenses/gpl-3.0.txt
;
;Csoundqt version of a csound synth inteted to be played and controlled 
;with midi-keyboard, has GUI for displaying stuff (also a version comming 
;that uses GUI controllers to control). 
;
;I used M-audio AxiomPro49 so if you have one, you know you have enough buttons
;to control this :D. There probaply is mistakes in there, and if you spot
;one I would be happy to become aware of such. So comments are welcome at 
;nikohuma <at> gmail <dot> com.
;
;thanks to rgareus @ LAD for pointing stuff out
<CsInstruments>
sr=96000
kr=9600
ksmps=10

nchnls=2

massign 1,1

instr 1
#include "midibindingsQt.asc"
#include "guibindings.asc"
 
knote cpsmidib 1
iveloc ampmidi 10000
iscale = 0.33 * iveloc
idur = 1

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

if( inoise==0 && isynth==0) then
	isynth=1
endif

amodu oscil	1, kfreq, iwlfo
kmodu downsamp amodu

;adjust vol to 400Hz sine
a440   oscili   ak1, 69, 1

;if synth on or noise off --> synth
if ( isynth == 1 ) then
    if (kpitch == 1) then
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
if ( inoise == 1 ) then
    inoise = 1
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
;f14 0 0 23 "/home/aparaatti/Desktop/Dropbox/Audio/Set-up/aalto.txt"
</CsScore>
</CsoundSynthesizer>














<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>791</x>
 <y>78</y>
 <width>432</width>
 <height>537</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>48</r>
  <g>48</g>
  <b>48</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>1</x>
  <y>40</y>
  <width>431</width>
  <height>333</height>
  <uuid>{c16ccdce-579c-4000-937e-5a278fe3341c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Synth</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>22</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>88</r>
   <g>88</g>
   <b>88</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>199</x>
  <y>45</y>
  <width>225</width>
  <height>157</height>
  <uuid>{08f36f53-4f97-4000-afcb-8e9ae97f90ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>LFO</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>192</g>
   <b>192</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>312</x>
  <y>161</y>
  <width>107</width>
  <height>35</height>
  <uuid>{9ddf771f-c619-4000-b028-b85f32d984d3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>    Cutt 
steepness</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>140</x>
  <y>50</y>
  <width>56</width>
  <height>41</height>
  <uuid>{e22b212d-d34c-4000-a3fa-38093f19d6ba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>note on/off</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>116</x>
  <y>163</y>
  <width>55</width>
  <height>53</height>
  <uuid>{ba28cc83-3321-483e-aacd-c18d1537e3db}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>note-noise</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>knoisenote</objectName>
  <x>126</x>
  <y>189</y>
  <width>36</width>
  <height>21</height>
  <uuid>{45ed5dae-04ef-4000-9809-167555d8a7e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>168</g>
   <b>88</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>22</x>
  <y>84</y>
  <width>29</width>
  <height>23</height>
  <uuid>{d30ba53d-d714-4000-b1e0-715035ee13ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>vol synth</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>115</y>
  <width>66</width>
  <height>32</height>
  <uuid>{8290a437-094f-4000-b96a-3b137c33afba}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>pan:</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>idec</objectName>
  <x>86</x>
  <y>53</y>
  <width>69</width>
  <height>40</height>
  <uuid>{a3128809-8a4f-4000-9dcb-5da9af7def76}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>1.91526112</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>katt</objectName>
  <x>44</x>
  <y>53</y>
  <width>69</width>
  <height>40</height>
  <uuid>{af2c9ed5-5cf5-4000-9d94-d437dd84114a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>3.00000000</maximum>
  <value>0.02500000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>75</x>
  <y>115</y>
  <width>81</width>
  <height>32</height>
  <uuid>{f0f349d1-3172-4000-8a32-91788ce19768}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>chorus:</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>106</x>
  <y>89</y>
  <width>30</width>
  <height>22</height>
  <uuid>{824efd91-51ce-4000-b5b7-cbd87ce5f063}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>dec</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>64</x>
  <y>89</y>
  <width>30</width>
  <height>22</height>
  <uuid>{63d97ffe-fc58-4000-b892-ebcd6adcd130}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>att</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>kvol</objectName>
  <x>9</x>
  <y>71</y>
  <width>22</width>
  <height>40</height>
  <uuid>{20544dae-e2c9-4000-a9e6-741e67b0748e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>7</midicc>
  <minimum>0.00000000</minimum>
  <maximum>4.00000000</maximum>
  <value>1.57480315</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBGraph">
  <objectName>iws3</objectName>
  <x>285</x>
  <y>246</y>
  <width>135</width>
  <height>120</height>
  <uuid>{78dd4234-0133-4000-afe6-21e93c214e41}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>0</value>
  <objectName2>iws3</objectName2>
  <zoomx>1.00000000</zoomx>
  <zoomy>0.20000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBGraph">
  <objectName>iws2</objectName>
  <x>150</x>
  <y>247</y>
  <width>135</width>
  <height>120</height>
  <uuid>{d88ced77-e341-4000-8d75-02d8c9d327f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>0</value>
  <objectName2>iws2</objectName2>
  <zoomx>1.00000000</zoomx>
  <zoomy>0.20000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBGraph">
  <objectName>iws</objectName>
  <x>12</x>
  <y>247</y>
  <width>135</width>
  <height>120</height>
  <uuid>{4da98e78-dc99-4000-9385-14023b00f007}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>0</value>
  <objectName2>iws</objectName2>
  <zoomx>1.00000000</zoomx>
  <zoomy>0.20000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <all>true</all>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kfreq</objectName>
  <x>208</x>
  <y>95</y>
  <width>60</width>
  <height>30</height>
  <uuid>{942ad402-00ed-4000-a084-699ff04a895c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>ksteepness</objectName>
  <x>368</x>
  <y>166</y>
  <width>44</width>
  <height>25</height>
  <uuid>{6487b7ea-7d65-4000-a685-40596fec37e0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>left</alignment>
  <font>DejaVu Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>168</g>
   <b>88</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>7</x>
  <y>149</y>
  <width>86</width>
  <height>96</height>
  <uuid>{71b02d96-8336-4000-bdf2-ffb27e2f06c5}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Noise</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>20</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>192</r>
   <g>255</g>
   <b>192</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>knoise</objectName>
  <x>68</x>
  <y>155</y>
  <width>18</width>
  <height>22</height>
  <uuid>{ba102dcb-a756-4000-8b7a-cdd503f574bc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>ksynth</objectName>
  <x>160</x>
  <y>66</y>
  <width>18</width>
  <height>22</height>
  <uuid>{e28e6178-cf09-4000-9ce4-7358c5fab20c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>59</x>
  <y>166</y>
  <width>34</width>
  <height>23</height>
  <uuid>{088db6ea-38e8-4000-9a21-9884351c2ed2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>on/off</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>knoisegain</objectName>
  <x>35</x>
  <y>185</y>
  <width>30</width>
  <height>35</height>
  <uuid>{7307b39b-6578-4000-9f3c-b5899d275c47}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>knoisegain</objectName>
  <x>18</x>
  <y>217</y>
  <width>31</width>
  <height>21</height>
  <uuid>{96c3d38c-56d2-4000-ad7c-6520ad9fbad6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>219</x>
  <y>147</y>
  <width>73</width>
  <height>59</height>
  <uuid>{31a72869-469c-4000-b3e2-42eaf2947531}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0 sine, 1 trig, 2 bi-sq, 3 u-sq, 4 saw, 5 saw-down</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>342</x>
  <y>98</y>
  <width>31</width>
  <height>23</height>
  <uuid>{939121b4-1431-4000-93b1-9e472f3fd4c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Vol</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>387</x>
  <y>98</y>
  <width>30</width>
  <height>23</height>
  <uuid>{4fd8c94a-a7cd-4000-8c1c-835f469a1863}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Pan</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>kpanon</objectName>
  <x>393</x>
  <y>80</y>
  <width>20</width>
  <height>20</height>
  <uuid>{bf0bf516-eb42-4000-a1a4-50dab897cc49}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>klfos</objectName>
  <x>347</x>
  <y>80</y>
  <width>20</width>
  <height>20</height>
  <uuid>{d0b2c33a-97f8-4000-849d-afcc3f26f8f1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>kpitch</objectName>
  <x>370</x>
  <y>80</y>
  <width>20</width>
  <height>20</height>
  <uuid>{007c4098-6018-4000-a55c-0f97543db284}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>361</x>
  <y>98</y>
  <width>34</width>
  <height>23</height>
  <uuid>{55de84ce-fe8b-4000-b636-06e630d510d7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>Pitch</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>kpitchdepth</objectName>
  <x>311</x>
  <y>81</y>
  <width>34</width>
  <height>30</height>
  <uuid>{6456a640-22fa-4000-a879-2132ccda286a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBKnob">
  <objectName>kcuttdepth</objectName>
  <x>320</x>
  <y>120</y>
  <width>22</width>
  <height>29</height>
  <uuid>{cba8b20e-7dcf-4000-aa7d-f5bfe147fe6a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1000.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>0.01000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>344</x>
  <y>137</y>
  <width>34</width>
  <height>23</height>
  <uuid>{b74fbc18-c432-4000-b095-2da0e8069432}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Cutt</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>kcuttlfo</objectName>
  <x>347</x>
  <y>125</y>
  <width>20</width>
  <height>20</height>
  <uuid>{5ebde300-b00c-4000-a919-2caf1a171cc6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>false</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBScope">
  <objectName/>
  <x>50</x>
  <y>377</y>
  <width>347</width>
  <height>160</height>
  <uuid>{08f85d85-04dc-4dbb-b9b9-3416ba552f24}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <value>-255.00000000</value>
  <type>scope</type>
  <zoomx>1.00000000</zoomx>
  <zoomy>7.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <mode>0.00000000</mode>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>258</x>
  <y>95</y>
  <width>33</width>
  <height>29</height>
  <uuid>{21a08780-9855-49a8-b3e1-8809cf105a37}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Hz</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>52</x>
  <y>217</y>
  <width>29</width>
  <height>23</height>
  <uuid>{63fd788c-ab34-4684-9ac9-ba5307469f55}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <label>vol synth</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>kpan</objectName>
  <x>33</x>
  <y>119</y>
  <width>35</width>
  <height>22</height>
  <uuid>{fadec2d5-43db-43f8-9a34-7af6ec219b46}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.496</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>168</g>
   <b>88</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>ichor</objectName>
  <x>113</x>
  <y>119</y>
  <width>39</width>
  <height>22</height>
  <uuid>{28e7f505-0130-42dd-8af4-1d7002d6df49}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>0.000</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>168</g>
   <b>88</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>300</x>
  <y>57</y>
  <width>45</width>
  <height>22</height>
  <uuid>{a9169124-d5f2-4f94-85c9-b36d7a1967a2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Depth:</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>12</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>201</x>
  <y>74</y>
  <width>57</width>
  <height>28</height>
  <uuid>{db39fbfe-0c5d-464e-b2d6-4604f08ce6b4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Rate:</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>201</x>
  <y>126</y>
  <width>57</width>
  <height>28</height>
  <uuid>{4d711e95-3445-45e0-a723-25d2064622ad}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Wave:</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>iwlfo</objectName>
  <x>251</x>
  <y>127</y>
  <width>60</width>
  <height>30</height>
  <uuid>{44d2ae82-e4af-45e4-924b-7663ae30ec45}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>1.000</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>18</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>168</x>
  <y>3</y>
  <width>85</width>
  <height>33</height>
  <uuid>{169010a5-5d52-48e2-8710-46930a80376e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>NiBass</label>
  <alignment>center</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>25</fontsize>
  <precision>3</precision>
  <color>
   <r>192</r>
   <g>255</g>
   <b>192</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBCheckBox">
  <objectName>kbass</objectName>
  <x>160</x>
  <y>104</y>
  <width>20</width>
  <height>20</height>
  <uuid>{96f8bd84-5781-4287-ba33-9dd94a710a5b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <selected>true</selected>
  <label/>
  <pressedValue>1</pressedValue>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>125</x>
  <y>89</y>
  <width>80</width>
  <height>41</height>
  <uuid>{c688026d-56d4-4ddb-ba6f-19af3d54cddb}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>low freq no dec</label>
  <alignment>left</alignment>
  <font>Nimbus Sans L</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
<preset name="nice ambient" number="0" >
<value id="{a3128809-8a4f-4000-9dcb-5da9af7def76}" mode="1" >2.67716527</value>
<value id="{af2c9ed5-5cf5-4000-9d94-d437dd84114a}" mode="1" >0.00000000</value>
<value id="{995d5216-76ee-4000-bdce-766c77304dff}" mode="1" >1.89066935</value>
<value id="{2657fe41-2568-4000-b633-a2c97e317778}" mode="1" >6000.00000000</value>
<value id="{ce6edd8a-567c-4000-8bd1-53a68b6e3819}" mode="1" >330.70849609</value>
<value id="{0c3fdca0-2331-4000-a4fc-8bafc3223324}" mode="1" >3.07086635</value>
<value id="{39439e64-836c-4000-9b0e-31d40cbe22ec}" mode="1" >121.00000000</value>
<value id="{fe8ca78d-b06e-4000-b968-071846e39c9d}" mode="1" >0.46956521</value>
<value id="{20544dae-e2c9-4000-a9e6-741e67b0748e}" mode="1" >2.00000000</value>
<value id="{bd59eb5e-b43a-4000-93ec-ca91190e19b7}" mode="1" >0.00021827</value>
<value id="{78dd4234-0133-4000-afe6-21e93c214e41}" mode="1" >0.00000000</value>
<value id="{d88ced77-e341-4000-8d75-02d8c9d327f9}" mode="1" >0.00000000</value>
<value id="{4da98e78-dc99-4000-9385-14023b00f007}" mode="1" >0.00000000</value>
<value id="{942ad402-00ed-4000-a084-699ff04a895c}" mode="1" >1.89066935</value>
<value id="{942ad402-00ed-4000-a084-699ff04a895c}" mode="4" >1.891</value>
<value id="{598bfc19-1c02-4000-9d42-c8f13a1a272c}" mode="1" >6000.00000000</value>
<value id="{598bfc19-1c02-4000-9d42-c8f13a1a272c}" mode="4" >6000.000</value>
<value id="{0130efb2-2e18-4000-9194-d0f9f9979bce}" mode="1" >330.70849609</value>
<value id="{0130efb2-2e18-4000-9194-d0f9f9979bce}" mode="4" >330.708</value>
<value id="{6487b7ea-7d65-4000-a685-40596fec37e0}" mode="1" >3.07086635</value>
<value id="{6487b7ea-7d65-4000-a685-40596fec37e0}" mode="4" >3.071</value>
<value id="{0d9b79cc-d9a8-4000-bd5f-1e00a44b3c99}" mode="1" >121.00000000</value>
<value id="{0d9b79cc-d9a8-4000-bd5f-1e00a44b3c99}" mode="4" >121.000</value>
<value id="{ba102dcb-a756-4000-8b7a-cdd503f574bc}" mode="1" >1.00000000</value>
<value id="{e28e6178-cf09-4000-9ce4-7358c5fab20c}" mode="1" >1.00000000</value>
<value id="{3ace2fa3-6b62-4000-94ee-aab1e3d128cd}" mode="1" >0.71653545</value>
<value id="{45ed5dae-04ef-4000-9809-167555d8a7e1}" mode="1" >0.71653545</value>
<value id="{45ed5dae-04ef-4000-9809-167555d8a7e1}" mode="4" >0.717</value>
<value id="{7307b39b-6578-4000-9f3c-b5899d275c47}" mode="1" >800.00000000</value>
<value id="{96c3d38c-56d2-4000-ad7c-6520ad9fbad6}" mode="1" >800.00000000</value>
<value id="{96c3d38c-56d2-4000-ad7c-6520ad9fbad6}" mode="4" >800.000</value>
<value id="{a6b3f6f4-8bc3-4000-8610-024a7c8cf691}" mode="1" >4.00000000</value>
<value id="{bf0bf516-eb42-4000-a1a4-50dab897cc49}" mode="1" >0.00000000</value>
<value id="{d0b2c33a-97f8-4000-849d-afcc3f26f8f1}" mode="1" >0.00000000</value>
<value id="{007c4098-6018-4000-a55c-0f97543db284}" mode="1" >0.00000000</value>
<value id="{6456a640-22fa-4000-a879-2132ccda286a}" mode="1" >0.00000000</value>
<value id="{cba8b20e-7dcf-4000-aa7d-f5bfe147fe6a}" mode="1" >108.36000061</value>
<value id="{5ebde300-b00c-4000-a919-2caf1a171cc6}" mode="1" >1.00000000</value>
<value id="{d5deda62-cb09-4000-8a60-44573a4b2ec1}" mode="1" >1.89066935</value>
<value id="{712f1eb6-0307-4000-b9b6-a550f5fee0c2}" mode="1" >30.00000000</value>
<value id="{712f1eb6-0307-4000-b9b6-a550f5fee0c2}" mode="4" >30.000</value>
<value id="{3f508fc5-d1db-4000-8713-8ae043361724}" mode="1" >30.00000000</value>
</preset>
<preset name="saha" number="1" >
<value id="{a3128809-8a4f-4000-9dcb-5da9af7def76}" mode="1" >2.71653533</value>
<value id="{af2c9ed5-5cf5-4000-9d94-d437dd84114a}" mode="1" >0.00000000</value>
<value id="{995d5216-76ee-4000-bdce-766c77304dff}" mode="1" >20.00000000</value>
<value id="{2657fe41-2568-4000-b633-a2c97e317778}" mode="1" >5858.26757812</value>
<value id="{ce6edd8a-567c-4000-8bd1-53a68b6e3819}" mode="1" >377.95312500</value>
<value id="{0c3fdca0-2331-4000-a4fc-8bafc3223324}" mode="1" >3.30708671</value>
<value id="{39439e64-836c-4000-9b0e-31d40cbe22ec}" mode="1" >122.00000000</value>
<value id="{fe8ca78d-b06e-4000-b968-071846e39c9d}" mode="1" >0.46956521</value>
<value id="{20544dae-e2c9-4000-a9e6-741e67b0748e}" mode="1" >2.33070874</value>
<value id="{bd59eb5e-b43a-4000-93ec-ca91190e19b7}" mode="1" >0.00042661</value>
<value id="{78dd4234-0133-4000-afe6-21e93c214e41}" mode="1" >0.00000000</value>
<value id="{d88ced77-e341-4000-8d75-02d8c9d327f9}" mode="1" >8.00000000</value>
<value id="{4da98e78-dc99-4000-9385-14023b00f007}" mode="1" >0.00000000</value>
<value id="{942ad402-00ed-4000-a084-699ff04a895c}" mode="1" >20.00000000</value>
<value id="{942ad402-00ed-4000-a084-699ff04a895c}" mode="4" >20.000</value>
<value id="{598bfc19-1c02-4000-9d42-c8f13a1a272c}" mode="1" >5858.26757812</value>
<value id="{598bfc19-1c02-4000-9d42-c8f13a1a272c}" mode="4" >5858.268</value>
<value id="{0130efb2-2e18-4000-9194-d0f9f9979bce}" mode="1" >377.95312500</value>
<value id="{0130efb2-2e18-4000-9194-d0f9f9979bce}" mode="4" >377.953</value>
<value id="{6487b7ea-7d65-4000-a685-40596fec37e0}" mode="1" >3.30708671</value>
<value id="{6487b7ea-7d65-4000-a685-40596fec37e0}" mode="4" >3.307</value>
<value id="{0d9b79cc-d9a8-4000-bd5f-1e00a44b3c99}" mode="1" >122.00000000</value>
<value id="{0d9b79cc-d9a8-4000-bd5f-1e00a44b3c99}" mode="4" >122.000</value>
<value id="{ba102dcb-a756-4000-8b7a-cdd503f574bc}" mode="1" >0.00000000</value>
<value id="{e28e6178-cf09-4000-9ce4-7358c5fab20c}" mode="1" >0.00000000</value>
<value id="{3ace2fa3-6b62-4000-94ee-aab1e3d128cd}" mode="1" >0.83464569</value>
<value id="{45ed5dae-04ef-4000-9809-167555d8a7e1}" mode="1" >0.83464569</value>
<value id="{45ed5dae-04ef-4000-9809-167555d8a7e1}" mode="4" >0.835</value>
<value id="{7307b39b-6578-4000-9f3c-b5899d275c47}" mode="1" >460.26770020</value>
<value id="{96c3d38c-56d2-4000-ad7c-6520ad9fbad6}" mode="1" >460.26770020</value>
<value id="{96c3d38c-56d2-4000-ad7c-6520ad9fbad6}" mode="4" >460.268</value>
<value id="{a6b3f6f4-8bc3-4000-8610-024a7c8cf691}" mode="1" >4.00000000</value>
<value id="{bf0bf516-eb42-4000-a1a4-50dab897cc49}" mode="1" >0.00000000</value>
<value id="{d0b2c33a-97f8-4000-849d-afcc3f26f8f1}" mode="1" >0.00000000</value>
<value id="{007c4098-6018-4000-a55c-0f97543db284}" mode="1" >1.00000000</value>
<value id="{6456a640-22fa-4000-a879-2132ccda286a}" mode="1" >10.00000000</value>
<value id="{cba8b20e-7dcf-4000-aa7d-f5bfe147fe6a}" mode="1" >108.36000061</value>
<value id="{5ebde300-b00c-4000-a919-2caf1a171cc6}" mode="1" >0.00000000</value>
<value id="{d5deda62-cb09-4000-8a60-44573a4b2ec1}" mode="1" >20.00000000</value>
<value id="{712f1eb6-0307-4000-b9b6-a550f5fee0c2}" mode="1" >30.00000000</value>
<value id="{712f1eb6-0307-4000-b9b6-a550f5fee0c2}" mode="4" >30.000</value>
<value id="{3f508fc5-d1db-4000-8713-8ae043361724}" mode="1" >30.00000000</value>
</preset>
<preset name="Evilbass" number="3" >
<value id="{a3128809-8a4f-4000-9dcb-5da9af7def76}" mode="1" >0.63079530</value>
<value id="{af2c9ed5-5cf5-4000-9d94-d437dd84114a}" mode="1" >0.00100000</value>
<value id="{fe8ca78d-b06e-4000-b968-071846e39c9d}" mode="1" >0.62608695</value>
<value id="{20544dae-e2c9-4000-a9e6-741e67b0748e}" mode="1" >0.85039371</value>
<value id="{bd59eb5e-b43a-4000-93ec-ca91190e19b7}" mode="1" >0.00001000</value>
<value id="{78dd4234-0133-4000-afe6-21e93c214e41}" mode="1" >1.00000000</value>
<value id="{d88ced77-e341-4000-8d75-02d8c9d327f9}" mode="1" >7.00000000</value>
<value id="{4da98e78-dc99-4000-9385-14023b00f007}" mode="1" >2.00000000</value>
<value id="{942ad402-00ed-4000-a084-699ff04a895c}" mode="1" >0.00100000</value>
<value id="{942ad402-00ed-4000-a084-699ff04a895c}" mode="4" >0.001</value>
<value id="{598bfc19-1c02-4000-9d42-c8f13a1a272c}" mode="1" >6000.00000000</value>
<value id="{598bfc19-1c02-4000-9d42-c8f13a1a272c}" mode="4" >6000.000</value>
<value id="{0130efb2-2e18-4000-9194-d0f9f9979bce}" mode="1" >6000.00000000</value>
<value id="{0130efb2-2e18-4000-9194-d0f9f9979bce}" mode="4" >6000.000</value>
<value id="{6487b7ea-7d65-4000-a685-40596fec37e0}" mode="1" >3.30708671</value>
<value id="{6487b7ea-7d65-4000-a685-40596fec37e0}" mode="4" >3.307</value>
<value id="{0d9b79cc-d9a8-4000-bd5f-1e00a44b3c99}" mode="1" >127.00000000</value>
<value id="{0d9b79cc-d9a8-4000-bd5f-1e00a44b3c99}" mode="4" >127.000</value>
<value id="{ba102dcb-a756-4000-8b7a-cdd503f574bc}" mode="1" >1.00000000</value>
<value id="{e28e6178-cf09-4000-9ce4-7358c5fab20c}" mode="1" >1.00000000</value>
<value id="{3ace2fa3-6b62-4000-94ee-aab1e3d128cd}" mode="1" >0.58267719</value>
<value id="{45ed5dae-04ef-4000-9809-167555d8a7e1}" mode="1" >0.58267719</value>
<value id="{45ed5dae-04ef-4000-9809-167555d8a7e1}" mode="4" >0.583</value>
<value id="{7307b39b-6578-4000-9f3c-b5899d275c47}" mode="1" >309.27557373</value>
<value id="{96c3d38c-56d2-4000-ad7c-6520ad9fbad6}" mode="1" >309.27557373</value>
<value id="{96c3d38c-56d2-4000-ad7c-6520ad9fbad6}" mode="4" >309.276</value>
<value id="{a6b3f6f4-8bc3-4000-8610-024a7c8cf691}" mode="1" >0.00000000</value>
<value id="{bf0bf516-eb42-4000-a1a4-50dab897cc49}" mode="1" >0.00000000</value>
<value id="{d0b2c33a-97f8-4000-849d-afcc3f26f8f1}" mode="1" >0.00000000</value>
<value id="{007c4098-6018-4000-a55c-0f97543db284}" mode="1" >0.00000000</value>
<value id="{6456a640-22fa-4000-a879-2132ccda286a}" mode="1" >0.80314958</value>
<value id="{cba8b20e-7dcf-4000-aa7d-f5bfe147fe6a}" mode="1" >108.36000061</value>
<value id="{5ebde300-b00c-4000-a919-2caf1a171cc6}" mode="1" >0.00000000</value>
<value id="{712f1eb6-0307-4000-b9b6-a550f5fee0c2}" mode="1" >30.00000000</value>
<value id="{712f1eb6-0307-4000-b9b6-a550f5fee0c2}" mode="4" >30.000</value>
<value id="{08f85d85-04dc-4dbb-b9b9-3416ba552f24}" mode="1" >-255.00000000</value>
<value id="{181851cb-81a2-418e-bc46-81b2eeada56c}" mode="1" >6.61399984</value>
<value id="{181851cb-81a2-418e-bc46-81b2eeada56c}" mode="4" >6.614</value>
<value id="{db46d5ea-b962-4f5e-86ab-75670ed14444}" mode="1" >-255.00000000</value>
</preset>
</bsbPresets>
