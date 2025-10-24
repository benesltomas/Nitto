(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Programm: MAIN
 * Datei: FB_BufferTensionCtrl.st
 * Autor: awalz
 * Erstellt: 21. November 2014
 ********************************************************************
 * Implementierung des Programms MAIN
 ********************************************************************) 

(* TODO: Bitte Kommentar hier einfügen *)
FUNCTION_BLOCK FB_BufferTensionCtrl
	IF firststart THEN
		pAxis ACCESS AxisREF;
		LCRPIDpara_0.Kfbk					:= 2.0; // Anti-windup used
		LCRPIDpara_0.d_mode					:= LCRPID_D_MODE_E;	// differentiate control deviation
		LCRPIDpara_0.fbk_mode				:= LCRPID_FBK_MODE_INTERN;	// feedback of internal output
		LCRPID_0.mode						:= LCRPID_MODE_AUTO;	// Standard PID operating mod
		// 50.000 = 3 m/min
		LCRPID_0.Y_max						:= 100;	// percent
		LCRPID_0.Y_min						:= -100;// percent

		LCRPIDpara_0.Kp						:= 3; (*11*)
		LCRPIDpara_0.Tn						:= 1.1;	// Integrative part
		LCRPIDpara_0.Tv						:= 0.0; // D-part
		LCRPIDpara_0.Tf						:= 0;(*0.020;*)
		LCRPIDpara_0.WX_max					:= 1000.0;
		LCRPIDpara_0.WX_min					:= -1000.0;
//		LCRPIDpara_0.deadband				:= 10;
//		LCRPIDpara_0.deadband_mode			:= LCRPID_DEADBAND_MODE_STANDARD;
		LCRPID_0.ident						:= LCRPIDpara_0.ident;
		// Maximum controller output:
	
		//set filter time for tension sensor
		LCRPT1e_ActTension.V		:= 1.0;
		LCRPT1e_ActTension.T1		:= TENSION_T_FILTER;(*0.2*)
		LCRPT1e_ActTension.enable	:= TRUE;
//		vecD[0]		:= 80;		// [mm]
//		vecD[1]		:= 1200.0;		// [mm]
//		vecD[2]		:= 0.0;	
//		vecKV[0]	:= 2.7;	// [As] 
//		vecKV[1]	:= 80.0;	// [As] 
//		vecKV[2]	:= 0.0;	
//		vecTN[0]	:= 0.00;	// [s]
//		vecTN[1]	:= 0.15;	// [s]
//		vecTN[2]	:= 0.0;
//		WNCLipSctrlPara_Unwinder.pSysPara		:= ADR(UnwinderSysPara);
//		WNCLipSctrlPara_Unwinder.numPoints		:= 2;
//		WNCLipSctrlPara_Unwinder.pVecDiam		:= ADR(vecD);
//		WNCLipSctrlPara_Unwinder.pVecSctrlKV	:= ADR(vecKV);
//		WNCLipSctrlPara_Unwinder.pVecSctrlTN	:= ADR(vecTN)
		//**************	set parameters for speed controller **************	
	
		MC_BR_VelocityControl_0.Acceleration	:= 20000; (*1000000 wo kommt der astronomischer Wert her*)
		MC_BR_VelocityControl_0.Deceleration	:= 20000;
		MC_BR_VelocityControl_0.TorqueMode		:= mcLIMIT;
		MC_BR_VelocityControl_0.SctrlKv 		:= 0.1;
		MC_BR_VelocityControl_0.SctrlTn			:= 0.15;

	(*	MC_BR_TorqueControl_0.Acceleration		:= 100000;*)
		
		
		//***********************************************************************
		firststart := FALSE;
	 END_IF 
	//************************** LCRPIDpara *******************************
	//lowpass filter for sensor signal
	LCRPT1e_ActTension.x		:=  dancer.tension_scaled; (*.IO.AIn.FlengeDMS.Value.Scaled;*)
	LCRPT1e_ActTension();
	LCRPIDpara_0();
	//************************** LCRPID *******************************
	LCRPID_0.ident						:= LCRPIDpara_0.ident;
	// PID controller:

	//  setpoint  		"W" = web tension from application recipe
	//  actual value	"X" = measured web tension from flenge DMS input (*override wird beim füllen draufgegebe*)
	LCRPID_0.W			:= LIMIT (0, data.recipe.SetTension + tensionoffset.setvalueVisu + override, 200);
//	LCRPID_0.X			:= floor (LCRPT1e_ActTension.y);
	LCRPID_0.X			:= LCRPT1e_ActTension.y;
	LCRPID_0();
	(*OutPID				:= LCRPID_TM.Y * TM_SCALE_PID_OUT_TO_OFFSET;*)
	CyclicVelocity		:= LCRPID_0.Y * TM_SCALE_PID_OUT_TO_OFFSET;

		
	IF CyclicVelocity < -1 THEN 
		MC_BR_VelocityControl_0.CyclicTorque :=  -1 * settorque ;
	ELSE 
		MC_BR_VelocityControl_0.CyclicTorque :=  settorque;
	END_IF
	// ================
	// CHECK ERRORS
	// ================

	IF (LCRPID_0.status > 12022) AND
	   (LCRPID_0.status < 65534) THEN
