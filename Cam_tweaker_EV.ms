lightCA = attributes lightSystem version:1
(
	fn viewportChange =
	(
		cam=getActiveCamera()
		if cam != undefined AND cam.modifiers["scene lighting"]!= undefined then
		(
			cam.modifiers["scene lighting"].calc_light cam
		)
	)
	parameters main rollout:params
	(
		sun type:#node
		dome type:#node
		sky type:#node
	)
	rollout params "Light System"
	(
		pickbutton sunUI "pick a sun"
		pickbutton domeUI "pick a dome" enabled:false 
		pickbutton skyUI "pick a sky" enabled:false 
		
		on sunUI picked obj do
		(
			sun = obj
			sunUI.text= obj.name
			domeUI.enabled=true
		)
		on domeUI picked obj do
		(
			dome = obj
			domeUI.text= obj.name
			skyUI.enabled=true
		)
		on skyUI picked obj do
		(
			sky = obj
			skyUI.text= obj.name
			DestroyDialog params
		)
	)
)

viewCA= attributes lightData version:1
(
	fn calc_light cam=
	(
		if cam.modifiers["scene lighting"].enabled == true then
		(
			EV=cam.modifiers["scene lighting"].EV
			OC=cam.modifiers["scene lighting"].OC
			offset=cam.modifiers["scene lighting"].sky_offset
			sun=rootNode.custAttributes["lightSystem"].sun
			dome=rootNode.custAttributes["lightSystem"].dome
			sky=rootNode.custAttributes["lightSystem"].sky
			sun.multiplier =(pow 2 (EV))/((OC)*10.0)
			dome.multiplier =(pow 2 (EV))/((100-OC)*10.0)
			sky.mat.multiplier = (log(((pow 2 (EV+offset))/((100-OC)*10.0))) +((EV+offset)/12)) *EV
			sky.mat.texmap.opacity[2] = (EV - 5) *100.0f
			if cam.modifiers["scene lighting"].sun_position_keep == true then
			(
				sun.pos = cam.modifiers["scene lighting"].sun_position
			)
		)
	)
	
	
	parameters main rollout:params
	(
		EV type:#float ui:EVUI default:12
		OC type:#float ui:OCUI default:50
		sky_offset type:#float ui:SOUI default:0
		sun_position_keep type:#boolean ui:SPKUI default:false
		sun_position type:#point3
	)
	fn SPKUI_text =
	(
		result=""
		if selection[1].modifiers["scene lighting"].sun_position_keep ==true then
		(
			result = "sun position saved"
		)
		else
		(
			result = "save sun position"
		)
		return result
	)
 
	rollout params "Light Parameters"
	(
		spinner EVUI "Exposure Value" type: #float
		spinner OCUI "Overcast" type: #float
		spinner SOUI "Sky offset" type: #float range:[-24,24,0]
		checkbutton SPKUI "save sun position"
		 
		on EVUI changed val do
		(
			calc_light selection[1]
		)
		on OCUI changed val do
		(
			calc_light selection[1]
		)
		on SOUI changed val do
		(
			calc_light selection[1]
		)
		on SPKUI changed state do
		(
			if state == on then
			(
				sun_position = lightSystem.sun.pos
				SPKUI.text = "sun position saved"
			)
			else
			(
				SPKUI.text = "save sun position"
			)
		)
		on params open do 
		(
			SPKUI.text =SPKUI_text()
		)
	)
)
fn getValues = 
(
	EV_val=1.4427* (log((1000.0*$Dome.multiplier*$Sun.multiplier)/($Dome.multiplier+$Sun.multiplier)))
	OC_val = (pow 2 (LightTweakerRoll.EV_Sld.value))/(($Sun.multiplier)*10.0)
)
fn addLightSysModifier =
(
	if (rootNode.custAttributes["lightSystem"] == undefined) then
	(
		custAttributes.add rootNode lightCA
		createDialog rootNode.custAttributes["lightSystem"].params
	)
	if (superclassof selection[1]) == camera then
	(
		viewLight = EmptyModifier()
		viewLight.name= "scene lighting"
		addModifier selection[1] viewLight
		custAttributes.add selection[1].modifiers["scene lighting"] viewCA
		try
		(
			callbacks.addScript #viewportChange "cam=getActiveCamera() \n if cam != undefined AND cam.modifiers[\"scene lighting\"]!= undefined then (cam.modifiers[\"scene lighting\"].calc_light cam)" id:#CTEV persistent:true
		)
		catch
		(
			print "callback not added"
		)
	)
)

addLightSysModifier()