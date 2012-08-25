;attack, decay
iatt ctrl7 1, 73, 0.025, 2 			
idec ctrl7 1, 75, 0.01, 1

;on/off
inoise ctrl7 1, 68, 0, 1
isynth ctrl7 1, 69, 1, 0
ibass ctrl7 1, 70, 1, 0 

;waves
iws ctrl7 1, 90, 1, 16
iws2 ctrl7 1, 91, 1, 16
iws3 ctrl7 1, 92, 1, 16
iwlfo ctrl7 1, 93, 1, 16

kpan ctrl7 1, 10, 1, 0
kvol ctrl7 1, 7, 0, 4 
knoisegain ctrl7 1, 74, 0, 1
knoisenote ctrl7 1, 88, 0, 1

;chorusing
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