//		// Error in PID controller detected -> stop control
		AxisStep		:= ST_CTRL_OFF;
	END_IF

	CASE AxisStep OF
		//********************* INITIALISATION ************************
		ST_INIT1:
			LCRPIDpara_0.enable		:= TRUE;
			LCRPIDpara_0.enter		:= FALSE;
			LCRPID_0.enable			:= FALSE; (* 10.12.14*)
		(*	LCRPID_0.enable			:= FALSE;*)
			MC_BR_VelocityControl_0.Enable := FALSE;
			AxisStep					:= ST_READY;
			
		//********************* WAIT FOR COMMANDS ************************
		ST_READY:
		(*	MC_BR_CyclicWrite_0.Enable			:= FALSE;*)
			IF cmd = CONST.AXIS.START  THEN
				(*TensMeas.Command.startTmControl	:= FALSE;*)
			(*	MC_BR_CyclicWrite_0.Enable		:= TRUE;*)
				LCRPID_0.enable			:= FALSE;
				AxisStep		:= ST_WAIT_POWER_ENABLED;
			ELSIF cmd = CONST.AXIS.JOG_POS THEN 
				AxisStep := ST_MOVE_POS;
			ELSIF cmd = CONST.AXIS.JOG_NEG THEN 
				AxisStep := ST_MOVE_NEG;
			END_IF
			// End of STEP_TM_READY
		//********************* WAIT FOR DRIVES BEING ENABLED ************************
		ST_WAIT_POWER_ENABLED:
			IF  MC_ReadStatus_0.StandStill OR  MC_ReadStatus_0.ContinuousMotion THEN
				AxisStep			:= ST_LOAD_PARA_START;
				// Generate rising edge at the enter input in order to update 
				// PID controller parameters
				LCRPIDpara_0.enter	:= FALSE;
			ELSIF MC_ReadStatus_0.Error THEN
				AxisStep := ST_INIT1;
			END_IF
			// End of STEP_TM_WAIT_POWER_ENABLED
		//********************* START PARAMETER LOADING ************************
		ST_LOAD_PARA_START:	
			// Rising edge for updating controller parameter
			LCRPIDpara_0.enter		:= TRUE;
			AxisStep				:= ST_WAIT_LOAD_PARA_DONE;
//		//********************* WAIT FOR PARAMETER LOAD COMPLETE ************************
		ST_WAIT_LOAD_PARA_DONE:
			LCRPIDpara_0.enter		:= FALSE;
			AxisStep				:= ST_WAIT_SWITCH_CTRL_ON;
			// End of STEP_TM_WAIT_LOAD_PARA_DONE
//
//		//********************* ACTIVATE CONTROL ************************
		ST_WAIT_SWITCH_CTRL_ON:
			IF  MC_ReadStatus_0.StandStill AND (LCRPIDpara_0.ident <> 0)  THEN
				// Enable PID controller and Offset correction for web tension control
				LCRPID_0.enable				:= TRUE;
//				MC_BR_TorqueControl_0.Enable := TRUE;
//				MC_BR_TorqueControl_0.StartSignal :=TRUE;
				MC_BR_VelocityControl_0.Enable 	:= TRUE;
				AxisStep						:= ST_CTRL_ACTIVE;
			ELSIF MC_ReadStatus_0.ContinuousMotion THEN (* PI_REgler und Achse sind bereits aktiv*)
				MC_BR_VelocityControl_0.Enable 	:= TRUE;
				LCRPID_0.enable					:= TRUE;
				AxisStep						:= ST_CTRL_ACTIVE;

			END_IF
			// Go to ready state in order to update controller parameter
			IF  cmd = CONST.AXIS.STOP  THEN
				AxisStep	:= ST_INIT1;
			END_IF
//			// End of STEP_TM_WAIT_SWITCH_CTRL_ON
//
//		//********************* CONTROL IS ACTIVE ************************
		ST_CTRL_ACTIVE:
			MC_BR_VelocityControl_0.CyclicVelocityCorrection := LIMIT (-300, CyclicVelocity, 300);
		(*		MC_BR_TorqueControl_0.Torque :=  LIMIT (-50, CyclicVelocity, 50);*)
			IF cmd = CONST.AXIS.STOP	OR  MC_ReadStatus_0.Disabled  THEN
			(*	TensMeas.Command.stopTmControl 			:= FALSE;*)
				MC_BR_VelocityControl_0.Enable 	:= FALSE;
//				MC_BR_TorqueControl_0.Enable := FALSE;
//				MC_BR_TorqueControl_0.StartSignal :=FALSE;
			(*	AxisStep	:= ST_CTRL_OFF;*)
				AxisStep := ST_INIT1;
			ELSIF MC_BR_VelocityControl_0.CommandAborted AND cmd = CONST.AXIS.START THEN
				MC_BR_VelocityControl_0.Enable 	:= FALSE;
				AxisStep := ST_INIT1;
			ELSIF  cmd = CONST.AXIS.JOG_POS OR cmd = CONST.AXIS.JOG_NEG THEN
				MC_BR_VelocityControl_0.Enable 	:= FALSE;
				AxisStep := ST_INIT1;
			END_IF
