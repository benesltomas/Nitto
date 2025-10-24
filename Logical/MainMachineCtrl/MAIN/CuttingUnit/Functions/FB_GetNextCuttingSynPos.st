(********************************************************************
 * COPYRIGHT -- Nitto
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_GetNextCuttingSynPos.st
 * Autor: s_spilker
 * Erstellt: 9. November 2015
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_GetNextCuttingSynPos
// zu brmfmod die Funktion soll einen Rest der zwei Längen berechnen 
// wenn die zwei Längen gelich sind (ausgenommen die Nachkommastellen fängt der Wert zu jittern (der Wert springt zwischen 0 und der Periodenlänge)

	periodLength :=	uData.general.periodLength;
	getMark(machineMaster := machineMaster, uData := uData, markpoints := markpoints, uAxis := uAxis, usercorrec := setCutOffset.setOffset_o);
//		IF period = 1 THEN //nur für Testzwecke
//		IF moduloBeforePosition > 0 THEN
//			IF moduloBeforePosition > periodLength THEN 
//				correctionTotal1 := fmod(moduloBeforePosition, periodLength);
//				syncDataBefore.correctionNoLimit := correctionTotal1;
//				correctionTotalInt := 1;
//			ELSIF moduloBeforePosition < periodLength THEN
//				syncDataBefore.correctionNoLimit := (periodLength - moduloBeforePosition);
//				correctionTotalInt := 2;
//			END_IF
//		ELSIF 	moduloBeforePosition < 0 THEN
//			IF moduloBeforePosition < - periodLength THEN
//				correctionTotal1 := fmod(moduloBeforePosition, periodLength);
//				syncDataBefore.correctionNoLimit :=  correctionTotal1;
//				correctionTotalInt := 3;	
//			ELSIF moduloBeforePosition > - periodLength THEN
//				syncDataBefore.correctionNoLimit := moduloBeforePosition + periodLength;
//				correctionTotalInt := 4;
//			END_IF
//	
//		ELSIF moduloBeforePosition = periodLength THEN
//				syncDataBefore.correctionNoLimit := 0;
//				correctionTotalInt := 5;
//		END_IF
//	ELSIF period =	2 THEN
//		IF ABS ( moduloBeforePosition) > periodLength THEN
//			correctionTotal1 := fmod(ABS (moduloBeforePosition), periodLength);
//			syncDataBefore.correctionNoLimit := correctionTotal1 - periodLength;
//			correctionTotalInt := 6;
//		ELSIF ABS (moduloBeforePosition) < periodLength THEN
//			syncDataBefore.correctionNoLimit := correctionTotal1;
//			correctionTotalInt := 7;	
//		END_IF
//	ELSIF period = 3 THEN
//			correctionTotal1 := fmod(moduloBeforePosition, periodLength);
//			IF correctionTotal1 > periodLength/2 THEN
//				syncDataBefore.correctionNoLimit := correctionTotal1 - periodLength;
//			ELSE 
//				syncDataBefore.correctionNoLimit := correctionTotal1;
//			END_IF
//	ELSIF period =4 THEN
//			correctionTotal1 := fmod(ABS (moduloBeforePosition), periodLength);
//				IF correctionTotal1 > periodLength/2 THEN
//				syncDataBefore.correctionNoLimit := correctionTotal1 - periodLength;
//			ELSE 
//				syncDataBefore.correctionNoLimit := correctionTotal1;
//			END_IF
//	ELSIF period = 5 THEN 
//		correctionTotal1 := fmod(moduloBeforePosition, periodLength);
//	END_IF
//////permantes Lesen der Kurvenscheibenposition des Masters X-Achse 607, 512, 1067, 
//	MC_BR_ReadCyclicPosition_1(Enable := TRUE, ParID:= 542, Axis := uAxis.AxisREF);//nur zu Testzwecken 
	MC_BR_ReadCyclicPosition_0(Enable := TRUE, ParID:= 1075, Axis := uAxis.AxisREF);
//	moduloBeforePosition := MC_BR_ReadCyclicPosition_0.CyclicPosition.Integer - uData.general.periodLength;
	moduloBeforePosition := MC_BR_ReadCyclicPosition_0.CyclicPosition.Real - uData.general.periodLength;
	IF uData.recipe.mode = CONST.CUTTINGUNIT.MODEs.FREE_RUN THEN 
		//für einen Rundenzähler
		countRtrig();	
		IF MC_BR_ReadCyclicPosition_0.CyclicPosition.Real < 5000 THEN
			countRtrig.CLK := TRUE;
		END_IF
		IF countRtrig.Q	THEN 
			syncDataBefore.markIndx := syncDataBefore.markIndx + 1;
			syncDataBefore.correctionNoLimit :=	- setCutOffset.setOffset_o;
		END_IF
		IF MC_BR_ReadCyclicPosition_0.CyclicPosition.Real > 10000 THEN
			countRtrig.CLK := FALSE;
		END_IF
	ELSIF uData.recipe.mode = CONST.CUTTINGUNIT.MODEs.SYNC_RUN OR uData.recipe.mode = CONST.CUTTINGUNIT.MODEs.CROSS_CUT THEN
			IF 	markpoints.ProbeCounter <> tmpcounter  OR trigger THEN
	//			correctionTotal := getMark.diffToUnitBefore - MC_BR_ReadCyclicPosition_0.CyclicPosition.Real;
				correctionTmp	:= fmod(getMark.diffToUnitBefore, uData.general.periodLength);
	//			correctionTotal := getMark.diffToUnitBefore - moduloBeforePosition;////03.11
				correctionTotal := correctionTmp - moduloBeforePosition;
				syncDataBefore.correctionNoLimit := correctionTotal;
				trigger := FALSE;
				syncDataBefore.markIndx := markpoints.ProbeCounter;	
				tmpcounter := markpoints.ProbeCounter;
			ELSIF markpoints.MissedTriggers <> period THEN
				syncDataBefore.correctionNoLimit := correctionTotal;// LETZTEN BEKQNNTN WERT ALS KORREKTUR VORGEBEN
				period := markpoints.MissedTriggers;
			END_IF
	END_IF



END_FUNCTION_BLOCK