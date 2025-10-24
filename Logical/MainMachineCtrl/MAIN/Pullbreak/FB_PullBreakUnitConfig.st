(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_PullBreakUnitConfig.st
 * Autor: Awalz
 * Erstellt: 7. Mai 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_PullBreakUnitConfig
 axis.cplOn();
 axis.cplOff();
	axis.ctrl.BasicControl.Parameter.Deceleration	:= 80000.0; //only for initialization
	axis.ctrl.BasicControl.Parameter.Acceleration	:= 80000.0;

	CASE state OF
	ST_IDLE:
		IF cmd <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			busy := TRUE;
			err(reset:= TRUE);
			cmdtmp := cmd;
			IF cmd = CONST.CUTTINGUNIT.CMDs.CPL_ON THEN
				cmdtmp := cmd;
				state := ST_CPL_START;
			ELSIF cmd = CONST.CUTTINGUNIT.CMDs.CPL_OFF THEN
				cmdtmp := cmd;
				state := ST_CPLOFF_START;
			ELSIF  cmd =  CONST.CUTTINGUNIT.CMDs.MOVEBW OR cmd = CONST.CUTTINGUNIT.CMDs.MOVEFW THEN
				state := ST_MOVE_START;
			ELSE
				err.state := state;
				err(text := 'CommandError');
				state := ST_ERROR;
			END_IF
		END_IF

	ST_CPL_START:
		axis.ctrl();
		
		IF cmd = CONST.CUTTINGUNIT.CMDs.ABORT THEN
			state := ST_ABORT;
		ELSIF axis.cplOn.InGear THEN
			status.isCoupled := TRUE;
			status.mode := CONST.UNITMODEs.ENABLE;
			state := ST_QUIT;
		ELSIF axis.cplOn.Busy  THEN
			status.isCoupled := TRUE;
			status.mode := CONST.UNITMODEs.ENABLE;
			state := ST_QUIT;	
		ELSIF axis.ctrl.MC_ReadStatus_0.StandStill THEN 
			axis.cplOn(Execute := TRUE, Master := machineMasterCtrl.AxisREF, Slave := axis.ctrl.AxisREF,
						Acceleration := 40000, Deceleration := 40000 , RatioDenominator := axis.setGearRatio.ratioDenominator, 
						RatioNumerator := axis.setGearRatio.ratioNumeratorOut);	
			state := ST_CPL_WAIT;
		END_IF

	ST_CPL_WAIT:
		axis.cplOn( Master := machineMasterCtrl.AxisREF, Slave := axis.ctrl.AxisREF );
		IF axis.cplOn.Busy THEN
			axis.cplOn(Execute := FALSE, Master := machineMasterCtrl.AxisREF, Slave := axis.ctrl.AxisREF);
				status.isCoupled := TRUE;
				status.mode := CONST.UNITMODEs.ENABLE;
				state := ST_QUIT;
		ELSIF axis.cplOn.Error THEN
				err.id := axis.cplOn.ErrorID;
				err.fnc := 'axis.cplOn';
				err.state := state;
				state := ST_ERROR;
(*			ELSIF axis.cplOn.CommandAborted THEN
				err.fnc := 'axis.cplOn CommandAborted';
				err.state := state;
				state := ST_ERROR; 
			ELSIF axis.cplOn.InGear THEN *)
		END_IF

	ST_CPLOFF_START:
		IF cmd = CONST.CUTTINGUNIT.CMDs.ABORT THEN
			state := ST_ABORT;
		ELSIF axis.cplOff.Error  THEN
			err.state := state;
			err.text := 'MC_GearOut';
			state := ST_ERROR;
		ELSIF axis.cplOff.Busy OR axis.cplOff.Execute THEN
			axis.cplOff(Execute := FALSE, Slave := axis.ctrl.AxisREF);
		ELSE
			axis.cplOff(Execute := TRUE, Slave := axis.ctrl.AxisREF);
			state := ST_CPLOFF_WAIT;
		END_IF

	ST_CPLOFF_WAIT:
		axis.cplOff( Slave := axis.ctrl.AxisREF );
		IF  axis.cplOff.Done THEN
			IF axis.cplOff.Error THEN
				err.id := axis.cplOff.ErrorID;
				err.fnc := 'axis.cplOff';
				err.state := state;
				state := ST_ERROR;
(*neu 20.08.14*)
			ELSE
				axis.cplOff.Execute := FALSE; 
				status.isCoupled := FALSE;
				IF cmd = CONST.CUTTINGUNIT.CMDs.MOVEBW OR cmd = CONST.CUTTINGUNIT.CMDs.MOVEFW THEN
					state := ST_MOVE_START;
				ELSE
				(*	status.mode := CONST.UNITMODEs.DISABLE;*)
					state := ST_QUIT;
				END_IF

			END_IF
			
		END_IF
//////////20.08.14 Kundenwunsch: um die Zugstation zu reinigen sollte man die joggen können
		ST_MOVE_START:
//		masterAxis.ctrl.ref.ReadStatus();
		IF cmd = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			busy := FALSE;
			state := ST_IDLE;
		ELSIF axis.ctrl.MC_ReadStatus_0.SynchronizedMotion THEN 
//			err.text := 'MOVE nicht möglich. Achse ist gekoppelt';
//			err.state := state;
			state := ST_CPLOFF_START;
//		ELSIF status.isCalibrated THEN (* die Stanze soll man auch ohne zu rferenzieren drehen können*)
//			IF axis.ctrl.busy (*OR axis.ctrl.cmd <> CONST.AXIS.NOACTION*) THEN
//				axis.ctrl(cmd := CONST.AXIS.NOACTION);
		ELSIF axis.ctrl.MC_ReadStatus_0.StandStill OR axis.ctrl.MC_ReadStatus_0.ContinuousMotion THEN	
			IF cmd = CONST.CUTTINGUNIT.CMDs.MOVEBW THEN
				axis.ctrl(cmd := CONST.AXIS.JOG_NEG, velocity := 4);
				state := ST_MOVE_WAIT;
			ELSE
				axis.ctrl(cmd := CONST.AXIS.JOG_POS, velocity := 4);
				state := ST_MOVE_WAIT;
			END_IF
		END_IF
		
	ST_MOVE_WAIT:
		axis.ctrl();
		IF cmd = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			axis.ctrl(cmd := CONST.AXIS.NOACTION );
			state := ST_MOVE_QUIT;
		END_IF
//
	ST_MOVE_QUIT: (* hier evtl. koppeln*)
		state := ST_CPL_START;
		(*state := ST_QUIT;*)

	ST_ERROR:
		IF LEN(err.fnc) < 1 THEN
			err.fnc := 'FB_PullBrakeUnitConfig';
		END_IF
		err.flag := TRUE;
		state := ST_QUIT;

	ST_ABORT:
		state := ST_ABORT_QUIT;

	ST_ABORT_QUIT:
		busy := FALSE;
		IF cmd <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			state := ST_IDLE;
		END_IF

	ST_QUIT:
		IF cmd = CONST.CUTTINGUNIT.CMDs.ABORT THEN
			busy := TRUE;
			state := ST_ABORT;
		ELSE
			busy := FALSE;
			IF cmd = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
				state := ST_IDLE;
			END_IF
		END_IF
	END_CASE
END_FUNCTION_BLOCK