(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_automUnwinder.st
 * Autor: awalz
 * Erstellt: 24. Juli 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* Fügt eine neue Aktion zum IEC Programm oder Bibliothek *)
ACTION ac_automUnwinder:
	CASE state OF	
		ST_IDLE:
			IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC  THEN
				state := ST_IDLE;
				err(reset := TRUE);
				busy := TRUE;
				(*	status.ready := FALSE;*)
				StateCtrl := CTRL_AUTO_AFTER;
			ELSE
				IF NOT feederCtrl.LimitSwitchRight AND machineaxis.MC_ReadStatus_0.ContinuousMotion THEN
					unwinderOp.data.recipeData.mode := CONST.UNITMODEs.ENABLE;
					state := ST_AXIS_RUN;	
				ELSIF NOT feederCtrl.LimitSwitchLeft AND  machineaxis.MC_ReadStatus_0.ContinuousMotion THEN
					unwinderDrv.data.recipeData.mode := CONST.UNITMODEs.ENABLE;
					state := ST_AXIS_RUN;
				ELSIF NOT feederCtrl.LimitSwitchRight AND  unwinderDrv.data.recipeData.mode = CONST.UNITMODEs.ENABLE THEN
					unwinderDrv.data.recipeData.mode := CONST.UNITMODEs.AXIS_OFF;
					state := ST_AXIS_STOP; (*automatische deaktivierung des Wicklers der gerade nicht dran ist*)
				ELSIF NOT feederCtrl.LimitSwitchLeft AND unwinderOp.data.recipeData.mode = CONST.UNITMODEs.ENABLE THEN
					unwinderOp.data.recipeData.mode := CONST.UNITMODEs.AXIS_OFF;
					state := ST_AXIS_STOP;	(*automatische deaktivierung des Wicklers der gerade nicht dran ist*)
				END_IF
			END_IF

		ST_AXIS_RUN:
			IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC THEN
				state := ST_IDLE;
				err(reset := TRUE);
				busy := TRUE;
				(*	status.ready := FALSE;*)
				StateCtrl := CTRL_AUTO_AFTER;
			ELSE
				IF NOT  machineaxis.MC_ReadStatus_0.ContinuousMotion (*AND NOT unwinderaxis.MC_ReadStatus_0.StandStill *) THEN
					state := ST_IDLE;
				END_IF
			END_IF

		ST_AXIS_STOP:
			IF BetrCtrl.value <> CONST.MACHINEMODES.AUTOMATIC THEN
				state := ST_IDLE;
				err(reset := TRUE);
				busy := TRUE;
				(*	status.ready := FALSE;*)
				StateCtrl := CTRL_AUTO_AFTER;
			ELSE 
				IF NOT  machineaxis.MC_ReadStatus_0.StandStill (*AND NOT unwinderaxis.MC_ReadStatus_0.StandStill *) THEN
					state := ST_IDLE;
				END_IF
			END_IF
	END_CASE 		
END_ACTION