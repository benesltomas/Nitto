(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_manualUnwinderCtrl.st
 * Autor: awalz
 * Erstellt: 24. Juni 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* Fügt eine neue Aktion zum IEC Programm oder Bibliothek *)
ACTION ac_manualUnwinderCtrl: 
	CASE state OF	
	ST_IDLE:
		IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL THEN
			state := ST_IDLE;
			err(reset := TRUE);
			busy := TRUE;
			status.ready := FALSE;
			StateCtrl := CTRL_MANUAL_AFTER;
		ELSE
			IF unwinderaxis.MC_ReadStatus_0.Error OR unwinderaxis.MC_ReadStatus_0.Errorstop  THEN 
				unwinderaxis.cmd := CONST.AXIS.RESET;
				cmd := CONST.AXIS.RESET;
				state := ST_AXIS_STOP;
			ELSE
				IF data.recipeData.mode = CONST.UNITMODEs.ENABLE THEN
					IF unwinderaxis.MC_ReadStatus_0.Disabled THEN  
						unwinderaxis(cmd := CONST.AXIS.POWER_ON, machineaxis := machineaxis, data := data);  
						state := ST_AXIS_ON;
					END_IF
					IF unwinderaxis.MC_ReadStatus_0.StandStill THEN
						unwinderaxis(cmd := CONST.AXIS.START, machineaxis := machineaxis, data := data);
						state := ST_AXIS_RUN;
					END_IF
				ELSIF data.recipeData.mode =  CONST.UNITMODEs.DISABLE THEN  
					IF unwinderaxis.MC_ReadStatus_0.Disabled THEN  
						unwinderaxis(cmd := CONST.AXIS.POWER_ON, machineaxis := machineaxis, data := data);  
						state := ST_AXIS_ON_DIS;
					ELSE 
						unwinderaxis(cmd := CONST.AXIS.STOP, machineaxis := machineaxis, data := data);
						state := ST_AXIS_STOP;
					END_IF
				ELSIF  data.recipeData.mode = CONST.UNITMODEs.AXIS_OFF THEN
					unwinderaxis(cmd := CONST.AXIS.POWER_OFF, machineaxis := machineaxis, data := data);
					state := ST_AXIS_OFF;
				END_IF
			END_IF
		END_IF


	ST_AXIS_STOP:
			IF data.recipeData.mode <> CONST.UNITMODEs.DISABLE THEN
				state := ST_IDLE;
			END_IF

	ST_AXIS_ON_DIS:
			IF data.recipeData.mode = CONST.UNITMODEs.DISABLE THEN
				state := ST_IDLE;
			END_IF

	ST_AXIS_RUN:
			IF data.recipeData.mode <> CONST.UNITMODEs.ENABLE (*AND NOT unwinderaxis.MC_ReadStatus_0.StandStill *) THEN
				state := ST_IDLE;
			END_IF
		
	ST_AXIS_ON:	
//			IF data.recipeData.mode = CONST.UNITMODEs.ENABLE THEN
//				state := ST_IDLE;
//			END_IF
			IF data.recipeData.mode = CONST.UNITMODEs.ENABLE THEN
				state := ST_IDLE;
			ELSIF data.recipeData.mode	<> CONST.UNITMODEs.ENABLE AND unwinderaxis.MC_ReadStatus_0.ContinuousMotion THEN 
				state := ST_IDLE;
			END_IF
	ST_AXIS_OFF: 
			IF data.recipeData.mode <> CONST.UNITMODEs.AXIS_OFF THEN
				state := ST_IDLE;
			END_IF

		
	END_CASE

END_ACTION