//		// End of STEP_TM_CTRL_ACTIVE
		ST_MOVE_POS: (* Achse hoch fahren*)
			MC_BR_VelocityControl_0.CyclicVelocityCorrection := LIMIT (-300, CyclicVelocity, 300);
			IF cmd = CONST.AXIS.JOG_POS AND MC_ReadStatus_0.StandStill THEN
				MC_BR_VelocityControl_0.CyclicVelocity := 100;
				MC_BR_VelocityControl_0.Enable := TRUE;
			ELSIF cmd <> CONST.AXIS.JOG_POS THEN 
				MC_BR_VelocityControl_0.CyclicVelocity := 0;
				MC_BR_VelocityControl_0.Enable := FALSE;
				AxisStep := ST_INIT1;
			END_IF

		ST_MOVE_NEG: (* Achse runter fahren*)
			MC_BR_VelocityControl_0.CyclicVelocityCorrection := LIMIT (-300, CyclicVelocity, 300);
			IF cmd = CONST.AXIS.JOG_NEG AND MC_ReadStatus_0.StandStill THEN
				MC_BR_VelocityControl_0.CyclicVelocity := - 100;
				MC_BR_VelocityControl_0.Enable := TRUE;
			ELSIF cmd <> CONST.AXIS.JOG_NEG THEN 
				MC_BR_VelocityControl_0.CyclicVelocity := 0;
				MC_BR_VelocityControl_0.Enable := FALSE;
				AxisStep := ST_INIT1;
			END_IF
//		//********************* PAUSING CONTROL ************************
		ST_CTRL_PAUSE:
//			action_TmCtrlOff;
//			// Go to step for waiting to enable control again
			IF cmd = CONST.AXIS.START THEN 
				AxisStep	:= ST_WAIT_SWITCH_CTRL_ON;
			ELSIF cmd = CONST.AXIS.POWER_OFF THEN 
				AxisStep	:= ST_CTRL_OFF;
			END_IF
//			// End of STEP_TM_CTRL_PAUSE
//
//		//********************* SWITCH CONTROL OFF ************************
		ST_CTRL_OFF:
//			action_TmCtrlOff;
//			// Go to step for waiting fo new commands
			AxisStep					:= ST_INIT1;
//			// End of STEP_TM_CTRL_OFF

	END_CASE
	//********************************************************************
	// Function Block Calls
	//*********************************************************************
	//***********************************************************************
	MC_ReadActualPosition_0.Enable := NOT(MC_ReadActualPosition_0.Error);
	MC_ReadActualPosition_0.Axis := AxisREF;
	MC_ReadActualPosition_0();
	
	MC_BR_ReadDriveStatus_0.Axis			:= AxisREF; 
	MC_BR_ReadDriveStatus_0.AdrDriveStatus	:= ADR(BasicControl.Status.DriveStatus); (*DriveStatus;*)
	MC_BR_ReadDriveStatus_0.Enable			:= NOT MC_BR_ReadDriveStatus_0.Error; (*MC_BR_ReadDriveStatus_0.Error;*)
	MC_BR_ReadDriveStatus_0();


//	MC_BR_CyclicWrite_0.Axis		:= AxisREF;
//	MC_BR_CyclicWrite_0.DataAddress	:= ADR(CyclicVelocity);
//	MC_BR_CyclicWrite_0.DataType	:= ncPAR_TYP_REAL;  nicht vergessen in Acps10map ACOPOS Parameter gpbsSPTa mit zschreiben
//	MC_BR_CyclicWrite_0.ParID		:= ACP10PAR_VAR_R4_0 + 0;
//	MC_BR_CyclicWrite_0();
//	MC_BR_TorqueControl_0.Axis := AxisREF;//
// 	MC_BR_TorqueControl_0();//
//	***********************MC_BR_VelocityControl******************
	MC_BR_VelocityControl_0.Axis			:= AxisREF;//
	MC_BR_VelocityControl_0();
	(************************ MC_READSTATUS *************************)
	MC_ReadStatus_0.Enable :=  NOT MC_ReadStatus_0.Error;
	MC_ReadStatus_0.Axis := AxisREF;
	MC_ReadStatus_0();  
	(************************** MC_POWER ****************************)
//	MC_Power_0.Axis := AxisREF;  (* pointer to axis *)
//	MC_Power_0();

	(************************** MC_STOP *****************************)
//	MC_Stop_0.Axis := AxisREF;
//	MC_Stop_0();
	(***************************MC_HALT******************************)
	(*MC_Halt_0.Axis := AxisREF;
	MC_Halt_0();
	(************************** MC_RESET ****************************)
//	MC_Reset_0.Axis := AxisREF;
//	MC_Reset_0();
END_FUNCTION_BLOCK