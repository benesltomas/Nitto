(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_manualGridWin.st
 * Autor: awalz
 * Erstellt: 25. Juni 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* Fügt eine neue Aktion zum IEC Programm oder Bibliothek *)
ACTION ac_manualGridWin: 
			CASE state OF	

	ST_IDLE:
//		IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL THEN
//			state := ST_IDLE;
//			err(reset := TRUE);
//			busy := TRUE;
//			status.ready := FALSE;
//			StateCtrl := CTRL_MANUAL_AFTER;
//		ELSE
			IF axis.MC_ReadStatus_0.Error OR axis.MC_ReadStatus_0.Errorstop  THEN 
				axis.cmd := CONST.AXIS.RESET;
				state := ST_AXIS_STOP;
			ELSE
				IF data.recipeData.mode = CONST.UNITMODEs.ENABLE THEN
					IF axis.MC_ReadStatus_0.Disabled THEN  
						axis(cmd := CONST.AXIS.POWER_ON, machineaxis := machineaxis, data := data);  
						state := ST_AXIS_ON;
					ELSIF axis.MC_ReadStatus_0.StandStill THEN
				(*		axis(cmd := CONST.AXIS.START, machineaxis := machineaxis, data := data);*)
						axis.cmd := CONST.AXIS.START;
						state := ST_AXIS_RUN;
					END_IF
				ELSIF data.recipeData.mode =  CONST.UNITMODEs.DISABLE THEN  
					IF axis.MC_ReadStatus_0.Disabled THEN  
						axis(cmd := CONST.AXIS.POWER_ON, machineaxis := machineaxis, data := data);  
						state := ST_AXIS_ON_DIS;
					ELSE 
						axis(cmd := CONST.AXIS.STOP, machineaxis := machineaxis, data := data);
						state := ST_AXIS_STOP;
					END_IF
				ELSIF data.recipeData.mode = CONST.UNITMODEs.AXIS_OFF THEN
					axis(cmd := CONST.AXIS.POWER_OFF, machineaxis := machineaxis, data := data);
					state := ST_AXIS_OFF;
				END_IF
			END_IF
//		END_IF

	ST_AXIS_STOP:
			IF data.recipeData.mode <> CONST.UNITMODEs.DISABLE THEN
				state := ST_IDLE;
/////////// wenn die Achse disable ist und die Maschine los läuft die Ache automatisch starten
			ELSIF machineaxis.MC_ReadStatus_0.ContinuousMotion THEN
				data.recipeData.mode :=  CONST.UNITMODEs.ENABLE;
				axis.cmd := CONST.AXIS.START;
				state := ST_IDLE;
			END_IF

	ST_AXIS_ON_DIS:
			IF data.recipeData.mode = CONST.UNITMODEs.DISABLE THEN
				state := ST_IDLE;
			END_IF

	ST_AXIS_RUN:
//			IF data.recipeData.mode <> CONST.UNITMODEs.ENABLE OR axis.MC_ReadStatus_0.Disabled OR axis.MC_ReadStatus_0.StandStill THEN
//				state := ST_IDLE;
//			END_IF
			IF data.recipeData.mode <> CONST.UNITMODEs.ENABLE (*OR NOT axis.MC_ReadStatus_0.ContinuousMotion*) THEN
				state := ST_IDLE;
			END_IF

	ST_AXIS_ON:	

			IF data.recipeData.mode = CONST.UNITMODEs.ENABLE THEN
				state := ST_IDLE;
			ELSIF data.recipeData.mode	<> CONST.UNITMODEs.ENABLE AND axis.MC_ReadStatus_0.ContinuousMotion THEN 
				state := ST_IDLE;
			END_IF

//			IF data.recipeData.mode <> CONST.UNITMODEs.ENABLE THEN
//				state := ST_IDLE;
//			END_IF

	ST_AXIS_OFF: 
			IF data.recipeData.mode <> CONST.UNITMODEs.AXIS_OFF THEN
				state := ST_IDLE;
			END_IF

	END_CASE
END_ACTION