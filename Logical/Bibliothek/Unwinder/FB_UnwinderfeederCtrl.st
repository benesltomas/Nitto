(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_UnwinderfeederCtrl.st
 * Autor: awalz
 * Erstellt: 24. Juni 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_UnwinderfeederCtrl
		UnwFeeder_HW;
		UnwFeeder_DrvIf;
		UnwFeeder_DiDoIf;
	
	// INITIALISATION
	IF firststart THEN
	pAxis ACCESS axisREF;
	 (*force variable offset generation *)
	(*pAxis.size                      := pAxis.size;*)
	
	MC_BR_JogVelocity_0.Axis			:= axisREF;
	MC_BR_JogVelocity_0.Velocity		:= 80.0;
	MC_BR_JogVelocity_0.Acceleration	:= 5000.0;
	MC_BR_JogVelocity_0.Deceleration	:= 5000.0;
	
	firststart := FALSE;
	END_IF	
	buttonLeftOpSide(clk := clk);  			// Taster fahre nach links auf der Antriebsseite
	buttonLeftDrvSide(clk := clk);			// Taster fahre nach links auf der Antriebsseite
	buttonRightOpSide(clk := clk);			// Taster fahre nach rechts auf der Bedienerseite
	buttonRightDrvSide (clk := clk);		// Taster fahre nach rechts auf der Antriebsseite
	buttonRequestOpSide(clk := clk);		// Taster für Rolenwechselanfrage
	buttonRequestDrvSide(clk := clk);		// Taster für Rolenwechselanfrage
	MC_Power_0.Axis := axisREF;
	MC_Stop_0.Axis := axisREF;
	MC_Reset_0.Axis := axisREF;
	
	(********************MC_BR_READDRIVESTATUS***********************)
	MC_BR_ReadDriveStatus_0.Enable := NOT(MC_BR_ReadDriveStatus_0.Error);
	MC_BR_ReadDriveStatus_0.Axis := axisREF;
	MC_BR_ReadDriveStatus_0.AdrDriveStatus := ADR(BasicControl.Status.DriveStatus);
	(************************ MC_READSTATUS *************************)
	MC_ReadStatus_0.Enable :=  NOT MC_ReadStatus_0.Error;
	MC_ReadStatus_0.Axis := axisREF;
	MC_ReadStatus_0();
//	UnwFeeder_HW. : SdcHwCfg_typ := (0);
//		UnwFeeder_DrvIf.oBrake : SdcDrvIf16_typ := (0);
//		UnwFeeder_DiDoIf : SdcDiDoIf_typ := (0);
	CASE AxisStep OF
	STATE_READY:
			IF cmd <> CONST.AXIS.NOACTION THEN
					busy := TRUE;
					cmdtmp:= cmd; 
					IF cmd = CONST.AXIS.RESET THEN 
						AxisStep := STATE_ERROR_RESET;
					ELSIF   cmd = CONST.AXIS.POWER_OFF THEN   
						AxisStep := STATE_POWER_OFF;  
					ELSIF   cmd = CONST.AXIS.POWER_ON THEN   
						AxisStep := STATE_POWER_ON;  
 					END_IF
			END_IF

	STATE_POWER_ON: 				
	IF UnwFeeder_ModuleOk AND cmd = CONST.AXIS.POWER_ON AND NOT MC_Power_0.Status 
		AND  BasicControl.Status.DriveStatus.ControllerReady AND NOT MC_Power_0.Error  THEN 
		MC_Power_0.Enable := TRUE;
	ELSIF	 MC_Power_0.Status THEN
			cmdtmp := cmd;
			AxisStep := STATE_QUIT;
	ELSIF (MC_Power_0.Error AND cmd = CONST.AXIS.POWER_ON ) OR( MC_ReadStatus_0.Errorstop AND cmd = CONST.AXIS.POWER_ON) THEN 
			MC_Power_0.Enable := FALSE;
			cmdtmp := cmd;
			cmd := CONST.AXIS.RESET	;
			AxisStep := STATE_ERROR_RESET;
	ELSIF NOT UnwFeeder_ModuleOk OR  NOT BasicControl.Status.DriveStatus.ControllerReady THEN
			cmdtmp := cmd;
			AxisStep := STATE_QUIT;
	END_IF


	STATE_POWER_OFF:
		MC_Power_0.Enable := FALSE;
			IF NOT MC_Power_0.Status THEN
				cmdtmp := cmd;
				(*AxisStep := STATE_READY;*)
				AxisStep := STATE_QUIT;
			END_IF
			(* if a power error occured go to error state *)
			IF MC_Power_0.Error  THEN
				BasicControl.Status.ErrorID := MC_Power_0.ErrorID;
				cmd := CONST.AXIS.RESET;	
				AxisStep := STATE_ERROR_RESET;
			END_IF


	STATE_ERROR_RESET:	
		IF cmd = CONST.AXIS.RESET THEN
			MC_Power_0.Enable := FALSE;
			MC_Reset_0.Execute := TRUE;
			IF MC_Reset_0.Done THEN
				MC_Reset_0.Execute := FALSE;
				cmdtmp := cmd;
				AxisStep := STATE_QUIT;
			END_IF
		END_IF

	STATE_QUIT:
			busy := FALSE;
			IF cmd = cmdtmp THEN
				busy := FALSE;
				cmd := CONST.AXIS.NOACTION;
				AxisStep := STATE_READY;
			ELSIF cmd <> CONST.AXIS.NOACTION THEN
				busy := FALSE;
				AxisStep := STATE_READY;
			(*ELSIF cmd = CONST.AXIS.POWER_OFF THEN 
				cmdtmp := cmd;
				AxisStep := STATE_POWER_OFF;*)
			(*ELSIF cmd = CONST.AXIS.POWER_ON THEN 
				cmdtmp := cmd;
				AxisStep := STATE_POWER_ON;*)
			END_IF
	END_CASE


	timer_TP( IN:= Start_timer,PT:= T#1000ms);
	timer_TON(IN := braketimer,PT := T#500ms);
	timerOPside_TOF(IN := buttonRightOpSide.LDT.button OR buttonLeftOpSide.LDT.button OR buttonRequestOpSide.LDT.button,PT := T#40s);
	timerDrvside_TOF(IN := buttonRightDrvSide.LDT.button OR buttonLeftDrvSide.LDT.button OR buttonRequestDrvSide.LDT.button ,PT := T#40s);
	Start_timer := FALSE;
	CASE State OF
	ST_WAIT:			
			IF buttonRequestOpSide.LDT.button (*AND  MC_ReadStatus_0.StandStill*) THEN
				brakerelease := FALSE;
				UnwFeeder_DrvIf.oBrake := FALSE;
				horn := TRUE;
				MC_Power_0.Enable := TRUE;
				trigOPSide := TRUE;	
				Start_timer := TRUE;
			END_IF
			
			IF buttonRequestDrvSide.LDT.button (*AND  MC_ReadStatus_0.StandStill*) THEN
				brakerelease := FALSE;
				UnwFeeder_DrvIf.oBrake := FALSE;
				horn := TRUE;
				MC_Power_0.Enable := TRUE;				
				Start_timer := TRUE;
				trigDrvSide := TRUE;
//				IF NOT timer_TP.Q THEN
//				State := ST_REQUEST_DrvSide;
//				END_IF
			END_IF	
			IF NOT timer_TP.Q AND MC_ReadStatus_0.StandStill AND trigOPSide THEN
				trigOPSide := FALSE;
				State := ST_REQUEST_OpSide;
			ELSIF NOT timer_TP.Q AND MC_ReadStatus_0.StandStill AND trigDrvSide THEN
				trigDrvSide := FALSE;
				State := ST_REQUEST_DrvSide;
			END_IF	

		ST_REQUEST_OpSide:
			// Einmal hupen
			// Ampel gelb fängt an zu blinken
			// Taster LED request blinkt
			// beide Abwickler deaktivieren
			// Bremse aus
			MC_BR_JogVelocity_0.Enable	:= TRUE;
			brakerelease := TRUE;
			UnwFeeder_DrvIf.oBrake := TRUE;
			horn := FALSE;
			buttonRequestOpSide.LDT.aktion := CONST.LAMP.ON; (*Zeigt das der Abwickler verfahrbereit ist*)
			IF buttonRequestOpSide.LDT.button AND NOT buttonRightOpSide.LDT.button AND buttonLeftOpSide.LDT.button 
				AND LimitSwitchRight THEN
				MC_BR_JogVelocity_0.JogPositive		:= TRUE;
			ELSIF buttonRequestOpSide.LDT.button AND buttonRightOpSide.LDT.button AND NOT buttonLeftOpSide.LDT.button
				 AND LimitSwitchLeft THEN
				MC_BR_JogVelocity_0.JogNegative		:= TRUE;
			ELSE 
				MC_BR_JogVelocity_0.JogPositive		:= FALSE;
				MC_BR_JogVelocity_0.JogNegative		:= FALSE;
			END_IF
			IF (buttonRightOpSide.LDT.button AND buttonLeftOpSide.LDT.button) OR NOT timerOPside_TOF.Q THEN
				State := ST_END;
			ELSIF  buttonRequestDrvSide.LDT.button THEN
				MC_BR_JogVelocity_0.JogPositive		:= FALSE;
				MC_BR_JogVelocity_0.JogNegative		:= FALSE;
				State := ST_REQUEST_DrvSide;
			END_IF	

		ST_REQUEST_DrvSide:	
			MC_BR_JogVelocity_0.Enable	:= TRUE;
			brakerelease := TRUE;
			UnwFeeder_DrvIf.oBrake := TRUE;
			horn := FALSE;
			buttonRequestDrvSide.LDT.aktion := CONST.LAMP.ON; (*Zeigt das der Abwickler verfahrbereit ist*)
			IF buttonRequestDrvSide.LDT.button AND NOT buttonRightDrvSide.LDT.button AND buttonLeftDrvSide.LDT.button
				 AND LimitSwitchLeft THEN
				MC_BR_JogVelocity_0.JogNegative		:= TRUE;
			ELSIF buttonRequestDrvSide.LDT.button AND NOT buttonLeftDrvSide.LDT.button AND buttonRightDrvSide.LDT.button
				AND LimitSwitchRight THEN
				MC_BR_JogVelocity_0.JogPositive		:= TRUE;
			ELSE 
				MC_BR_JogVelocity_0.JogPositive		:= FALSE;
				MC_BR_JogVelocity_0.JogNegative		:= FALSE;
			END_IF
			IF (buttonLeftDrvSide.LDT.button AND buttonRightDrvSide.LDT.button) OR NOT timerDrvside_TOF.Q THEN 
				State := ST_END;
			ELSIF buttonRequestOpSide.LDT.button THEN
				MC_BR_JogVelocity_0.JogPositive		:= FALSE;
				MC_BR_JogVelocity_0.JogNegative		:= FALSE;
				State := ST_REQUEST_OpSide;
			END_IF
	
		ST_END:
			MC_BR_JogVelocity_0.Enable	:= FALSE;
			brakerelease := FALSE;
		(*	MC_Power_0.Enable := FALSE;*)
			braketimer := TRUE;
			buttonRequestOpSide.LDT.aktion 	:= CONST.LAMP.OFF;
			buttonRequestDrvSide.LDT.aktion := CONST.LAMP.OFF;
			MC_BR_JogVelocity_0.JogPositive	:= FALSE;
			MC_BR_JogVelocity_0.JogNegative	:= FALSE;
			UnwFeeder_DrvIf.oBrake 			:= FALSE;
			IF timer_TON.Q THEN 
				MC_Power_0.Enable := FALSE;
				braketimer := FALSE;
				State := ST_WAIT;
			END_IF
			// Einmal hupen
			// Taster LED blinkt nicht mehr
			// Ampel gelb blinkt nicht mehr
			// beide Abwickler aktivieren
			// Bremse an	
		
	END_CASE
	MC_BR_ReadDriveStatus_0();
	MC_Reset_0();
	MC_Power_0();
	MC_Stop_0();
	MC_BR_JogVelocity_0();

END_FUNCTION_BLOCK