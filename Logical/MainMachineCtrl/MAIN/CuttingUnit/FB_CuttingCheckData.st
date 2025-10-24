(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_CuttingUnitCheckData.st
 * Autor: okrebs
 * Erstellt: 23. Mai 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einzufügen *)
FUNCTION_BLOCK FB_CuttingCheckData
//	
	err(reset := TRUE);
	tmpString := '';
	IF modeCtrl.mode = CONST.CUTTINGUNIT.MODEs.DISABLE THEN
		;
	ELSIF modeCtrl.mode = CONST.CUTTINGUNIT.MODEs.FREE_RUN OR modeCtrl.mode = CONST.CUTTINGUNIT.MODEs.SYNC_RUN THEN
		IF (*recipe.toolNumber < CONST.CUTTINGUNIT.TOOLs.MIN_TOOLS OR*) recipe.toolNumber > CONST.CUTTINGUNIT.TOOLs.MAX_TOOLS THEN
			err.flag := TRUE;
			tmpString := USINT_TO_STRING(recipe.toolNumber);
		(*	tmpString := CONCAT( 'ToolNr: ', tmpString );*)
			err.text := 'Fehler: Produktdaten.';
			err.id := CONST.CUTTINGUNIT.ERRORs.RECIPE_TOOLNR;
		ELSE

			IF  (recipe.tool.cutEndPosition < recipe.tool.cutStartPosition) OR (recipe.tool.cutEndPosition > general.periodLength) 
					OR (recipe.tool.cutStartPosition > general.periodLength) THEN
				err.flag := TRUE;
				err.text := 'Fehler: Produktdaten. Kontur Beschreibung';
				err.id := CONST.CUTTINGUNIT.ERRORs.RECIPE_SHAPE_CONFIG;
				err.fnc := 'FB_CuttingUnitChkData';
			END_IF
			IF recipe.tool.cogCutting < 3 THEN
				err.flag := TRUE;
				tmpString := INT_TO_STRING(recipe.toolNumber);
				err.text := 'Fehler: Zähneanzahl CutterWerkzeug:';
				err.id := CONST.CUTTINGUNIT.ERRORs.CUTTER_ZAEHNE;
				err.fnc := 'FB_CuttingUnitChkData';
			END_IF
			IF recipe.tool.cogSupportSpindle < 3 THEN
				err.flag := TRUE;
				tmpString := INT_TO_STRING(recipe.toolNumber);
				err.text :='Fehler: Zähneanzahl GegenwalzeWerkzeug:';
				err.id := CONST.CUTTINGUNIT.ERRORs.ANVILROLLER_ZAEHNE;
				err.fnc := 'FB_CuttingUnitChkData';
			END_IF
		END_IF
	ELSE
		err.flag := TRUE;
		err.text := 'Fehler: Produktdaten Betriebsart undefiniert';
		err.id := CONST.CUTTINGUNIT.ERRORs.RECIPE_MODE_UNDEF;
		err.fnc := 'FB_CuttingUnitChkData';
	END_IF

	
END_FUNCTION_BLOCK