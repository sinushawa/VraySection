struct Sections (ToKeep, Cutter, ToCap, IsEnabled)
persistent global sectionHolder
global objToKeep = #()
global objToCut = #()
global CopyHolder = #()
global matLib
cutSectionRollout

fn Init =
(
	matLib=loadTempMaterialLibrary "Section.mat"
)
fn ComboBoxFill =
(
	listSections=#()
	for i=1 to sectionHolder.Count do
	(
		nameS = "section"+(i as string)
		append listSections nameS
	)
	return listSections
)
fn UIRefresh =
(
	cutSectionRollout.objectToKeepUI.Items=(for o in objToKeep  collect o.name)
	cutSectionRollout.cutterUI.Items=(for o in objToCut  collect o.name)
)

fn applyMaps =
(
	
	toKeepmap = matLib[1]
	toKeepmap.objects=objToCut
	
		
	for i in objToKeep do
	(
		if (classof i.mat) == VrayBlendMtl AND i.mat.texmap_blend[1]==VrayDistanceTex then
		(
				i.mat.texmap_blend[1].objects=objToCut
		)
		else
		(
			oldMat= i.mat
			
			newMat = VrayBlendMtl()
			newMat.coatMtl[1] = oldMat
			newMat.Blend[1] = black
			newMat.texmap_blend[1]=toKeepmap
			i.mat = newMat
		)
	)
	/*
	*/
	toCutmap = matLib[2]
	toCutmap.objects=CopyHolder
	for i in objToCut do
	(
		if (classof i.mat) == VrayBlendMtl AND i.mat.texmap_blend[1]==VrayDistanceTex then
		(
				i.mat.texmap_blend[1].objects=CopyHolder
		)
		else
		(
			oldMat= i.mat
			
			newMat = VrayBlendMtl()
			newMat.coatMtl[1] = oldMat
			newMat.Blend[1] = black
			newMat.texmap_blend[1]=toCutmap
			i.mat = newMat
		)
	)
)
fn CheckObjects objectsToCheck =
(
	error = false
	errorObjects=#()
	errormesage=""
	ListOfObjectsToReturn=#()
	for i in objectsToCheck do
	(
		if (superclassof i) == GeometryClass AND i.mat != undefined then
		(
			append ListOfObjectsToReturn i
		)
		else 
		(
			if(superclassof i) == helper then
			(
				for j in i do
				(
					if (j!= i) then
					(
						ToAdd=#()
						ToAdd = CheckObjects j
						for k in ToAdd do
						(
							appendIfUnique ListOfObjectsToReturn k
						)
					)
				)
			)
			else
			(
			)
		)
	)
	return ListOfObjectsToReturn
)


rollout cutSectionRollout "Cut Section" width:250 height:380
(	
	listbox SectionUI items:ComboBoxFill()
	listbox objectToKeepUI "objects to cut"
	button addToKeepUI "add" across:2
	button removeToKeepUI "remove"
	listbox cutterUI "cutter"
	button addCutterUI "add" across:2
	button removeCutterUI "remove"
	
	on cutSectionRollout open do
	(
		Init()
		UIRefresh()
	)
	
	on addToKeepUI pressed do
	(
		objToKeepAdd = selectByName title:"Select Objects to cut" buttonText:"Select" showHidden:false single:false
		if objToKeepAdd != undefined then
		(
			objToKeepAdd = CheckObjects objToKeepAdd
			for i in objToKeepAdd do
			(
				appendIfUnique objToKeep i
				theResults = #()
				resultType = openEdges.Check currentTime i &theResults
				theResults as bitarray
				if theResults.count<1 then
				(
					objToAdd = snapshot i
					objToAdd.mat = undefined
					hide objToAdd
					append CopyHolder objToAdd
				)
			)
			UIRefresh()
			applyMaps()
		)
	)
	on removeToKeepUI pressed do
	(
		id=objectToKeepUI.selection
		deleteItem objToKeep id
		deleteItem CopyHolder id
		UIRefresh()
		applyMaps()
	)
	
	on addCutterUI pressed do
	(
		objToCutAdd = selectByName title:"Select Cutter" buttonText:"Select" showHidden:false single:false
		if objToCutAdd != undefined then
		(
			objToCutAdd = CheckObjects objToCutAdd
			for i in objToCutAdd do
			(
				appendIfUnique objToCut i
			)
			UIRefresh()
			applyMaps()
		)
	)
	on removeCutterUI pressed do
	(
		id=cutterUI.selection
		deleteItem objToCut id
		UIRefresh()
		applyMaps()
	)
)
CreateDialog cutSectionRollout