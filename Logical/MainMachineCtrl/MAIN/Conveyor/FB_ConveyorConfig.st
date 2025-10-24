(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_ConveyorConfig.st
 * Autor: Awalz
 * Erstellt: 12. Mai 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

 (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_ConveyorConfig
	TOF_delay.PT := T#1s;  //OKrebs 08.09.21
	TOF_delay.PT := T#1s;  //OKrebs 08.09.21
	axis.cplOn( Master := machineMasterCtrl.AxisREF, Slave := axis.ctrl.AxisREF);
 	axis.cplOff( Slave := axis.ctrl.AxisREF);
	CASE state OF
	ST_IDLE:
		IF cmd <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			busy := TRUE;
			err(reset:= TRUE);
			cmdtmp := cmd;
			IF cmd = CONST.CUTTINGUNIT.CMDs.CPL_ON THEN
				state := ST_CPL_START;
			ELSIF cmd = CONST.CUTTINGUNIT.CMDs.CPL_OFF THEN		
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
			Acceleration := 20000, Deceleration := 20000 , RatioDenominator := 1000, RatioNumerator := axis.setGearRatio.ratioDenominator(* 1000*));	
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
			axis.cplOff(Execute := FALSE, Slave := axis.ctrl.AxisREF );
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
			ELSE
				axis.cplOff.Execute := FALSE; 
				status.isCoupled := FALSE;
				IF cmd = CONST.CUTTINGUNIT.CMDs.MOVEBW OR cmd = CONST.CUTTINGUNIT.CMDs.MOVEFW THEN
					state := ST_MOVE_START;
				ELSE
			
					state := ST_QUIT;
				END_IF
			END_IF
			
		END_IF
//	ST_MOVE_START:
//			//		masterAxis.ctrl.ref.ReadStatus();
//		IF cmd = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
//			busy := FALSE;
//			state := ST_IDLE;
//		ELSIF axis.ctrl.MC_ReadStatus_0.SynchronizedMotion THEN 
//				//			err.text := 'MOVE nicht möglich. Achse ist gekoppelt';
//				//			err.state := state;
//			state := ST_CPLOFF_START;
//				//		ELSIF status.isCalibrated THEN (* die Stanze soll man auch ohne zu rferenzieren drehen können*)
//				//			IF axis.ctrl.busy (*OR axis.ctrl.cmd <> CONST.AXIS.NOACTION*) THEN
//				//				axis.ctrl(cmd := CONST.AXIS.NOACTION);
//		ELSIF axis.ctrl.MC_ReadStatus_0.StandStill OR axis.ctrl.MC_ReadStatus_0.ContinuousMotion THEN	
//			IF cmd = CONST.CUTTINGUNIT.CMDs.MOVEBW THEN
//				axis.ctrl(cmd := CONST.AXIS.JOG_NEG, velocity := 4);
//				state := ST_MOVE_WAIT;
//			ELSE
//				axis.ctrl(cmd := CONST.AXIS.JOG_POS, velocity := 4);
//				state := ST_MOVE_WAIT;
//			END_IF
//		END_IF

		//***********************neu********************// OKrebs 14.01.16		
		ST_MOVE_START:// 40	
			TON_delay.IN := cmd = CONST.CUTTINGUNIT.CMDs.MOVEBW OR cmd = CONST.CUTTINGUNIT.CMDs.MOVEFW;  //OKrebs 08.09.21
			TOF_delay.IN := cmd = CONST.CUTTINGUNIT.CMDs.MOVEBW OR cmd = CONST.CUTTINGUNIT.CMDs.MOVEFW;  //OKrebs 08.09.21
			IF NOT axis.MC_BR_Phasing_0.Busy  AND axis.ctrl.MC_ReadStatus_0.SynchronizedMotion AND cmd <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN								
				IF cmd = CONST.CUTTINGUNIT.CMDs.MOVEBW AND TON_delay.Q THEN	
					axis.MC_BR_Phasing_0.Acceleration := 90000;
					axis.MC_BR_Phasing_0.ApplicationMode := mcVELOCITY_CONTROL ;
					axis.MC_BR_Phasing_0.Slave := axis.ctrl.AxisREF;
					axis.MC_BR_Phasing_0.Velocity := - 16666.67 * 3; //1m/min
					axis.MC_BR_Phasing_0.Enable := TRUE;
					axis.MC_BR_Phasing_0.InitData := TRUE;			
					axis.MC_BR_Phasing_0.PerformVelocityControl := TRUE;
				ELSIF cmd = CONST.CUTTINGUNIT.CMDs.MOVEFW AND TON_delay.Q THEN
					axis.MC_BR_Phasing_0.Acceleration := 90000;
					axis.MC_BR_Phasing_0.ApplicationMode := mcVELOCITY_CONTROL;
					axis.MC_BR_Phasing_0.Slave := axis.ctrl.AxisREF;
					axis.MC_BR_Phasing_0.Velocity := 16666.67 * 3; //1m/min
					axis.MC_BR_Phasing_0.Enable := TRUE;
					axis.MC_BR_Phasing_0.InitData := TRUE;
					axis.MC_BR_Phasing_0.PerformVelocityControl := TRUE;
				END_IF	
			ELSIF cmd =  CONST.CUTTINGUNIT.CMDs.NO_CMD AND axis.ctrl.MC_ReadStatus_0.SynchronizedMotion THEN
				axis.MC_BR_Phasing_0.Velocity := 0;
				axis.MC_BR_Phasing_0.PerformVelocityControl := FALSE;
				axis.MC_BR_Phasing_0.InitData := FALSE;
				IF axis.MC_BR_Phasing_0.ShiftAttained OR EDGENEG(TOF_delay.Q) THEN
					axis.MC_BR_Phasing_0.Enable := FALSE;
					state := ST_QUIT;	
				END_IF
			ELSIF cmd =  CONST.CUTTINGUNIT.CMDs.NO_CMD AND (axis.ctrl.MC_ReadStatus_0.StandStill OR axis.ctrl.MC_ReadStatus_0.ContinuousMotion) THEN
				axis.ctrl(cmd := CONST.AXIS.NOACTION);
				state := ST_QUIT;	
			ELSIF  axis.ctrl.MC_ReadStatus_0.Disabled THEN
				state := ST_QUIT;	
			ELSE 
				
			END_IF

		//******************************************************************************		
		
		
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
			err.fnc := 'FB_ConveyorConfig';
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
	axis.MC_BR_Phasing_0();	//OKrebs 14.01.16	
	TOF_delay(); //OKrebs 08.09.21	
	TON_delay(); //OKrebs 08.09.21	
END_FUNCTION_BLOCK