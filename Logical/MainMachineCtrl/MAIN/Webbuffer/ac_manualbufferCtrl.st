(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_bufferCtrl.st
 * Autor: awalz
 * Erstellt: 10. Juli 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* Fügt eine neue Aktion zum IEC Programm oder Bibliothek *)
ACTION ac_manualbufferCtrl: 
//	axis.bufferaxis(machineaxis := machineaxis, data := data); (*auskomentiert am 21.08.14*)
	config( axis := axis, status := status);
	IF keys.home.LDT.button THEN
		cmdCtrl.value := CONST.CUTTINGUNIT.CMDs.CALIBR;
	ELSE
		cmdCtrl.value := CONST.CUTTINGUNIT.CMDs.NO_CMD;
//	ELSIF keys.home.LDT.ftrig THEN 
//		cmdCtrl.value := CONST.CUTTINGUNIT.CMDs.NO_CMD;
	END_IF

	CASE state OF
	ST_IDLE:
		IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL THEN
//			state := ST_IDLE;
//			err(reset := TRUE);
			busy := TRUE;
			StateCtrl := CTRL_MANUAL_AFTER;

		ELSE 
			IF 	firstStart AND  NOT axis.ctrl.BasicControl.AxisState.Homed  AND cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.CALIBR AND mechbrakeON_OFF THEN
				firstStart := FALSE;
				unwinderOFF := TRUE;
				state := ST_FUNCTION_START;
//		
			ELSIF (cmdCtrl.value =  CONST.CUTTINGUNIT.CMDs.MOVEBW OR cmdCtrl.value =  CONST.CUTTINGUNIT.CMDs.MOVEFW)
				AND axis.ctrl.BasicControl.AxisState.Homed AND mechbrakeON_OFF THEN
					cmdStatus(set := TRUE, value := cmdCtrl.value);
					busy := TRUE;
//					unwinderOFF := TRUE;  //Auskommentiert weil: Beim hoch und runter bewegen soll der Abwickler an bleiben, OKrebs 16.09.14
					state := ST_MOVE_START;
			ELSE
			 	IF (*axis.ctrl.BasicControl.AxisState.Homed AND *) machineaxis.MC_ReadStatus_0.ContinuousMotion AND mechbrakeON_OFF
				AND cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
					axis.bufferaxis.cmd := CONST.AXIS.START;
				ELSIF  (*machineaxis.MC_ReadStatus_0.StandStill OR*) cmdCtrl.value =  CONST.CUTTINGUNIT.CMDs.ABORT THEN
					axis.bufferaxis.cmd := CONST.AXIS.STOP;
				END_IF
//		END_IF
			END_IF
		END_IF


	ST_MOVE_START:
		IF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			cmdStatus(set := TRUE, value := CONST.CUTTINGUNIT.CMDs.NO_CMD);
			busy := FALSE;
			state := ST_IDLE;
//		ELSIF config.busy OR config.cmd <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
//			config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, axis := axis, status := status);
		ELSE
			config(cmd := cmdStatus.value, axis := axis, status := status);
			state := ST_MOVE;
		END_IF

	ST_MOVE:
		config ( axis := axis, status := status);
		IF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD,  axis := axis, status := status);
			state := ST_MOVE_QUIT;
		END_IF
		
	ST_MOVE_QUIT:
		config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, axis := axis, status := status);
		IF NOT config.busy THEN
			busy := FALSE;
			unwinderOFF := FALSE;
			cmdStatus(set := TRUE, value := CONST.CUTTINGUNIT.CMDs.NO_CMD);
			state := ST_IDLE;
		END_IF

	ST_FUNCTION_START:
		IF config.busy OR config.cmd <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, axis := axis, status := status);
		ELSE
			config(cmd := CONST.CUTTINGUNIT.CMDs.CALIBR (*cmdStatus.value*), axis := axis, status := status);
			state := ST_FUNCTION;
		END_IF

	ST_FUNCTION:
		config(  axis := axis, status := status);
		IF NOT config.busy THEN
			IF config.err.flag THEN
				err := config.err;
				err.state := state;
			END_IF
			config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD,  axis := axis, status := status );
			state := ST_FUNCTION_QUIT;
		ELSIF keys.up.LDT.button AND keys.down.LDT.button THEN//10.11.15
				config(cmd := CONST.CUTTINGUNIT.CMDs.RESET,  axis := axis, status := status );
			state := ST_FUNCTION_QUIT;
		END_IF

	ST_FUNCTION_QUIT:
		busy := FALSE;
			
		IF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			cmdStatus(set :=TRUE, value := CONST.CUTTINGUNIT.CMDs.NO_CMD);
			unwinderOFF := FALSE;
			state := ST_IDLE;
		END_IF

	END_CASE

END_ACTION