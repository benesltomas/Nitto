(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_manualPB.st
 * Autor: Awalz
 * Erstellt: 7. Mai 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> Fügt eine neue Aktion zum IEC Programm oder Bibliothek </$Description$>*)
ACTION ac_manualPB: 
//	axis.ctrl();
	config( machineMasterCtrl := machineMaster, axis := axis, status := status);
	CASE state OF
	ST_IDLE:
//		IF config.busy OR config.cmd <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
//			config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMasterCtrl := machineMaster, axis := axis, status := status);
		IF manualFirst  OR mode <> status.mode (*OR NewData *)THEN
			IF NOT status.isCoupled AND mode = CONST.UNITMODEs.ENABLE THEN
				config(cmd := CONST.CUTTINGUNIT.CMDs.CPL_ON, machineMasterCtrl := machineMaster, axis := axis, status := status);
				state := ST_CPL_WAIT;
			ELSIF mode <> CONST.UNITMODEs.ENABLE AND status.isCoupled THEN
				config(cmd := CONST.CUTTINGUNIT.CMDs.CPL_OFF, machineMasterCtrl := machineMaster, axis := axis, status := status);
				state := ST_CPL_WAIT;
			ELSE
				NewData := FALSE;
				manualFirst := FALSE;
			END_IF
///////////////////////////////////////////////////
//			ELSIF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.MOVEFW OR cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.MOVEBW THEN
//					state := 	ST_MOVE_START;
//////////////////////////////	
		ELSIF cmdCtrl.value <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			cmdStatus(set := TRUE, value := cmdCtrl.value);
			busy := TRUE;
			state := ST_FUNCTION_START;
		END_IF

	ST_CPL_WAIT:
		config( machineMasterCtrl := machineMaster, axis := axis, status := status);
		IF NOT config.busy THEN
			IF config.err.flag THEN
				err := config.err;
				err.state := state;
				state := ST_ERROR;
			ELSE
				manualFirst := FALSE;
				state := ST_IDLE;
			END_IF
			config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMasterCtrl := machineMaster, axis := axis, status := status );
		END_IF

	ST_FUNCTION_START:
//		IF config.busy (*OR config.cmd <> CONST.CUTTINGUNIT.CMDs.NO_CMD*) THEN
//			config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMasterCtrl := machineMaster, axis := axis, status := status);
//		ELSE
			config(cmd := cmdStatus.value, machineMasterCtrl := machineMaster, axis := axis, status := status);
			state := ST_FUNCTION;
	(*	END_IF*)

	ST_FUNCTION:
////		config( machineMasterCtrl := machineMaster, axis := axis, status := status);
////		IF NOT config.busy THEN
////			IF config.err.flag THEN
////				err := config.err;
////				err.state := state;
////			END_IF
////		config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMasterCtrl := machineMaster, axis := axis, status := status );
////			state := ST_FUNCTION_QUIT;
		IF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMasterCtrl := machineMaster, axis := axis, status := status );
			state := ST_FUNCTION_QUIT;
		END_IF

	ST_FUNCTION_QUIT:
		busy := FALSE;
		IF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			cmdStatus(set :=TRUE, value := CONST.CUTTINGUNIT.CMDs.NO_CMD);
			state := ST_IDLE;
		END_IF

	ST_ERROR:
		err.flag := TRUE;
		busy := FALSE;
		IF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL THEN
			state := ST_IDLE;
			err(reset := TRUE);
			busy := TRUE;
			StateCtrl := CTRL_MANUAL_AFTER;
		END_IF
	END_CASE



END_ACTION