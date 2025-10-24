(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: Bibliothek
 * Datei: FB_AxisCtrl.st
 * Autor: awalz
 * Erstellt: 23. Juli 2014
 ********************************************************************
 * Implementierung der Library Bibliothek
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_AxisCtrl

(***************************************************************
        Control Sequence
***************************************************************)
(* status information is read before the step sequencer to attain a shorter reaction time *)
(************************ MC_READSTATUS *************************)
	MC_ReadStatus_0.Enable :=  NOT MC_ReadStatus_0.Error;
	MC_ReadStatus_0.Axis := AxisREF;
	MC_ReadStatus_0();  
	BasicControl.AxisState.Disabled             := MC_ReadStatus_0.Disabled;
	BasicControl.AxisState.StandStill           := MC_ReadStatus_0.StandStill;
	BasicControl.AxisState.Stopping             := MC_ReadStatus_0.Stopping;
	BasicControl.AxisState.Homing               := MC_ReadStatus_0.Homing;
	BasicControl.AxisState.DiscreteMotion       := MC_ReadStatus_0.DiscreteMotion;
	BasicControl.AxisState.ContinuousMotion     := MC_ReadStatus_0.ContinuousMotion;
	BasicControl.AxisState.SynchronizedMotion   := MC_ReadStatus_0.SynchronizedMotion;
	BasicControl.AxisState.ErrorStop            := MC_ReadStatus_0.Errorstop;
	
	(********************MC_BR_READDRIVESTATUS***********************)
	MC_BR_ReadDriveStatus_0.Enable := NOT(MC_BR_ReadDriveStatus_0.Error);
	MC_BR_ReadDriveStatus_0.Axis := AxisREF;
	MC_BR_ReadDriveStatus_0.AdrDriveStatus := ADR(BasicControl.Status.DriveStatus);
	MC_BR_ReadDriveStatus_0();
	
	(******************** MC_READACTUALPOSITION *********************)
	MC_ReadActualPosition_0.Enable := (NOT(MC_ReadActualPosition_0.Error));
	MC_ReadActualPosition_0.Axis := AxisREF;
	MC_ReadActualPosition_0();
	IF(MC_ReadActualPosition_0.Valid = TRUE)THEN
		BasicControl.Status.ActPosition := MC_ReadActualPosition_0.Position;
	END_IF

	(******************** MC_READACTUALVELOCITY *********************)
	MC_ReadActualVelocity_0.Enable := (NOT(MC_ReadActualVelocity_0.Error));
	MC_ReadActualVelocity_0.Axis := AxisREF;
	MC_ReadActualVelocity_0();
	IF(MC_ReadActualVelocity_0.Valid = TRUE)THEN
		BasicControl.Status.ActVelocity := MC_ReadActualVelocity_0.Velocity;
	END_IF
	(*********************+*Parameter schreiben**********************)
	MC_MoveVelocity_0.Acceleration  := ruck;
	MC_MoveVelocity_0.Deceleration  := ruck;
	MC_ReadStatus_0();
	(************************ MC_READAXISERROR **********************)
	MC_ReadAxisError_0.Enable := NOT(MC_ReadAxisError_0.Error);
	MC_ReadAxisError_0.Axis := AxisREF;
	MC_ReadAxisError_0.DataAddress := ADR(BasicControl.Status.ErrorText);
	MC_ReadAxisError_0.DataLength := SIZEOF(BasicControl.Status.ErrorText);
	MC_ReadAxisError_0.DataObjectName := 'acp10etxde';
	MC_ReadAxisError_0();
	(* central monitoring OF stop command attains a shorter reaction TIME in CASE OF emergency stop *)
	(******************CHECK FOR STOP COMMAND************************)
	(*IF (BasicControl.Command.Stop = TRUE) THEN*)
//	IF cmd = CONST.AXIS.STOP THEN //12.03.15
//		busy := TRUE;
//		IF ((AxisStep >= STATE_READY) AND (AxisStep < STATE_ERROR)) THEN
//			(* reset all FB execute inputs we use *)
//			MC_Home_0.Execute := 0;
//			MC_Stop_0.Execute := 0;
//			MC_MoveAbsolute_0.Execute := 0;
//			MC_MoveAdditive_0.Execute := 0;
//			MC_MoveVelocity_0.Execute := 0;
//			MC_ReadAxisError_0.Acknowledge := 0;
//			MC_Reset_0.Execute := 0;
//
//			(* reset user commands *)
//			BasicControl.Command.Stop := 0;
//			BasicControl.Command.Home := 0;
//			BasicControl.Command.MoveJogPos := 0;
//			BasicControl.Command.MoveJogNeg := 0;
//			BasicControl.Command.MoveVelocity := 0;
//			BasicControl.Command.MoveAbsolute := 0;
//			BasicControl.Command.MoveAdditive := 0;
//			MC_Stop_0( Execute := TRUE, Deceleration := verzoegerung);
//			AxisStep := STATE_STOP;
//		END_IF        
//	END_IF   
//	
////////////////////////////////////////////////////////////////////////////	 
//(*	IF AxisHandle[tempIndex].AxisState.Stopping THEN
//	    IF (AxisHandle[tempIndex].Status.ActVelocity = 0.0) THEN
//			AxisIf.Status.isMoving 						:= FALSE;
//			AllDrives.Status.stopActive					:= FALSE;
//		ELSE
//			AxisIf.Status.isMoving 						:= TRUE;
//		END_IF
//	ELSIF (NOT ( AxisHandle[tempIndex].AxisState.DiscreteMotion OR
//	             AxisHandle[tempIndex].AxisState.ContinuousMotion)) THEN
//		AxisIf.Status.isMoving 							:= FALSE;
//		AllDrives.Status.stopActive						:= FALSE;
//	ELSE
//		AxisIf.Status.isMoving 							:= TRUE;
//	END_IF*)
//////////////////////////////////////////////////////////////////////////////
//	(**************** CHECK FOR GENERAL AXIS ERROR ******************)
//(*	IF ((MC_ReadAxisError_0.AxisErrorID <> 0) AND (MC_ReadAxisError_0.Valid)) THEN
//		AxisStep := STATE_ERROR_AXIS;
//		(***************** CHECK IF POWER SHOULD BE OFF *******************)
//(*	ELSIF ((NOT BasicControl.Command.Power) AND (MC_ReadAxisError_0.Valid)) THEN
//		IF ((MC_ReadStatus_0.Errorstop) AND (MC_ReadStatus_0.Valid )) THEN
//			AxisStep := STATE_ERROR_RESET;
//		ELSE
//			AxisStep := STATE_WAIT;
//		END_IF
//	END_IF*)
	
	CASE AxisStep OF
					
					
//		******************* WAIT ************************
		STATE_WAIT:  (* STATE: Wait *)
			AxisStep := STATE_QUIT;
//			(*IF (BasicControl.Command.Power = TRUE) THEN*)
//			IF cmd = CONST.AXIS.POWER_ON THEN 
//				cmdtmp := cmd;
//				AxisStep := STATE_POWER_ON;
//			ELSIF cmd = CONST.AXIS.VAXIS_ON THEN 
//				cmdtmp := cmd;
//				AxisStep := STATE_VAXIS_ON;
//			ELSIF cmd = CONST.AXIS.POWER_OFF THEN 
//				cmdtmp := cmd;
//				AxisStep := STATE_POWER_OFF;
//			ELSE
//				MC_Power_0.Enable := FALSE;
//			END_IF	
//			
//			(* reset all FB execute inputs we use *)
//			MC_Home_0.Execute := FALSE;
//			MC_Stop_0.Execute := FALSE;
//			MC_MoveAbsolute_0.Execute := FALSE;
//			MC_MoveAdditive_0.Execute := FALSE;
//			MC_MoveVelocity_0.Execute := FALSE;
//			MC_ReadAxisError_0.Acknowledge := FALSE;
//			MC_Reset_0.Execute := FALSE;
//			(* reset user commands *)
//			BasicControl.Command.Stop := FALSE;
//			BasicControl.Command.Home := FALSE;
//			BasicControl.Command.MoveJogPos := FALSE;
//			BasicControl.Command.MoveJogNeg := FALSE;
//			BasicControl.Command.MoveVelocity := FALSE;
//			BasicControl.Command.MoveAbsolute := FALSE;
//			BasicControl.Command.MoveAdditive := FALSE;
//
//			BasicControl.Status.ErrorID := 0;
//		(********************Virtuelle Achse einschalten****)
		STATE_VAXIS_ON:
		
			IF MC_BR_ReadDriveStatus_0.Valid THEN 
				cmdtmp := cmd;
				AxisStep := STATE_QUIT;
			END_IF
		(******************** POWER ON **********************)
		STATE_POWER_ON:  (* STATE: Power on *)
			(*MC_Power_0.Enable := TRUE;*)
			IF BasicControl.Status.DriveStatus.ControllerReady AND	cmd = CONST.AXIS.POWER_ON 
				AND NOT MC_Power_0.Status AND NOT MC_Power_0.Error THEN
				MC_Power_0.Enable := TRUE; (*erster Anlauf*)
					cmdtmp := cmd;
			ELSIF MC_Power_0.Error AND cmdtmp = cmd THEN 
					MC_Power_0.Enable := FALSE ;(* if a power error occured go to error state *)
					cmd := CONST.AXIS.RESET;
					AxisStep := STATE_ERROR_RESET;
			ELSIF 	MC_Power_0.Status AND NOT MC_Power_0.Error THEN 	
					cmdtmp := cmd;
					AxisStep := STATE_QUIT;
		(*	ELSIF MC_Power_0.Error AND cmdtmp <> cmd THEN
					BasicControl.Status.ErrorID := MC_Power_0.ErrorID;
					AxisStep := STATE_ERROR;*)
			ELSIF MC_ReadStatus_0.Errorstop THEN (*24.07.14*)
					BasicControl.Status.ErrorID := MC_Power_0.ErrorID;
					cmdtmp := cmd;
					AxisStep := STATE_ERROR;
			END_IF
		(******************** POWER OFF **********************)
		STATE_POWER_OFF:  (* STATE: Power on *)
			MC_Power_0.Enable := FALSE;
			IF NOT MC_Power_0.Status THEN
				cmdtmp := cmd;
				(*AxisStep := STATE_READY;*)
				AxisStep := STATE_QUIT;
			END_IF
			(* if a power error occured go to error state *)
			IF MC_Power_0.Error  THEN
				BasicControl.Status.ErrorID := MC_Power_0.ErrorID;
				AxisStep := STATE_ERROR;
			END_IF
		(******************** READY **********************)
		STATE_READY:  (* STATE: Waiting for commands *)
			IF cmd <> CONST.AXIS.NOACTION THEN
					busy := TRUE;
					(*cmdtmp:= cmd; *)//13.03.15
					IF cmd = CONST.AXIS.RESET THEN 
						AxisStep := STATE_ERROR_RESET;
					ELSIF cmd = CONST.AXIS.STOP THEN
						MC_Stop_0( Execute := TRUE, Deceleration := verzoegerung);
						AxisStep := STATE_STOP;
					ELSIF cmd = CONST.AXIS.JOG_NEG THEN
						MC_MoveVelocity_0(Execute := TRUE, Velocity := 16666*velocity, Acceleration := BasicControl.Parameter.Acceleration,
										Deceleration  := BasicControl.Parameter.Deceleration, Direction := mcNEGATIVE_DIR);
						AxisStep := STATE_JOG_NEGATIVE;
					ELSIF cmd = CONST.AXIS.JOG_POS THEN	
						MC_MoveVelocity_0(Execute := TRUE, Velocity := 16666*velocity, Acceleration := BasicControl.Parameter.Acceleration,
										Deceleration  := BasicControl.Parameter.Deceleration,Direction := mcPOSITIVE_DIR);
						AxisStep := STATE_JOG_POSITIVE;
					ELSIF cmd = CONST.AXIS.SETPOS THEN
						MC_MoveAbsolute_0(Execute := TRUE, Position := position, Velocity := 16666*velocity, Acceleration := BasicControl.Parameter.Acceleration,
										Deceleration  := BasicControl.Parameter.Deceleration, Direction := mcPOSITIVE_DIR);
						AxisStep := STATE_MOVE_ABSOLUTE;
					ELSIF  cmd = CONST.AXIS.CALIBR THEN
						(*Achse referenzieren*)
						AxisStep := STATE_HOME;
					ELSIF cmd = CONST.AXIS.MOVE_VELOCITY THEN
//							MC_MoveVelocity_0.Acceleration  := BasicControl.Parameter.Acceleration;
//							MC_MoveVelocity_0.Deceleration  := BasicControl.Parameter.Deceleration;
							MC_MoveVelocity_0(Execute := TRUE, Velocity := 16666*velocity, Acceleration := BasicControl.Parameter.Acceleration,
												Deceleration  := BasicControl.Parameter.Deceleration,	Direction := mcPOSITIVE_DIR);
						AxisStep := STATE_MOVE_VELOCITY;
					ELSIF   cmd = CONST.AXIS.POWER_OFF THEN   
						AxisStep := STATE_POWER_OFF;  
					ELSIF   cmd = CONST.AXIS.POWER_ON THEN   
						AxisStep := STATE_POWER_ON;                                 
					END_IF		
			ELSE 
				busy := FALSE;
			END_IF
		(******************** HOME **********************)
		STATE_HOME:  (* STATE: start homing process *)
			MC_Home_0.Position := BasicControl.Parameter.HomePosition;
			MC_Home_0.HomingMode := BasicControl.Parameter.HomeMode;
			MC_Home_0.HomingMode := mcHOME_SWITCH_GATE;
			MC_Home_0.Execute := TRUE;
			IF MC_Home_0.Done AND cmd = CONST.AXIS.CALIBR THEN
				MC_Home_0.Execute := FALSE;
				BasicControl.AxisState.Homed := TRUE;
				cmdtmp := cmd;
				AxisStep := STATE_QUIT;
			ELSIF cmd <> CONST.AXIS.CALIBR THEN 
				MC_Home_0.Execute := FALSE;
				MC_Stop_0( Execute := TRUE, Deceleration := verzoegerung);
				AxisStep := STATE_STOP;
			END_IF
			
			(* if a homing error occured go to error state *)
			IF MC_Home_0.Error  OR MC_ReadStatus_0.Errorstop THEN
				MC_Home_0.Execute := FALSE;
				BasicControl.Status.ErrorID := MC_Home_0.ErrorID;
				AxisStep := STATE_ERROR;
			END_IF
        
		(***********************HALT_MOVEMENT***************************)
		STATE_HALT:   (* STATE: Halt movement *)
			MC_Halt_0.Deceleration := BasicControl.Parameter.Deceleration;
			MC_Halt_0.Execute := TRUE;
			IF MC_Halt_0.Done THEN
				MC_Halt_0.Execute := FALSE;
				cmdtmp := cmd;
				AxisStep := STATE_QUIT;
			ELSIF cmd = CONST.AXIS.STOP THEN
				MC_Halt_0.Execute := FALSE;
				MC_Stop_0( Execute := TRUE, Deceleration := verzoegerung);
				AxisStep := STATE_STOP;  
			END_IF
			(* check if error occured *)
			IF MC_Halt_0.Error OR  MC_ReadStatus_0.Errorstop THEN
				BasicControl.Status.ErrorID := MC_Halt_0.ErrorID;
				MC_Halt_0.Execute := FALSE;
				AxisStep := STATE_ERROR;
			END_IF                                         

		(*********************** STOP MOVEMENT *************************)
		STATE_STOP:  (* STATE: Stop movement *)
//			MC_Stop_0.Deceleration := BasicControl.Parameter.Deceleration;
//			MC_Stop_0.Execute := TRUE;
			(* if axis is stopped go to ready state *)
			IF MC_Stop_0.Done  OR MC_ReadStatus_0.StandStill THEN
				MC_Stop_0.Execute := FALSE;
				cmdtmp := cmd;
				AxisStep := STATE_QUIT;
			ELSIF MC_ReadStatus_0.Disabled THEN
				MC_Stop_0.Execute := FALSE;
				cmdtmp := cmd;
				AxisStep := STATE_QUIT;
			END_IF
			(* check if error occured *)
			IF MC_Stop_0.Error OR MC_ReadStatus_0.Errorstop THEN
				BasicControl.Status.ErrorID := MC_Stop_0.ErrorID;
				MC_Stop_0.Execute := FALSE;
				AxisStep := STATE_ERROR;
			END_IF

		(******************** START JOG MOVEMENT POSITVE **********************)
		STATE_JOG_POSITIVE:  (* STATE: Start jog movement in positive direction *)
			IF cmd <> CONST.AXIS.JOG_POS AND cmd <> CONST.AXIS.STOP THEN
				cmdtmp := cmd;
				MC_MoveVelocity_0.Execute := FALSE;
				AxisStep := STATE_HALT;
			ELSIF cmd = CONST.AXIS.STOP THEN
				MC_MoveVelocity_0.Execute := FALSE;
				MC_Stop_0( Execute := TRUE, Deceleration := verzoegerung);
				AxisStep := STATE_STOP;
			END_IF
			(* check if error occured *)
			IF MC_MoveVelocity_0.Error OR MC_ReadStatus_0.Errorstop  THEN
				BasicControl.Status.ErrorID := MC_MoveVelocity_0.ErrorID;
				MC_MoveVelocity_0.Execute := FALSE;
				AxisStep := STATE_ERROR;
			END_IF

		(******************** START JOG MOVEMENT NEGATIVE **********************)
		STATE_JOG_NEGATIVE:  (* STATE: Start jog movement in negative direction *)
			IF cmd <> CONST.AXIS.JOG_NEG AND cmd <> CONST.AXIS.STOP  THEN
				MC_MoveVelocity_0.Execute := FALSE;
				cmdtmp := cmd;
				AxisStep := STATE_HALT;
			ELSIF cmd = CONST.AXIS.STOP THEN
				MC_MoveVelocity_0.Execute := FALSE;
				MC_Stop_0( Execute := TRUE, Deceleration := verzoegerung);
				AxisStep := STATE_STOP;
			END_IF
			(* check if error occured *)
			IF MC_MoveVelocity_0.Error OR MC_ReadStatus_0.Errorstop  THEN
				BasicControl.Status.ErrorID := MC_MoveVelocity_0.ErrorID;
				MC_MoveVelocity_0.Execute := FALSE;
				AxisStep := STATE_ERROR;
			END_IF

		(******************** START ABSOLUTE MOVEMENT **********************)
		STATE_MOVE_ABSOLUTE:  (* STATE: Start absolute movement *)
			(* check if commanded position is reached *)
			IF cmd <> CONST.AXIS.SETPOS AND cmd <> CONST.AXIS.STOP THEN
				MC_MoveAbsolute_0.Execute := FALSE;
				cmdtmp := cmd;
				AxisStep := STATE_HALT;
			ELSIF MC_MoveAbsolute_0.Done  THEN
				MC_MoveAbsolute_0.Execute := FALSE;
				cmdtmp := cmd;
				AxisStep := STATE_QUIT;
			ELSIF cmd = CONST.AXIS.STOP THEN
				MC_MoveAbsolute_0.Execute := FALSE;
				MC_Stop_0( Execute := TRUE, Deceleration := verzoegerung);
				AxisStep := STATE_STOP;
			END_IF
			(* check if error occured *)
			IF MC_MoveAbsolute_0.Error OR MC_ReadStatus_0.Errorstop THEN
				BasicControl.Status.ErrorID := MC_MoveAbsolute_0.ErrorID;
				MC_MoveAbsolute_0.Execute := TRUE;
				AxisStep := STATE_ERROR;
			END_IF

		(******************** START ADDITIVE MOVEMENT **********************)
		STATE_MOVE_ADDITIVE:  (* STATE: Start additive movement *)
			(* check if commanded distance is reached *)
			IF cmd <> CONST.AXIS.SETPOS AND cmd <> CONST.AXIS.STOP THEN
				MC_MoveAdditive_0.Execute := FALSE;
				cmdtmp := cmd;
				AxisStep := STATE_HALT;
				AxisStep := STATE_HALT;
			ELSIF MC_MoveAdditive_0.Done THEN
				MC_MoveAdditive_0.Execute := FALSE;
				cmdtmp := cmd;
				AxisStep := STATE_QUIT;
			ELSIF cmd = CONST.AXIS.STOP THEN
				MC_MoveAdditive_0.Execute := FALSE;
				MC_Stop_0( Execute := TRUE, Deceleration := verzoegerung);
				AxisStep := STATE_STOP;
			END_IF
			(* check if error occured *)
			IF MC_MoveAdditive_0.Error OR  MC_ReadStatus_0.Errorstop THEN
				BasicControl.Status.ErrorID := MC_MoveAdditive_0.ErrorID;
				MC_MoveAdditive_0.Execute := FALSE;
				AxisStep := STATE_ERROR;
			END_IF

		(******************** START VELOCITY MOVEMENT **********************)
		STATE_MOVE_VELOCITY:  (* STATE: Start velocity movement *)
			IF cmd <>  CONST.AXIS.MOVE_VELOCITY AND  cmd <> CONST.AXIS.STOP THEN
				MC_MoveVelocity_0.Execute := FALSE;
				cmdtmp := cmd;
				AxisStep := STATE_HALT;
			ELSIF MC_MoveVelocity_0.InVelocity THEN
				MC_MoveVelocity_0.Execute := FALSE;
				cmdtmp := cmd;
				AxisStep := STATE_QUIT;
			ELSIF cmd = CONST.AXIS.STOP THEN
				MC_MoveVelocity_0.Execute := FALSE;
				MC_Stop_0( Execute := TRUE, Deceleration := verzoegerung);
				AxisStep := STATE_STOP;
			END_IF
			(* check if error occured *)
			IF MC_MoveVelocity_0.Error OR MC_ReadStatus_0.Errorstop  THEN
				BasicControl.Status.ErrorID := MC_MoveVelocity_0.ErrorID;
				MC_MoveVelocity_0.Execute := FALSE;
				AxisStep := STATE_ERROR;
			END_IF

		(******************** FB-ERROR OCCURED *************************)
		STATE_ERROR:  (* STATE: Error *)
			(* check if FB indicates an axis error *)
			IF (MC_ReadAxisError_0.AxisErrorCount<>0) THEN
				AxisStep := STATE_ERROR_AXIS;
			ELSE
				IF (BasicControl.Command.ErrorAcknowledge = TRUE) THEN
					BasicControl.Command.ErrorAcknowledge := FALSE;
					BasicControl.Status.ErrorID := 0;
					(* reset axis if it is in axis state ErrorStop *)
					IF MC_ReadStatus_0.Errorstop AND MC_ReadStatus_0.Valid  THEN
						AxisStep := STATE_ERROR_RESET;
					ELSE
						(*AxisStep := STATE_WAIT;*)
							cmdtmp := cmd;
						AxisStep := STATE_QUIT;
					END_IF
				END_IF
			END_IF

		(******************** AXIS-ERROR OCCURED *************************)
		STATE_ERROR_AXIS:  (* STATE: Axis Error *)
			IF (MC_ReadAxisError_0.Valid) THEN
			err.set := TRUE;
			err.text := MC_ReadAxisError_0.DataObjectName;
			err.id :=  UINT_TO_DINT  (MC_ReadAxisError_0.AxisErrorID) ;
				IF (MC_ReadAxisError_0.AxisErrorID <> 0) THEN
					BasicControl.Status.ErrorID := MC_ReadAxisError_0.AxisErrorID;
				END_IF
				MC_ReadAxisError_0.Acknowledge := FALSE;
			(*	IF (BasicControl.Command.ErrorAcknowledge) THEN
					BasicControl.Command.ErrorAcknowledge := FALSE;
					(* acknowledge axis error *)
				IF cmd = CONST.AXIS.RESET THEN 
					IF (MC_ReadAxisError_0.AxisErrorID <> 0) THEN
						MC_ReadAxisError_0.Acknowledge := TRUE;
						AxisStep := STATE_ERROR_RESET;
					END_IF
				END_IF
				IF (MC_ReadAxisError_0.AxisErrorCount = 0) THEN
					(* reset axis if it is in axis state ErrorStop *)
					BasicControl.Status.ErrorID := 0;
					IF ((MC_ReadStatus_0.Errorstop ) AND (MC_ReadStatus_0.Valid)) THEN
						AxisStep := STATE_ERROR_RESET;
					ELSE
						(*AxisStep := STATE_WAIT;*)
						cmdtmp := cmd;
						AxisStep := STATE_QUIT;
					END_IF
				ELSIF NOT MC_ReadAxisError_0.Error THEN
							cmdtmp := cmd;
							AxisStep := STATE_QUIT;
				END_IF
			ELSE
				AxisStep := STATE_WAIT; (* kein Fehler liegt vor*)
			END_IF

		(******************** RESET DONE *************************)
		STATE_ERROR_RESET:  (* STATE: Wait for reset done *)
			MC_Reset_0.Execute := TRUE;
			(* reset MC_Power.Enable if this FB is in Error*)
			IF (MC_Power_0.Error) THEN
				MC_Power_0.Enable := FALSE;
			END_IF
			IF(MC_Reset_0.Done)THEN
				MC_Reset_0.Execute := FALSE;
				cmdtmp := cmd;
				AxisStep := STATE_QUIT;
			ELSIF(MC_Reset_0.Error) THEN
				MC_Reset_0.Execute := FALSE;
				AxisStep := STATE_ERROR;                    
			END_IF
			(******************** SEQUENCE END *************************)
		STATE_QUIT: 
			busy := FALSE;
			IF cmd = cmdtmp THEN
				busy := FALSE;
				cmd := CONST.AXIS.NOACTION;
				AxisStep := STATE_READY;
			ELSIF cmd <> CONST.AXIS.NOACTION THEN
				busy := FALSE;
				AxisStep := STATE_READY;
			END_IF
		
	END_CASE

(***************************************************************
        Function Block Calls
***************************************************************)

(************************** MC_POWER ****************************)
	MC_Power_0.Axis := AxisREF;  (* pointer to axis *)
	MC_Power_0();

	(************************** MC_HOME *****************************)
	MC_Home_0.Axis := AxisREF;
	MC_Home_0();

	(********************** MC_MOVEABSOLUTE *************************)
	MC_MoveAbsolute_0.Acceleration := BasicControl.Parameter.Acceleration;
	MC_MoveAbsolute_0.Deceleration := BasicControl.Parameter.Deceleration;
	MC_MoveAbsolute_0.Axis := AxisREF;
	MC_MoveAbsolute_0();

	(********************** MC_MOVEADDITIVE *************************)
	MC_MoveAdditive_0.Acceleration := BasicControl.Parameter.Acceleration;
	MC_MoveAdditive_0.Deceleration := BasicControl.Parameter.Deceleration;
	MC_MoveAdditive_0.Axis := AxisREF;
	MC_MoveAdditive_0();

	(********************** MC_MOVEVELOCITY *************************)
	MC_MoveVelocity_0.Acceleration  := BasicControl.Parameter.Acceleration;
	MC_MoveVelocity_0.Deceleration  := BasicControl.Parameter.Deceleration;
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