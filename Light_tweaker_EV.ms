thislightTweakerRoll = LightTweakerRoll
fn calc_light=
(
	EV_Sld = LightTweakerRoll.EV_Sld
	OC_Sld = LightTweakerRoll.OC_Sld
	$Sun.multiplier =(pow 2 (EV_Sld.value))/((OC_Sld.value)*10.0)
	$Sky.mat.multiplier = (pow 2 (EV_Sld.value))/200
	--$Dome.multiplier =(sin((100-OC_Sld.value)/100.0*90) + 1)* ((pow 2 (EV_Sld.value))/((100-OC_Sld.value)*11.0))
	$Dome.multiplier =(pow 2 (EV_Sld.value))/((100-OC_Sld.value)*11.0)
)

fn calc_cam=
(
	EV_Val=(log EV_Cam_Val / log 2)
	--EV_Val = log 2((pow aperture 2)/SSpeed)
)

fn getValues = 
(
	LightTweakerRoll.EV_Sld.value = log ($Sky.mat.multiplier*200) / log 2
	LightTweakerRoll.OC_Sld.value = (pow 2 (LightTweakerRoll.EV_Sld.value))/(($Sun.multiplier)*11.0)
)
fn getEV =
(
	LightTweakerRoll.EV_Sld.value = log ($Sky.mat.multiplier*200) / log 2
)

rollout LightTweakerRoll "parameters" width:232
(
	slider EV_Sld "Exposure" width:220 orient:#horizontal type:#float ticks:1 range:[0.1,19,getEV()] align:#left across:2
	edittext EV_val text:(EV_Sld.value as string) align:#right
	slider OC_Sld "overcast" width:220 orient:#horizontal type:#integer ticks:10 range:[1,100,getValues()] align:#left across:2
	edittext OC_val text:(OC_Sld.value as string) align:#right
	
	on EV_Sld changed val do
	(
		EV_val.text = (EV_Sld.value as string)
		calc_light()
	)
	on OC_Sld changed val do
	(
		OC_val.text = (OC_Sld.value as string)
		calc_light()
	)
	on LightTweakerRoll open do
	(
		getValues()
	)
)
createDialog LightTweakerRoll