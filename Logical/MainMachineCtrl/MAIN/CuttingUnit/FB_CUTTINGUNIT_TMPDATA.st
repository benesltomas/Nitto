(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_CUTTINGUNIT_TMPDATA.st
 * Autor: Awalz
 * Erstellt: 3. Juni 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_CUTTINGUNIT_TMPDATA
	IF BetrCtrl.value = CONST.MACHINEMODES.MANUAL THEN
		IF set THEN
			actMasterModulData := setMasterModulData;
			actMach := setMach;
			actRecipe := setRecipe;
			set := FALSE;
		END_IF
	ELSE 
		err.flag := TRUE;
		err.text := 'Rezept nicht geladen Maschine ist in Aotomatikmodus';
		err.fnc := 'FB_CUTTINGUNIT_TMPDATA';
		err.set := TRUE;
	END_IF
	
	changed := FALSE;
	changedText := '';
	IF compare THEN
		IF actMasterModulData.periodLength <> setMasterModulData.periodLength THEN
			changed := TRUE;
			changedText := 'MasterModulData.recipe.periodLength';
		ELSIF actRecipe.mode <> setRecipe.mode THEN
			changed := TRUE;
			changedText := 'Recipe.mode';
		ELSIF actRecipe.toolNumber <> setRecipe.toolNumber THEN
			changed := TRUE;
			changedText := 'Recipe.toolNumber';
		ELSIF actRecipe.tool.cogSupportSpindle <> setRecipe.tool.cogSupportSpindle  THEN
			changed := TRUE;
			changedText := 'Tool.anvilroller.zaehne';
		ELSIF actRecipe.tool.description <> setRecipe.tool.description THEN
			changed := TRUE;
			changedText := 'Tool.arrangementSpecial';
		ELSIF actRecipe.tool.gearRatioMotor <> setRecipe.tool.gearRatioMotor THEN
			changed := TRUE;
			changedText := 'Tool.gearFactorModule';
		ELSIF actRecipe.tool.cutStartPosition <> setRecipe.tool.cutStartPosition THEN
			changed := TRUE;
			changedText := 'Tool.cutStartPosition';
		ELSIF actRecipe.tool.numberToolSegments <> setRecipe.tool.numberToolSegments  THEN
			changed := TRUE;
			changedText := 'Tool.numberToolsegments';
		ELSIF actRecipe.tool.cogCutting <> setRecipe.tool.cogCutting THEN
			changed := TRUE;
			changedText := 'Tool.cutter.zaehne';
		ELSIF actRecipe.tool.cutEndPosition <> setRecipe.tool.cutEndPosition THEN
			changed := TRUE;
			changedText := 'Tool.cutEndPosition';
		ELSE
//			syncPosCmp(actSyncPos := actTool.shape.syncPos, setSyncPos := setTool.shape.syncPos);
//			IF syncPosCmp.changed THEN
//				changed := TRUE;
//				changedText := CONCAT('Tool.shape.', syncPosCmp.changedText);
//			END_IF
		END_IF
	END_IF
END_FUNCTION_BLOCK