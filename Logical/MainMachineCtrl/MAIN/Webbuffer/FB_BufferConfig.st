(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_BufferConfig.st
 * Autor: awalz
 * Erstellt: 10. Juli 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_BufferConfig

		(*axis.refSwitchConfig(Enable := TRUE, Axis := axis.ctrl.AxisREF);*)
		axis.ctrl.BasicControl.Parameter.Deceleration := 1000;
		axis.ctrl.BasicControl.Parameter.Acceleration := 1000;
		pAxis ACCESS axis.ctrl.AxisREF;
		axis.ctrl();
		
CASE state OF
	ST_IDLE:
		IF cmd <> CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			busy := TRUE;
			err(reset := TRUE);
			cmdtmp := cmd;
			IF cmd = CONST.CUTTINGUNIT.CMDs.ABORT THEN
				state := ST_ABORT;
			ELSE
				IF cmd = CONST.CUTTINGUNIT.CMDs.CALIBR THEN
					state := ST_INIT_START;
				ELSIF cmd = CONST.CUTTINGUNIT.CMDs.MOVEFW OR cmd = CONST.CUTTINGUNIT.CMDs.MOVEBW THEN
					state := ST_MOVE_START;
//				ELSE
//					busy := FALSE;
//					err.reset();
				END_IF
			END_IF
		END_IF
//

	(*ST_SET_MODULO:*)
		
	ST_INIT_START:
		axis();
		IF NOT axis.ctrl.MC_ReadStatus_0.Disabled THEN
			axis.ctrl.cmd := CONST.AXIS.POWER_OFF; 
		ELSE 
			axis.ctrl.cmd := CONST.AXIS.NOACTION; 
			IF NOT axis.ctrl.busy AND  axis.ctrl.MC_ReadStatus_0.Disabled THEN
				pAxis.dig_in.level.neg_hw_end := ncACTIV_HI + ncFORCE;
				pAxis.dig_in.level.pos_hw_end := ncACTIV_HI + ncFORCE;
				InitAxisSubjectPar.Axis := axis.ctrl.AxisREF;
				InitAxisSubjectPar.Subject := ncDIG_IN;
				InitAxisSubjectPar.Execute := TRUE;
				InitAxisSubjectPar();
				IF InitAxisSubjectPar.Done THEN 
				(*	axis.refSwitchConfig(Enable := TRUE);*)
				(*	axis.refSwitchConfig.Axis := axis.ctrl.AxisREF;*)
					InitAxisSubjectPar.Execute := FALSE;
					state := ST_REF_START;
				ELSIF InitAxisSubjectPar.Error THEN 
					err.text := 'Parameter ncDIG_IN nicht initialisiert';
					err.state := state;
					state := ST_ERROR;
				END_IF 
			END_IF
		END_IF

	
	ST_REF_START: 
		InitAxisSubjectPar();
		(*axis.refSwitchConfig();*)
		IF axis.ctrl.MC_ReadStatus_0.Disabled THEN 
			axis.ctrl.cmd := CONST.AXIS.POWER_ON; 
		ELSIF NOT axis.ctrl.busy AND axis.ctrl.MC_ReadStatus_0.StandStill THEN
		(*	axis.refSwitchConfig(Enable := TRUE);*)
			axis.ctrl.BasicControl.Parameter.HomeMode := mcHOME_LIMIT_SWITCH;
			axis.ctrl.cmd := CONST.AXIS.CALIBR; (* Achse referenzieren*)
			state := ST_CALIBR_WAIT;
		END_IF
		
	ST_CALIBR_WAIT:	
	(*	axis.refSwitchConfig();*)
		IF axis.ctrl.BasicControl.AxisState.Homed THEN 	
			(*axis.refSwitchConfig(Enable := FALSE);*)
			cmd := CONST.CUTTINGUNIT.CMDs.NO_CMD;
			axis.ctrl(cmd := CONST.AXIS.NOACTION);
			status.ready := TRUE;
			cmdtmp := cmd;
			state := ST_QUIT;(* Achse ist referenziert*)
		(*	state := ST_CALIBR_START_NULLPOS;*)
		ELSIF cmd <> CONST.CUTTINGUNIT.CMDs.CALIBR THEN 
			axis.ctrl(cmd := CONST.AXIS.STOP);
			state := ST_QUIT;	
		END_IF	


	ST_MOVE_START:
//		masterAxis.ctrl.ref.ReadStatus();
		IF cmd = CONST.CUTTINGUNIT.CMDs.NO_CMD THEN
			busy := FALSE;
			state := ST_IDLE;
		ELSE 	
			IF cmd = CONST.CUTTINGUNIT.CMDs.MOVEBW THEN
				axis.ctrl.velocity	:= 0.01;
				axis.ctrl.cmd := CONST.AXIS.JOG_NEG;
				state := ST_MOVE_WAIT;
			ELSE
				axis.ctrl.velocity := 0.02;
				axis.ctrl.cmd := CONST.AXIS.JOG_POS;
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
		state := ST_QUIT;


	ST_ERROR:
		IF LEN(err.fnc) < 1 THEN
			err.fnc := 'FB_CuttingConfig';
		END_IF
		err(flag := TRUE);
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
				axis.ctrl(cmd := CONST.AXIS.NOACTION);
				state := ST_IDLE;
			END_IF
		END_IF
		
	END_CASE
//InitAxisSubjectPar();
END_FUNCTION_BLOCK