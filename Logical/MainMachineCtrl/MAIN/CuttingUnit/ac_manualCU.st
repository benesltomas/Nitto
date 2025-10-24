(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: ac_manualCU.st
 * Autor: Awalz
 * Erstellt: 21. Mai 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> Fügt eine neue Aktion zum IEC Programm oder Bibliothek </$Description$>*)
ACTION ac_manualCU: 
	status.isCoupled := axis.ctrl.MC_ReadStatus_0.SynchronizedMotion;

	CASE state OF
		ST_IDLE:

			IF status.dataOk THEN
				IF data.newTools OR data.newRecipe THEN
					IF data.recipe.mode = CONST.CUTTINGUNIT.MODEs.DISABLE THEN
						modeCtrl.mode := data.recipe.mode;
						config (cmd := CONST.CUTTINGUNIT.CMDs.DEINIT, machineMaster := machineMaster,axis := axis, status := status, data := data,
						IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter,markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
						busy := TRUE;
						state := ST_SETDATA_WAIT;
					ELSE	
						modeCtrl.mode := data.recipe.mode;
						check(machdata := data.machdata, recipe := data.recipe, general := data.general, modeCtrl := modeCtrl);
						IF check.err.flag THEN
							data.err := check.err;
						ELSE
							config (cmd := CONST.CUTTINGUNIT.CMDs.SETDATA, machineMaster := machineMaster, axis := axis, status := status, data := data, 
							IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter,markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
							state := ST_SETDATA_WAIT;
						END_IF
					END_IF
				ELSE
					IF data.recipe.mode = CONST.CUTTINGUNIT.MODEs.DISABLE THEN // Stanzen dennoch bewegen können*)

						IF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.MOVEFW OR cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.MOVEBW THEN
							cmdStatus(set := TRUE, value := cmdCtrl.value);
							busy := TRUE;
							state := ST_MOVE_START;
						ELSIF cmdCtrl.value <> CONST.CUTTINGUNIT.CMDs.NO_CMD AND NOT cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.RESET THEN
							cmdStatus(set := TRUE, value := cmdCtrl.value);
							busy := TRUE;
							state := ST_FUNCTION_START;
						END_IF
					ELSE
						IF NOT status.isCalibrated OR NOT axis.ctrl.BasicControl.AxisState.Homed THEN
							modeCtrl.mode := data.recipe.mode;
							IF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.CALIBR THEN (*warten bis das kommando  gesetzt wird*)
								cmdStatus(set := TRUE, value := cmdCtrl.value);
								busy := TRUE;
								state := ST_FUNCTION_START;
							ELSIF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.MOVEFW OR cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.MOVEBW THEN
								cmdStatus(set := TRUE, value := cmdCtrl.value);
								busy := TRUE;
								state := ST_MOVE_START;
							END_IF
						ELSE 
							IF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.MOVEFW OR cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.MOVEBW THEN
								cmdStatus(set := TRUE, value := cmdCtrl.value);
								busy := TRUE;
								state := ST_MOVE_START;
							ELSIF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.CALIBR THEN
								cmdStatus(set := TRUE, value := cmdCtrl.value);
								busy := TRUE;
								state := ST_FUNCTION_QUIT;
							ELSIF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.SYNC THEN
								cmdStatus(set := TRUE, value := cmdCtrl.value);
								busy := TRUE;
								state := ST_FUNCTION_START;
							ELSIF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.CPL_ON THEN// manuell koppeln
								cmdStatus(set := TRUE, value := cmdCtrl.value);
								busy := TRUE;
								state := ST_FUNCTION_START;
							ELSIF manualFirst AND axis.ctrl.MC_ReadStatus_0.StandStill THEN//bei Steuerung Aus/Ein wieder einkoppeln
								busy := TRUE;
								manualFirst := FALSE;
								state := ST_CPLON_WAIT;
							END_IF 
						END_IF
					END_IF
				END_IF
			END_IF

		ST_CPLON_WAIT:
			IF config.busy THEN
				config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMaster := machineMaster, axis := axis, status := status,data := data, 
				IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter,markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
			ELSE
				config(cmd := CONST.CUTTINGUNIT.CMDs.CPL_ON, machineMaster := machineMaster, axis := axis, status := status,data := data, 
				IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter,markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
				state := ST_FUNCTION;
			END_IF

		ST_SETDATA_WAIT:
			config ( machineMaster := machineMaster, axis := axis, status := status, data := data, IOs := IOs, powerbridge := powerbridge, 
				scalePerimeter := scalePerimeter, markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
			IF NOT config.busy THEN
				IF config.err.flag THEN
					err := config.err;
					err.state := state;
					state := ST_ERROR;
				ELSE
					tmpData(set := TRUE, setMasterModulData := data.general, setMach := data.machdata, setRecipe := data.recipe, BetrCtrl := BetrCtrl );
					data(newRecipe := FALSE, newMach := FALSE);
					busy := FALSE;
					config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMaster := machineMaster, axis := axis, status := status,data := data, 
					IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter,markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
					state := ST_IDLE;
				END_IF
			ELSIF  cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.RESET THEN //14.04.15
				config(cmd := CONST.CUTTINGUNIT.CMDs.RESET, machineMaster := machineMaster, axis := axis, status := status, data := data, 
				IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter,markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
				state := ST_FUNCTION_ABORT_WAIT;
			END_IF

		ST_FUNCTION_START:
			IF config.busy OR config.cmd <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
				config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMaster := machineMaster, axis := axis, status := status, data := data, 
				IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter, markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
			ELSE
				config (cmd := cmdStatus.value, machineMaster := machineMaster, axis := axis, status := status, data := data, IOs := IOs, 
				powerbridge := powerbridge, scalePerimeter := scalePerimeter, markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
				state := ST_FUNCTION;
			END_IF

		ST_FUNCTION://12
			config(machineMaster := machineMaster, axis := axis, status := status, data := data, IOs := IOs, powerbridge := powerbridge, 
				scalePerimeter := scalePerimeter, markpoints := markpoints, camtable := camtable, getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
			IF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.ABORT THEN
				config(cmd := CONST.CUTTINGUNIT.CMDs.ABORT, machineMaster := machineMaster, axis := axis, status := status, data := data,
				IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter, markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
				state := ST_FUNCTION_ABORT_WAIT;
			ELSIF NOT config.busy THEN
				IF config.err.flag THEN
					err := config.err;
					err.state := state;
				END_IF
				config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMaster := machineMaster, axis := axis, status := status, data := data, 
				IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter,markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
				state := ST_FUNCTION_QUIT;
			ELSIF (*config.err.flag AND*) cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.RESET THEN //14.04.15
				config(cmd := CONST.CUTTINGUNIT.CMDs.RESET, machineMaster := machineMaster, axis := axis, status := status, data := data, 
				IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter,markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
				state := ST_FUNCTION_ABORT_WAIT;
			END_IF

		ST_FUNCTION_ABORT_WAIT:
			config( machineMaster := machineMaster, axis := axis, status := status, data := data,IOs := IOs, powerbridge := powerbridge,
				scalePerimeter := scalePerimeter, markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
			IF NOT config.busy THEN
				IF config.err.flag THEN
					err := config.err;
					err.state := state;
				END_IF
				config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMaster := machineMaster, axis := axis, status := status, data := data, 
				IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter,markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
				state := ST_FUNCTION_QUIT;
			END_IF
			
		ST_FUNCTION_QUIT:
			busy := FALSE;
			IF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
				cmdStatus(set := TRUE, value := CONST.CUTTINGUNIT.CMDs.NO_CMD);
				state := ST_IDLE;
			END_IF

		ST_MOVE_START:

			IF config.busy OR config.cmd <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN //27.04.15
				config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMaster := machineMaster, axis := axis, status := status, data := data, IOs := IOs, powerbridge := powerbridge, 
				scalePerimeter := scalePerimeter, markpoints := markpoints, camtable := camtable, getNextUnitSyncPos := getNextUnitSyncPos,setCutOffset := setCutOffset);
			ELSIF NOT config.busy THEN //27.04.15
				config(cmd := cmdStatus.value, machineMaster := machineMaster, axis := axis, status := status, data := data, IOs := IOs, powerbridge := powerbridge, 
				scalePerimeter := scalePerimeter, markpoints := markpoints, camtable := camtable,getNextUnitSyncPos := getNextUnitSyncPos,setCutOffset := setCutOffset);
				state := ST_MOVE;
			END_IF

		ST_MOVE:
			config(machineMaster := machineMaster, axis := axis, status := status, data := data, IOs := IOs, powerbridge := powerbridge, 
				scalePerimeter := scalePerimeter, markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
			IF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
				config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMaster := machineMaster, axis := axis, status := status, data := data, 
				IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter, markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
				state := ST_MOVE_QUIT;
			
			ELSE
				config(cmd := cmdStatus.value, machineMaster := machineMaster, axis := axis, status := status, data := data, 
				IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter, markpoints := markpoints,camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
			END_IF
		
		ST_MOVE_QUIT:
			config(cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD, machineMaster := machineMaster, axis := axis, status := status, data := data, 
			IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter, markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
			IF NOT config.busy THEN
				busy := FALSE;
				cmdStatus(set := TRUE, value := CONST.CUTTINGUNIT.CMDs.NO_CMD);
				state := ST_IDLE;
			ELSIF cmdCtrl.value = CONST.CUTTINGUNIT.CMDs.RESET THEN //14.04.15
				config(cmd := CONST.CUTTINGUNIT.CMDs.RESET, machineMaster := machineMaster, axis := axis, status := status, data := data, 
				IOs := IOs, powerbridge := powerbridge, scalePerimeter := scalePerimeter,markpoints := markpoints, camtable := camtable,  getNextUnitSyncPos := getNextUnitSyncPos, setCutOffset := setCutOffset);
				state := ST_FUNCTION_ABORT_WAIT;
			END_IF
	
		ST_ERROR:
			err.set := TRUE;
			busy := FALSE;
			IF cmdCtrl.value <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
				err(reset := TRUE);
				state := ST_IDLE;
			ELSIF BetrCtrl.value <> CONST.MACHINEMODES.MANUAL THEN
				state := ST_IDLE;
				err(reset := TRUE);
				busy := TRUE;
				StateCtrl := CTRL_MANUAL_AFTER;
			END_IF
	END_CASE

END_ACTION