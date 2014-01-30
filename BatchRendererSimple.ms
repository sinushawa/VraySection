fn camera_filt obj = superclassof obj == camera

persistent global BRS_baseName
persistent global BRS_path_name
persistent global BRS_cams

fn UpdatePP =
(
	scripts=getClassInstances Float_Script
	for controller in scripts do
	(
		controller.Update()
	)
)

rollout SimpleBatchRollout "Batch rendering" width:250 height:490
(
	
	edittext baseNameIT "base filename:" text:"" width:170 fieldWidth:170 height:24 labelOnTop:true
	edittext filePathIT "filepath:" text:"" width:170 fieldWidth:170 height:24 labelOnTop:true offset:[0,20] acros:2
	button fileButtIT "..." width:32 align:#right offset:[0,-26]
	button pickButtIT "Select Cameras" width:80 align:#left offset:[0,20]
	ListBox camListIT  height:20 readonly:true
	button renderIT "Render" offset:[0,20]
	
	on fileButtIT pressed do
	(
		path_name=getSavePath caption:"Output path" initialDir:maxFilePath
		if path_name != undefined then
		(
			filePathIT.text = path_name
			BRS_path_name = path_name
		)
	)
	
	on pickButtIT pressed do
	(
		BRS_cams =selectByName title:"Select cameras" buttonText:"confirm" showHidden:true single:false --filter:camera_filt 
		if BRS_cams!=undefined then
		(
			camListIT.items = for cam in BRS_cams collect cam.name
		)
	)
	
	on renderIT pressed do
	(
		cancelled=false
		reb=#()
		for cam in BRS_cams do
		(
			if cancelled == false do
			(
				viewport.SetCamera cam
				if ( cam.modifiers["scene lighting"] != undefined AND rootNode.custAttributes["lightSystem"] != undefined) then
				(
					cam.modifiers["scene lighting"].calc_light cam
				)
				UpdatePP()
				fileplace = filePathIT.text+@"\"+(getFilenameFile baseNameIT.text)+cam.name+(getFilenameType baseNameIT.text)
				
				bm = render camera:cam outputfile:(fileplace) progressbar:true cancelled:&cancelled renderElements:true renderElementBitmaps:&reb
				if reb!=undefined AND reb.Count>0 then
				(
					for i=1 to reb.count do
					(
						reb_filename=filePathIT.text+@"\"+(getFilenameFile baseNameIT.text)+cam.name+"_re"+(i as string)+(getFilenameType baseNameIT.text)
						reb[i].filename=reb_filename
						save reb[i] quiet:true
					)
				)
			)
			
		)
	)
	
	on SimpleBatchRollout open do
	(
		if BRS_baseName != undefined then
		(
			SimpleBatchRollout.baseNameIT.text = BRS_baseName
			SimpleBatchRollout.filePathIT.text = BRS_path_name
			if BRS_cams!= undefined AND BRS_cams.Count > 0 then
			(
				try
				(
					SimpleBatchRollout.camListIT.items = for cam in BRS_cams collect cam.name
				)
				catch
				(
				)
			)
			else
			(
				SimpleBatchRollout.camListIT.items = #()
			)
		)
		else
		(
			autoPath = filterString maxFilePath "\\"
			autoPathLength = autoPath.Count
			finalPath = ""
			for i=1 to autoPathLength do
			(
				if i != autoPath.Count-1 then
				(
					finalPath = finalPath + autoPath[i]
				)
				else
				(
					finalPath = finalPath + "04 Output"
				)
				finalPath = finalPath + "\\"
			)
			filePathIT.text = finalPath
			outputFile = (getFilenameFile maxFileName) + "_" + ".jpg"
			baseNameIT.text = outputFile
		)
	)
	
	on SimpleBatchRollout close do
	(
		BRS_baseName = baseNameIT.text
		BRS_path_name = filePathIT.text
	)
	
)
SimpleBatchFloater = newRolloutFloater "Max devs suck" 250 518
addRollout SimpleBatchRollout SimpleBatchFloater