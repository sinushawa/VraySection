global objToKeep = #()
global objToCut = #()
global CopyHolder = #()
global matLib
cutSectionRollout

fn textureContainsClass matOrTex classMatoTex =
(
	listOfTexturesOfThisClass=#()
	if (superclassof matOrTex) == Material then
	(
		numberOfMaterialsInside= getNumSubMtls matOrTex
		for i=1 to numberOfMaterialsInside do
		(
			matToCheck=getSubMtl matOrTex i
			if matToCheck!= undefined then
			(
				ToAddToTheResult = textureContainsClass matToCheck classMatoTex
				for j=1 to ToAddToTheResult.Count do
				(
					appendIfunique listOfTexturesOfThisClass ToAddToTheResult[j]
				)
			)
		)
	)
	numberOfTexturesInside= getNumSubTexmaps matOrTex
	for i=1 to numberOfTexturesInside do
	(
		textureToCheck=getSubTexmap matOrTex i
		if textureToCheck!= undefined then
		(
			if (classof textureToCheck) == classMatoTex then
			(
				append listOfTexturesOfThisClass textureToCheck
			)
			else
			(
				ToAddToTheResult = textureContainsClass textureToCheck classMatoTex
				for j=1 to ToAddToTheResult.Count do
				(
					appendIfUnique listOfTexturesOfThisClass ToAddToTheResult[j]
				)
			)
		)
	)
	return listOfTexturesOfThisClass
)

fn RetrieveOpacityMaps matOrTex =
(
	listOfOpacityMaps=#()
	if (superclassof matOrTex) == Material then
	(
		numberOfMaterialsInside= getNumSubMtls matOrTex
		for i=1 to numberOfMaterialsInside do
		(
			matToCheck=getSubMtl matOrTex i
			if matToCheck!= undefined then
			(
				ToAddToTheResult = RetrieveOpacityMaps matToCheck
				for j=1 to ToAddToTheResult.Count do
				(
					appendIfunique listOfOpacityMaps ToAddToTheResult[j]
				)
			)
		)
	)
	appendIfunique listOfOpacityMaps matOrTex.texmap_opacity
	return listOfOpacityMaps
)
fn RetrieveAllMats matOrTex =
(
	listOfMats=#()
	if (superclassof matOrTex) == Material then
	(
		numberOfMaterialsInside= getNumSubMtls matOrTex
		for i=1 to numberOfMaterialsInside do
		(
			matToCheck=getSubMtl matOrTex i
			if matToCheck != undefined then
			(
				ToAddToTheResult = RetrieveAllMats matToCheck
				for j=1 to ToAddToTheResult.Count do
				(
					appendIfunique listOfMats ToAddToTheResult[j]
				)
			)
		)
	)
	if (classof matOrTex) == VRayMtl then
	(
		appendIfunique listOfMats matOrTex
	)
	return listOfMats
)
-- typeToReturn 1 if you want to receive ToKeep   2 if you want cut,  objOrName 1 to return the node 2 to return the node name
fn getObjects typeToReturn objOrName=
(
	listOfVrayDistanceTexKeep=#()
	listOfVrayDistanceTexCut=#()
	ListOfOptions =#()
	for i in selection do
	(
		if i.mat != undefined then
		(
			ToAddToTheResult = textureContainsClass i.mat VrayDistanceTex
			for j=1 to ToAddToTheResult.Count do
			(
				if ToAddToTheResult[j].far_color == white AND ToAddToTheResult[j].near_color == white AND ToAddToTheResult[j].inside_color == black then
				(
					for k in ToAddToTheResult[j].objects do
					(
						appendIfUnique listOfVrayDistanceTexCut k
					)
					appendIfUnique listOfVrayDistanceTexKeep i
				)
			)
		)
	)
	append listOfOptions listOfVrayDistanceTexKeep
	append listOfOptions listOfVrayDistanceTexCut
	listOfTexsToTreat=listOfOptions[typeToReturn]
	listOfObjectsToReturn=#()
	for i in listOfTexsToTreat do
	(
		if objOrName==2 then
		(
			appendIfUnique listOfObjectsToReturn i.name
		)
		else
		(
			appendIfUnique listOfObjectsToReturn i
		)
	)
	return listOfObjectsToReturn
)

fn Init =
(
	matLib=loadTempMaterialLibrary "Section.mat"
	objToKeep = getObjects 1 1
	objToCut = getObjects 2 1
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