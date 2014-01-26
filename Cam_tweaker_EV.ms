struct lightSystem_struct (sun, dome, sky)

persistent global lightSystem

viewCA= attributes lightData version:1
(
	fn calc_light cam=
	(
		if cam.modifiers["scene lighting"].enabled == true then
		(
			EV=cam.modifiers["scene lighting"].EV
			OC=cam.modifiers["scene lighting"].OC
			sun=lightSystem.sun
			dome=lightSystem.dome
			sky=lightSystem.sky
			sun.multiplier =(pow 2 (EV))/((OC)*10.0)
			dome.multiplier =(pow 2 (EV))/((100-OC)*10.0)
			sky.mat.multiplier = (log(((pow 2 (EV))/((100-OC)*10.0))) +(EV/12)) *EV
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
		spinner SOUI "Sky offset" type: #float
		checkbutton SPKUI "save sun position"
		 
		on EVUI changed val do
		(
			calc_light selection[1]
		)
		on OCUI changed val do
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

fn viewportChange =
(
	cam=getActiveCamera()
	if cam != undefined AND cam.modifiers["scene lighting"]!= undefined then
	(
		cam.modifiers["scene lighting"].calc_light cam
	)
)
fn selected_cam ev nd = 
(
	node_sel =GetAnimByHandle nd[nd.count]
)
rollout lightSystemRollout "global light parameters" width:180 height:110
(
	pickbutton sunUI "pick a sun"
	pickbutton domeUI "pick a dome"
	pickbutton skyUI "pick a sky"
	
	on sunUI picked obj do
	(
		lightSystem.sun = obj
		sunUI.text= obj.name
	)
	on domeUI picked obj do
	(
		lightSystem.dome = obj
		domeUI.text= obj.name
	)
	on skyUI picked obj do
	(
		lightSystem.sky = obj
		skyUI.text= obj.name
	)
)
if (superclassof selection[1]) == camera then
(
	viewLight = EmptyModifier()
	viewLight.name= "scene lighting"
	addModifier selection[1] viewLight
	custAttributes.add selection[1].modifiers["scene lighting"] viewCA
	if lightSystem == undefined OR (isDeleted lightSystem.sun) OR isDeleted (lightSystem.dome) OR (isDeleted lightSystem.sky) then
	(
		lightSystem = lightSystem_struct sun:undefined dome:undefined sky:undefined
		CreateDialog lightSystemRollout
	)
	try
	(
		callbacks.addScript #viewportChange "viewportChange()" id:#CTEV persistent:true
		-- unhealthy to have light changing at every camera selection?
		callbackItem = NodeEventCallback selectionChanged:selected_cam
	)
	catch
	(
		print "callback not added"
	)
)