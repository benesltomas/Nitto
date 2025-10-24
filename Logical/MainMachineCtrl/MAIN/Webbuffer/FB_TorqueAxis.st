(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_TorqueAxis.st
 * Autor: awalz
 * Erstellt: 11. Juli 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_TorqueAxis
	(********************MC_BR_READDRIVESTATUS***********************)
	MC_BR_ReadDriveStatus_0.Enable := NOT(MC_BR_ReadDriveStatus_0.Error);
	MC_BR_ReadDriveStatus_0.Axis := AxisREF;
	MC_BR_ReadDriveStatus_0.AdrDriveStatus := ADR(BasicControl.Status.DriveStatus);
	MC_BR_ReadDriveStatus_0();
	(************************ MC_READSTATUS *************************)
	MC_ReadStatus_0.Enable :=  NOT MC_ReadStatus_0.Error;
	MC_ReadStatus_0.Axis := AxisREF;
	MC_ReadStatus_0();  
	//*****************************************************************
	IF enablemerker THEN
		MC_TorqueControl_0.Execute := TRUE;(*wieder einschalten*)
		enablemerker := FALSE;
	END_IF
	IF MC_TorqueControl_0.Torque <> settorque OR MC_TorqueControl_0.Velocity <> setvelocity AND MC_TorqueControl_0.Active THEN
		MC_TorqueControl_0.Execute := FALSE;
		enablemerker := TRUE;
	END_IF

	MC_TorqueControl_0.TorqueRamp 	:= 1;
	MC_TorqueControl_0.Velocity 	:= setvelocity; (*300;*)
	MC_TorqueControl_0.Acceleration := 1000;
	MC_TorqueControl_0.Axis			:= AxisREF; 
	MC_TorqueControl_0.Torque 		:= settorque;

	IF MC_TorqueControl_0.Execute AND MC_TorqueControl_0.CommandAborted AND cmdtmp = CONST.AXIS.START THEN
		MC_TorqueControl_0.Execute := FALSE;
	ELSIF NOT MC_TorqueControl_0.Execute  AND cmdtmp = CONST.AXIS.POWER_ON AND NOT MC_TorqueControl_0.Error AND MC_ReadStatus_0.StandStill THEN
		MC_TorqueControl_0.Execute := TRUE;
	ELSIF MC_TorqueControl_0.Error AND cmdtmp = CONST.AXIS.START THEN
		MC_TorqueControl_0.Execute := FALSE;
	END_IF
	IF NOT( MC_ReadStatus_0.StandStill OR MC_ReadStatus_0.ContinuousMotion OR MC_ReadStatus_0.DiscreteMotion OR MC_ReadStatus_0.SynchronizedMotion) THEN
			MC_TorqueControl_0.Execute := FALSE;
	END_IF

	IF 	cmd = CONST.AXIS.START AND NOT MC_TorqueControl_0.InTorque THEN
		MC_Stop_0.Execute := FALSE;
		MC_TorqueControl_0.Execute := TRUE;
		cmdtmp := cmd;
		cmd:= CONST.AXIS.NOACTION;
	END_IF
	//********************************************************************	
	MC_Stop_0.Deceleration	:= 2000;
	IF cmd = CONST.AXIS.STOP THEN
		IF  MC_ReadStatus_0.ContinuousMotion OR MC_ReadStatus_0.DiscreteMotion THEN
				MC_TorqueControl_0.Execute := FALSE;
				MC_Stop_0.Execute := TRUE;
		END_IF
		IF MC_Stop_0.Done THEN 
			MC_Stop_0.Execute := FALSE;
			cmdtmp := cmd;
			cmd := CONST.AXIS.NOACTION;
		END_IF
	END_IF
	(***************************************************************
        FUNCTION Block Calls
	(************************** MC_STOP *****************************)
	MC_Stop_0.Axis := AxisREF;
	MC_Stop_0();
	IF BasicControl.Status.DriveStatus.NetworkInit THEN
		MC_TorqueControl_0();
	END_IF	
//	(************************** MC_POWER ****************************)
//	MC_Power_0.Axis := AxisREF;  (* pointer to axis *)
//	MC_Power_0(); (*Laut B& R darf man den FB nicht zwei mal für die selbe Achse aufrufen*)
	(************************** MC_RESET ****************************)
//	MC_Reset_0.Axis := AxisREF;
//	MC_Reset_0();
END_FUNCTION_BLOCK