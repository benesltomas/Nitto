(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_manualTurnGrd.st
 * Autor: Awalz
 * Erstellt: 5. Juni 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> Fügt eine neue Aktion zum IEC Programm oder Bibliothek </$Description$>*)
ACTION ac_manualTurnGrd: 
		IF feeder.MC_ReadStatus_0.ContinuousMotion THEN
			rtig := TRUE;
		ELSE
			rtig := FALSE;
		END_IF
		feedertrig(CLK := rtig);

	CASE state OF 
		
		ST_IDLE: 
			IF feedertrig.Q  THEN 
				(*feederPosTmp := feeder.BasicControl.Status.ActPosition;*)
				feederPosTmp := feeder.MC_ReadActualPosition_0.Position;
				IF gridwinderright.data.recipeData.mode = CONST.UNITMODEs.ENABLE THEN 
				(*	gridwinderright.data.machData.frictionCompensation := 1;*)
					state := ST_TURN_WAIT_RIGHT;
				ELSIF gridwinderleft.data.recipeData.mode = CONST.UNITMODEs.ENABLE THEN
					(*gridwinderleft.data.machData.frictionCompensation := 1;*)
					state := ST_TURN_WAIT_LEFT;
				END_IF
			
			END_IF

		ST_TURN_WAIT_RIGHT:
			IF feederPosTmp + 65000 < feeder.BasicControl.Status.ActPosition AND feeder.MC_ReadStatus_0.ContinuousMotion  THEN
				gridwinderright.data.recipeData.mode := CONST.UNITMODEs.AXIS_OFF;
				gridwinderleft.data.recipeData.mode := CONST.UNITMODEs.ENABLE;
				state := ST_IDLE;
			ELSIF NOT feeder.MC_ReadStatus_0.ContinuousMotion THEN
					state := ST_IDLE;
			END_IF

		ST_TURN_WAIT_LEFT:
			IF feederPosTmp + 65000 < feeder.BasicControl.Status.ActPosition AND feeder.MC_ReadStatus_0.ContinuousMotion THEN	
				gridwinderright.data.recipeData.mode := CONST.UNITMODEs.ENABLE;
				gridwinderleft.data.recipeData.mode := CONST.UNITMODEs.AXIS_OFF;
				state := ST_IDLE;
			ELSIF NOT feeder.MC_ReadStatus_0.ContinuousMotion THEN
				state := ST_IDLE;
			END_IF

		ST_NOACTION: 
				;
	END_CASE
END_ACTION