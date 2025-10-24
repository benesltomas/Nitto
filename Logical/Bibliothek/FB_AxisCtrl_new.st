(********************************************************************
 * COPYRIGHT -- Nitto
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_AxisCtrl_new.st
 * Autor: s_spilker
 * Erstellt: 9. November 2015
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_AxisCtrl_new

(***************************************************************
        Control Sequence
***************************************************************)
(* status information is read before the step sequencer to attain a shorter reaction time *)
(************************ MC_READSTATUS *************************)
	MC_ReadStatus_0.Enable :=  NOT MC_ReadStatus_0.Error;
	MC_ReadStatus_0.Axis := AxisREF;
	MC_ReadStatus_0();  	
	(********************MC_BR_READDRIVESTATUS***********************)
	MC_BR_ReadDriveStatus_0.Enable := NOT(MC_BR_ReadDriveStatus_0.Error);
	MC_BR_ReadDriveStatus_0.Axis := AxisREF;
	MC_BR_ReadDriveStatus_0.AdrDriveStatus := ADR(BasicControl.Status.DriveStatus);
	MC_BR_ReadDriveStatus_0();
	(******************** MC_READACTUALPOSITION *********************)
	MC_ReadActualPosition_0.Enable := (NOT(MC_ReadActualPosition_0.Error));
	MC_ReadActualPosition_0.Axis := AxisREF;
	MC_ReadActualPosition_0();//B&R kennt wohl Ausgagstypen nicht

	(******************** MC_READACTUALVELOCITY *********************)
	MC_ReadActualVelocity_0.Enable := (NOT(MC_ReadActualVelocity_0.Error));
	MC_ReadActualVelocity_0.Axis := AxisREF;
	MC_ReadActualVelocity_0();

	(*********************+*Parameter schreiben**********************)
	(************************ MC_READAXISERROR **********************)
	MC_ReadAxisError_0.Enable := NOT(MC_ReadAxisError_0.Error);
	MC_ReadAxisError_0.Axis := AxisREF;
	MC_ReadAxisError_0.DataAddress := ADR(BasicControl.Status.ErrorText);
	MC_ReadAxisError_0.DataLength := SIZEOF(BasicControl.Status.ErrorText);
	MC_ReadAxisError_0.DataObjectName := 'acp10etxde';
	MC_ReadAxisError_0();
	(* central monitoring OF stop command attains a shorter reaction TIME in CASE OF emergency stop *)
	(******************CHECK FOR STOP COMMAND************************)	
	CASE AxisStep OF
					
					
//		******************* WAIT ************************
		STATE_WAIT:  (* STATE: Wait *)
			AxisStep := STATE_QUIT;

//		(********************Virtuelle Achse einschalten****)
		STATE_VAXIS_ON:
		
			IF MC_BR_ReadDriveStatus_0.Valid THEN 
				cmdtmp := Cmd;
				AxisStep := STATE_QUIT; 
			END_IF
		(******************** POWER ON **********************)
		STATE_POWER_ON:  (* STATE: Power on *)
			(*MC_Power_0.Enable := TRUE;*)
			MC_Power_0.Axis := AxisREF;
			MC_Power_0();
			IF BasicControl.Status.DriveStatus.ControllerReady AND	Cmd = CONST.AXIS.POWER_ON 
				AND NOT MC_Power_0.Status AND NOT MC_Power_0.Error THEN
				MC_Power_0.Enable := TRUE; (*erster Anlauf*)
					cmdtmp := Cmd;
			ELSIF MC_Power_0.Error AND cmdtmp = Cmd THEN 
					MC_Power_0.Enable := FALSE ;(* if a power error occured go to error state *)
					Cmd := CONST.AXIS.RESET;
					err.set := TRUE;
					err.fnc := 'FB_AxisCtrl';
					err.id  := MC_Power_0.ErrorID;
					err.state := AxisStep;
					AxisStep := STATE_ERROR_RESET;
			ELSIF 	MC_Power_0.Status AND NOT MC_Power_0.Error THEN 	
					cmdtmp := Cmd;
					AxisStep := STATE_QUIT;
			ELSIF MC_ReadStatus_0.Errorstop THEN (*24.07.14*)
					BasicControl.Status.ErrorID := MC_Power_0.ErrorID;
					err.set := TRUE;
					err.fnc := 'FB_AxisCtrl';
					err.id  := MC_Power_0.ErrorID;;
					err.state := AxisStep;
					AxisStep := STATE_ERROR;
			END_IF
		(******************* POWER OFF *********************)
		STATE_POWER_OFF:  (* STATE: Power off *)
			MC_Power_0.Axis := AxisREF;
			MC_Power_0.Enable := FALSE;
			MC_Power_0();
			IF NOT MC_Power_0.Status AND NOT MC_Power_0.Busy  THEN
				cmdtmp := Cmd;
				AxisStep := STATE_QUIT;
			END_IF
			(* if a power error occured go to error state *)
			IF MC_Power_0.Error  THEN
				BasicControl.Status.ErrorID := MC_Power_0.ErrorID;
				err.set := TRUE;
				err.fnc := 'FB_AxisCtrl';
				err.id  := MC_Power_0.ErrorID;
				err.state := AxisStep;
				AxisStep := STATE_ERROR;
			END_IF
		(******************** READY **********************)
		STATE_READY:  (* STATE: Waiting for commands *)
			IF Cmd <> CONST.AXIS.NOACTION THEN
					busy := TRUE;
					(*cmdtmp:= Cmd; *)
					IF Cmd = CONST.AXIS.RESET THEN 
						AxisStep := STATE_ERROR_RESET;
					ELSIF Cmd = CONST.AXIS.STOP  THEN
						MC_Stop_0.Execute := TRUE; 
						MC_Stop_0.Deceleration := Deceleration;
						AxisStep := STATE_STOP;
					ELSIF Cmd = CONST.AXIS.JOG_NEG THEN				
						MC_BR_JogVelocity_0.Enable := TRUE; 
						MC_BR_JogVelocity_0.Velocity := 16666*Velocity; 
						MC_BR_JogVelocity_0.Acceleration := Acceleration;
						MC_BR_JogVelocity_0.Deceleration  := Deceleration;
						MC_BR_JogVelocity_0.JogPositive := FALSE;
						MC_BR_JogVelocity_0.JogNegative := TRUE;
						AxisStep := STATE_JOG_NEGATIVE;
					ELSIF Cmd = CONST.AXIS.JOG_POS THEN	
						MC_BR_JogVelocity_0.Enable := TRUE; 
						MC_BR_JogVelocity_0.Velocity := 16666*Velocity; 
						MC_BR_JogVelocity_0.Acceleration := Acceleration;
						MC_BR_JogVelocity_0.Deceleration  := Deceleration;
						MC_BR_JogVelocity_0.JogPositive := TRUE;
						MC_BR_JogVelocity_0.JogNegative := FALSE;
						AxisStep := STATE_JOG_POSITIVE;
					ELSIF Cmd = CONST.AXIS.SETPOS THEN
						MC_MoveAbsolute_0(Execute := TRUE, Position := Position, Velocity := 16666*Velocity, Acceleration := Acceleration,
										Deceleration  := BasicControl.Parameter.Deceleration, Direction := mcPOSITIVE_DIR);
						AxisStep := STATE_MOVE_ABSOLUTE;
					ELSIF Cmd = CONST.AXIS.SETPOSREL THEN		
						MC_BR_JogLimitPosition_0.Enable := TRUE;
						MC_BR_JogLimitPosition_0.Velocity := 16666*Velocity; 
						MC_BR_JogLimitPosition_0.Acceleration := Acceleration;
						MC_BR_JogLimitPosition_0.Deceleration := Deceleration;
						MC_BR_JogLimitPosition_0.LastPosition := Position;
//						MC_BR_JogLimitPosition_0.FirstPosition := - 2147483647;//nicht vergessen 
						MC_BR_JogLimitPosition_0.JogPositive  := TRUE;
						MC_BR_JogLimitPosition_0.JogNegative  := FALSE;
						AxisStep := STATE_MOVE_ADDITIVE;
					ELSIF Cmd = CONST.AXIS.MOVE_VELOCITY THEN
							MC_MoveVelocity_0(Execute := TRUE, Velocity := 16666*Velocity, Acceleration := Acceleration,
												Deceleration  := Deceleration,	Direction := mcPOSITIVE_DIR);
						AxisStep := STATE_MOVE_VELOCITY;
					ELSIF Cmd = CONST.AXIS.SETPOSREL_NOLIMIT THEN
						MC_MoveAdditive_0(Execute := TRUE, Distance := Position, Velocity := 16666*Velocity, Acceleration := Acceleration,
										Deceleration  := Deceleration);
						AxisStep := STATE_MOVE_ADDITIVELIMIT;
					ELSIF Cmd = CONST.AXIS.MOVE_CYCLIC_VELOCITY THEN
						MC_BR_JogVelocity_0.Enable := TRUE; 
						MC_BR_JogVelocity_0.Velocity := 16666*Velocity; 
						MC_BR_JogVelocity_0.Acceleration := Acceleration;
						MC_BR_JogVelocity_0.Deceleration  := Deceleration;
						MC_BR_JogVelocity_0.JogPositive := TRUE;
						MC_BR_JogVelocity_0.JogNegative := FALSE;
						AxisStep := STATE_MOVE_CYCLIC_VELOCITY;
					ELSIF  Cmd = CONST.AXIS.CALIBR THEN
						MC_Home_0.Execute := TRUE;
						MC_Home_0.Position := BasicControl.Parameter.HomePosition; 
						MC_Home_0.HomingMode := BasicControl.Parameter.HomeMode; 
						AxisStep := STATE_HOME;
					ELSIF   Cmd = CONST.AXIS.POWER_OFF THEN   
						AxisStep := STATE_POWER_OFF;  
					ELSIF   Cmd = CONST.AXIS.POWER_ON THEN   
						AxisStep := STATE_POWER_ON;                                 
					END_IF		
			ELSE 
				busy := FALSE;
			END_IF
		(******************** HOME **********************)
		STATE_HOME:  (* STATE: start homing process *)
//			MC_Home_0.Axis := AxisREF;
//			MC_Home_0();
			IF MC_Home_0.Done AND Cmd = CONST.AXIS.CALIBR THEN
				MC_Home_0.Execute := FALSE;
				BasicControl.AxisState.Homed := TRUE;
			ELSIF BasicControl.AxisState.Homed  AND NOT MC_Home_0.Done THEN // Referenzierung beendet
				cmdtmp := Cmd;
				AxisStep := STATE_QUIT;
			ELSIF Cmd <> CONST.AXIS.CALIBR THEN //da nur der MC_Stop den Zustand Homing unterbrechen kann
				MC_Home_0.Execute 		:= FALSE;
				MC_Stop_0.Deceleration 	:= Deceleration;
				MC_Stop_0.Execute 		:= TRUE;
				AxisStep := STATE_STOP;
			ELSIF MC_Home_0.CommandAborted AND Cmd = CONST.AXIS.CALIBR THEN
				MC_Home_0.Execute := FALSE;
				AxisStep := STATE_READY;
			END_IF
			(* if a homing error occured go to error state *)
			IF MC_Home_0.Error  THEN
				MC_Home_0.Execute := FALSE;
				BasicControl.Status.ErrorID := MC_Home_0.ErrorID;
				err.set := TRUE;
				err.fnc := 'MC_Home_0';
				err.id  := MC_Home_0.ErrorID;
				err.text := BasicControl.Status.ErrorText[0];
				err.state := AxisStep;
				AxisStep := STATE_ERROR;
			END_IF
        
		(***********************HALT_MOVEMENT***************************)
		STATE_HALT:   (* STATE: Halt movement *)
			MC_Halt_0.Deceleration := Deceleration;
			MC_Halt_0.Execute := TRUE;
			IF MC_Halt_0.Done THEN
				MC_Halt_0.Execute := FALSE;
				cmdtmp := Cmd;
				AxisStep := STATE_QUIT;     
			END_IF
			(* check if error occured *)
			IF MC_Halt_0.Error  THEN
				BasicControl.Status.ErrorID := MC_Halt_0.ErrorID;
				MC_Halt_0.Execute := FALSE;
				err.set := TRUE;
				err.fnc := 'FB_AxisCtrl';
				err.id  := MC_Halt_0.ErrorID;
				err.state := AxisStep;
				AxisStep := STATE_ERROR;
			END_IF                                         

		(*********************** STOP MOVEMENT *************************)
		STATE_STOP:  (* STATE: Stop movement *)
		(*	MC_Stop_0.Execute := TRUE;*)
			(* if axis is stopped go to ready state *)
			MC_BR_JogVelocity_0.Axis := AxisREF;
			MC_BR_JogVelocity_0.Velocity := 16666*Velocity;
			MC_BR_JogVelocity_0();	
			MC_BR_JogLimitPosition_0.Axis := AxisREF;
			MC_BR_JogLimitPosition_0.Enable := FALSE;
			MC_BR_JogLimitPosition_0();	
			IF MC_Stop_0.Done OR MC_ReadStatus_0.StandStill THEN
				MC_Stop_0.Execute := FALSE;
				cmdtmp := Cmd;
				AxisStep := STATE_QUIT;
//			ELSIF MC_ReadStatus_0.Disabled THEN
//				MC_Stop_0.Execute := FALSE;
//				cmdtmp := Cmd;
//				AxisStep := STATE_QUIT;
			END_IF
			(* check if error occured *)
			IF MC_Stop_0.Error THEN
				BasicControl.Status.ErrorID := MC_Stop_0.ErrorID;
				MC_Stop_0.Execute := FALSE;
				err.set := TRUE;
				err.fnc := 'FB_AxisCtrl';
				err.id  := MC_Stop_0.ErrorID;
				err.state := AxisStep;
				AxisStep := STATE_ERROR;
			ELSIF MC_ReadStatus_0.Errorstop THEN 
		 		MC_Stop_0.Execute := FALSE;
				err.set := TRUE;
				err.fnc := 'FB_AxisCtrl';
				err.text  := BasicControl.Status.ErrorText[0];
				err.state := AxisStep;
				AxisStep := STATE_ERROR;
			END_IF

		(******************** START JOG MOVEMENT POSITVE **********************)
		STATE_JOG_POSITIVE:  (* STATE: Start jog movement in positive direction *)
			MC_BR_JogVelocity_0.Axis := AxisREF;
			MC_BR_JogVelocity_0.Velocity := 16666*Velocity;	
			MC_BR_JogVelocity_0();
		
			IF Cmd <> CONST.AXIS.JOG_POS  AND Cmd <> CONST.AXIS.STOP THEN
				MC_BR_JogVelocity_0.Enable := FALSE;
				cmdtmp := Cmd;
				IF NOT MC_BR_JogVelocity_0.Busy THEN 
					AxisStep := STATE_QUIT;
				END_IF
			ELSIF Cmd = CONST.AXIS.STOP THEN
				MC_BR_JogVelocity_0.Enable := FALSE;
				MC_Stop_0( Execute := TRUE, Deceleration := Deceleration);
				AxisStep := STATE_STOP; 
			END_IF 
			IF MC_BR_JogVelocity_0.Error THEN
				BasicControl.Status.ErrorID := MC_BR_JogVelocity_0.ErrorID;
				MC_BR_JogVelocity_0.Enable := FALSE;
				err.set := TRUE;
				err.fnc := 'FB_AxisCtrl';
				err.id := MC_BR_JogVelocity_0.ErrorID;
				err.state := AxisStep;
				AxisStep := STATE_ERROR;
			END_IF

		(******************** START JOG MOVEMENT NEGATIVE **********************)
		STATE_JOG_NEGATIVE:  (* STATE: Start jog movement in negative direction *)
			MC_BR_JogVelocity_0.Axis := AxisREF;
			MC_BR_JogVelocity_0.Velocity := 16666*Velocity;			
			MC_BR_JogVelocity_0();
			IF Cmd <> CONST.AXIS.JOG_NEG AND Cmd <> CONST.AXIS.STOP  THEN
				MC_BR_JogVelocity_0.Enable := FALSE;
				cmdtmp := Cmd;
				IF NOT MC_BR_JogVelocity_0.Busy THEN 
					AxisStep := STATE_QUIT;
				END_IF
			ELSIF Cmd = CONST.AXIS.STOP THEN
				MC_BR_JogVelocity_0.Enable := FALSE;
				MC_Stop_0( Execute := TRUE, Deceleration := Deceleration);
				AxisStep := STATE_STOP; 
			END_IF 
			IF MC_BR_JogVelocity_0.Error THEN
				BasicControl.Status.ErrorID := MC_BR_JogVelocity_0.ErrorID;
				MC_BR_JogVelocity_0.Enable := FALSE;
				err.set := TRUE;
				err.fnc := 'FB_AxisCtrl';
				err.id := MC_BR_JogVelocity_0.ErrorID;
				err.state := AxisStep;
				AxisStep := STATE_ERROR;
			END_IF

		(******************** START ABSOLUTE MOVEMENT **********************)
		STATE_MOVE_ABSOLUTE:  (* STATE: Start absolute movement *)
			(* check if commanded position is reached *)
			IF Cmd <> CONST.AXIS.SETPOS AND Cmd <> CONST.AXIS.STOP THEN
				MC_MoveAbsolute_0.Execute := FALSE;
				cmdtmp := Cmd;
				AxisStep := STATE_HALT;
			ELSIF MC_MoveAbsolute_0.Done  THEN
				MC_MoveAbsolute_0.Execute := FALSE;
				cmdtmp := Cmd;
				AxisStep := STATE_QUIT;
			ELSIF Cmd = CONST.AXIS.STOP THEN
				MC_MoveAbsolute_0.Execute := FALSE;
				MC_Stop_0( Execute := TRUE, Deceleration := Deceleration);
				AxisStep := STATE_STOP;  
			END_IF
			(* check if error occured *)
			IF MC_MoveAbsolute_0.Error THEN
				BasicControl.Status.ErrorID := MC_MoveAbsolute_0.ErrorID;
				MC_MoveAbsolute_0.Execute := TRUE;
				err.set := TRUE;
				err.fnc := 'FB_AxisCtrl';
				err.id  := MC_MoveAbsolute_0.ErrorID;
				err.state := AxisStep;
				AxisStep := STATE_ERROR;
			END_IF


		(******************** START ADDITIVE MOVEMENT **********************)
		STATE_MOVE_ADDITIVE:  (* STATE: Start additive movement *)
			(* check if commanded distance is reached *)
			//mit MC_MoveAdditive kann man die Geschwindigkeit nicht permanent ändern
			MC_BR_JogLimitPosition_0.Axis := AxisREF;
			MC_BR_JogLimitPosition_0.Velocity := 16666*Velocity;			
			MC_BR_JogLimitPosition_0();
			IF MC_BR_JogLimitPosition_0.LimitReached THEN
				MC_BR_JogLimitPosition_0.Enable := FALSE;
				cmdtmp := Cmd;
			ELSIF NOT MC_BR_JogLimitPosition_0.Busy  THEN 
					AxisStep := STATE_QUIT;
			ELSIF Cmd = CONST.AXIS.STOP THEN
				MC_BR_JogLimitPosition_0.Enable := FALSE;
				MC_Stop_0( Execute := TRUE, Deceleration := Deceleration);
				AxisStep := STATE_STOP; 
			END_IF 
			IF MC_BR_JogLimitPosition_0.Error THEN
				BasicControl.Status.ErrorID := MC_BR_JogLimitPosition_0.ErrorID;
				MC_BR_JogLimitPosition_0.Enable := FALSE;
				err.set := TRUE;
				err.fnc := 'FB_AxisCtrl';
				err.id := MC_BR_JogLimitPosition_0.ErrorID;
				err.text := BasicControl.Status.ErrorText[0];
				err.state := AxisStep;
				AxisStep := STATE_ERROR;
			END_IF



		STATE_MOVE_ADDITIVELIMIT:
			IF Cmd<> CONST.AXIS.SETPOSREL_NOLIMIT  THEN
				MC_MoveAdditive_0.Execute := FALSE;
				cmdtmp := Cmd;
				AxisStep := STATE_HALT;
			ELSIF MC_MoveAdditive_0.Done  THEN
				MC_MoveAdditive_0.Execute := FALSE;
					(*AxisStep := STATE_READY;*)
					cmdtmp := Cmd;
					AxisStep := STATE_QUIT;
			END_IF 
			(* check if error occured *)
			IF (MC_MoveAdditive_0.Error = TRUE) THEN
				BasicControl.Status.ErrorID := MC_MoveAdditive_0.ErrorID;
				MC_MoveAdditive_0.Execute := FALSE;
				AxisStep := STATE_ERROR;
			END_IF
			CyclicVelocity  := 16666*Velocity; 
			MC_BR_CyclicWrite_0.Axis		:= AxisREF;
			MC_BR_CyclicWrite_0.DataAddress	:= ADR(CyclicVelocity);
			MC_BR_CyclicWrite_0.DataType	:= ncPAR_TYP_REAL;
			MC_BR_CyclicWrite_0.ParID		:= ACP10PAR_VAR_R4_0 + 0;
			MC_BR_CyclicWrite_0();


		(******************** START VELOCITY MOVEMENT **********************)
		STATE_MOVE_VELOCITY:  (* STATE: Start velocity movement *)
			IF Cmd <>  CONST.AXIS.MOVE_VELOCITY  AND Cmd <> CONST.AXIS.STOP THEN
				MC_MoveVelocity_0.Execute := FALSE;
				cmdtmp := Cmd;
				AxisStep := STATE_HALT;
			ELSIF MC_MoveVelocity_0.InVelocity THEN
				MC_MoveVelocity_0.Execute := FALSE;
				cmdtmp := Cmd;
				AxisStep := STATE_QUIT;
			ELSIF Cmd = CONST.AXIS.STOP THEN
				MC_MoveVelocity_0.Execute := FALSE;
				MC_Stop_0( Execute := TRUE, Deceleration := Deceleration);
				AxisStep := STATE_STOP;  
			END_IF
			(* check if error occured *)
			IF MC_MoveVelocity_0.Error THEN
				BasicControl.Status.ErrorID := MC_MoveVelocity_0.ErrorID;
				MC_MoveVelocity_0.Execute := FALSE;
				err.set := TRUE;
				err.fnc := 'FB_AxisCtrl';
				err.id  := MC_MoveVelocity_0.ErrorID;
				err.state := AxisStep;
				AxisStep := STATE_ERROR;
			END_IF

		STATE_MOVE_CYCLIC_VELOCITY:
			MC_BR_JogVelocity_0.Axis := AxisREF;
			MC_BR_JogVelocity_0.Velocity := 16666*Velocity;
			MC_BR_JogVelocity_0();
			IF Cmd <> CONST.AXIS.MOVE_CYCLIC_VELOCITY AND Cmd <> CONST.AXIS.STOP THEN
				MC_BR_JogVelocity_0.Enable := FALSE;
				cmdtmp := Cmd;
				IF NOT MC_BR_JogVelocity_0.Busy THEN 
					AxisStep := STATE_QUIT;
				END_IF
			ELSIF Cmd = CONST.AXIS.STOP THEN
				MC_BR_JogVelocity_0.Enable := FALSE;
				MC_Stop_0( Execute := TRUE, Deceleration := Deceleration);
				AxisStep := STATE_STOP; 
			END_IF 
			IF MC_BR_JogVelocity_0.Error THEN
				BasicControl.Status.ErrorID := MC_BR_JogVelocity_0.ErrorID;
				MC_BR_JogVelocity_0.Enable := FALSE;
				err.set := TRUE;
				err.fnc := 'FB_AxisCtrl';
				err.id := MC_BR_JogVelocity_0.ErrorID;
				err.state := AxisStep;
				AxisStep := STATE_ERROR;
			END_IF
			


		(******************** FB-ERROR OCCURED *************************)

		STATE_ERROR:  (* STATE: Error *)
			(* check if FB indicates an axis error *)
			err();
			IF MC_ReadAxisError_0.AxisErrorCount<>0 THEN
				AxisStep := STATE_ERROR_AXIS;
			ELSE
				IF MC_ReadStatus_0.Errorstop AND MC_ReadStatus_0.Valid  THEN
					AxisStep := STATE_ERROR_AXIS;
				ELSIF Cmd = CONST.AXIS.RESET THEN 
					cmdtmp := Cmd;
					AxisStep := STATE_ERROR_RESET;
				END_IF
			END_IF

		(******************** AXIS-ERROR OCCURED *************************)
		STATE_ERROR_AXIS:  (* STATE: Axis Error *)
			IF MC_ReadAxisError_0.Valid THEN
				err.set := TRUE;
				err.text := BasicControl.Status.ErrorText[0];
				err.id :=  UINT_TO_DINT  (MC_ReadAxisError_0.AxisErrorID) ;
				err();
				IF MC_ReadAxisError_0.AxisErrorID <> 0 THEN
						BasicControl.Status.ErrorID := MC_ReadAxisError_0.AxisErrorID;
				END_IF
				MC_ReadAxisError_0.Acknowledge := FALSE;
				IF Cmd = CONST.AXIS.RESET THEN 
					IF MC_ReadAxisError_0.AxisErrorID <> 0 THEN
						MC_ReadAxisError_0.Acknowledge := TRUE;
						AxisStep := STATE_ERROR_RESET;
					END_IF
				END_IF
				IF MC_ReadAxisError_0.AxisErrorCount = 0 THEN
					(* reset axis if it is in axis state ErrorStop *)
					BasicControl.Status.ErrorID := 0;
					IF MC_ReadStatus_0.Errorstop AND MC_ReadStatus_0.Valid THEN
						AxisStep := STATE_ERROR_RESET;
					ELSE
						cmdtmp := Cmd;
						AxisStep := STATE_QUIT;
					END_IF
				ELSIF NOT MC_ReadAxisError_0.Error THEN
						cmdtmp := Cmd;
						AxisStep := STATE_QUIT;
				END_IF
			ELSE
				AxisStep := STATE_WAIT; (* kein Fehler liegt vor*)
			END_IF

		(******************** RESET DONE *************************)
		STATE_ERROR_RESET:  (* STATE: Wait for reset done *)
			MC_Reset_0.Execute := TRUE;
			MC_Power_0.Axis := AxisREF;
			MC_Power_0();
			MC_Home_0.Axis := AxisREF;
			MC_Home_0.Execute := FALSE;
			MC_Home_0();
			err.reset := TRUE;
			err();
			(* reset MC_Power.Enable if this FB is in Error*)
			IF MC_Power_0.Error THEN
				MC_Power_0.Enable := FALSE;
			END_IF
			IF MC_Reset_0.Done THEN
				MC_Reset_0.Execute := FALSE;
				cmdtmp := Cmd;
				AxisStep := STATE_QUIT;
			ELSIF MC_Reset_0.Error THEN
				MC_Reset_0.Execute := FALSE;
				AxisStep := STATE_ERROR;                    
			END_IF

		(******************** SEQUENCE END *************************)
		STATE_QUIT: 
//
//			busy := FALSE;
//			IF Cmd = cmdtmp THEN
//				busy := FALSE;
//				Cmd := CONST.AXIS.NOACTION;
//				AxisStep := STATE_READY;
//			ELSIF Cmd <> CONST.AXIS.NOACTION THEN
//				AxisStep := STATE_READY;
//			END_IF
		busy:=FALSE;
		IF Cmd <> cmdtmp THEN
			IF Cmd = CONST.AXIS.RESET THEN
				busy := TRUE;
				AxisStep := STATE_ERROR_RESET;
			ELSIF Cmd = CONST.AXIS.STOP THEN
				MC_Stop_0( Execute := TRUE, Deceleration := Deceleration);
				busy := TRUE;
				AxisStep := STATE_STOP;
			ELSE
				busy := FALSE;
				AxisStep := STATE_READY;
			END_IF
		ELSE
			Cmd := CONST.AXIS.NOACTION;
			AxisStep := STATE_READY;
		END_IF
	END_CASE

(***************************************************************
        FUNCTION Block Calls
***************************************************************)

(************************** MC_POWER ****************************)
//	MC_Power_0.Axis := AxisREF;  (* pointer to axis *)
//	MC_Power_0();
	(************************** MC_HOME *****************************)
	MC_Home_0.Axis := AxisREF;
	MC_Home_0();
	(********************** MC_MOVEABSOLUTE *************************)
	MC_MoveAbsolute_0.Acceleration := Acceleration;
	MC_MoveAbsolute_0.Deceleration := Deceleration;
	MC_MoveAbsolute_0.Axis := AxisREF;
	MC_MoveAbsolute_0();
	(********************** MC_MOVEADDITIVE *************************)
	MC_MoveAdditive_0.Acceleration := Acceleration;
	MC_MoveAdditive_0.Deceleration := Deceleration;
	MC_MoveAdditive_0.Axis := AxisREF;
	MC_MoveAdditive_0();
	(********************** MC_MOVEVELOCITY *************************)
	MC_MoveVelocity_0.Acceleration  := Acceleration;
	MC_MoveVelocity_0.Deceleration  := Deceleration;
	MC_MoveVelocity_0.Axis := AxisREF;
	MC_MoveVelocity_0();
	(************************** MC_STOP *****************************)
	MC_Stop_0.Axis := AxisREF;
	MC_Stop_0();
	(***************************MC_HALT******************************)
	MC_Halt_0.Axis := AxisREF;
	MC_Halt_0();
	(************************** MC_RESET ****************************)
	MC_Reset_0.Axis := AxisREF;
	MC_Reset_0();
END_FUNCTION_BLOCK