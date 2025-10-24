(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Library: UserSpilke
 * Datei: FB_MainUnwiningCtrl.st
 * Autor: Awalz
 * Erstellt: 24. März 2014
 ********************************************************************
 * Implementierung der Library UserSpilke
 ********************************************************************) 

(* TODO: hier wird der Betriebmodus umgeschalten *)
FUNCTION_BLOCK FB_UnwinderAxis
	IF firststart THEN
		pAxis ACCESS AxisREF;
		UnwinderSysPara.wndWidth		:= 550;	// [mm] 
		UnwinderSysPara.minDiam			:= 76; //gMachRecipe.Winders.CoreDiam; // [mm] 
		UnwinderSysPara.xDiam			:= 1000; //gMachRecipe.Winders.CoreDiam; // [mm] 
		UnwinderSysPara.maxDiam			:= 1200; // [mm] 
		UnwinderSysPara.minDiam			:= 76;	// [mm] 
		UnwinderSysPara.minInertia		:= 1.0; // [kgm^2] 
		UnwinderSysPara.xInertia		:= 1.0; // [kgm^2] 
		UnwinderSysPara.gearRatio		:= 8; //GEAR_RATIO_UNWINDER; // [1] 
		UnwinderSysPara.kvTorque		:= 0.01; // [Nms] 
		UnwinderSysPara.posTorque		:= 0.1; // [Nm] 
		UnwinderSysPara.negTorque		:= 0.1; // [Nm] 
		UnwinderSysPara.matThickness	:= 50.00; // [um] 
		UnwinderSysPara.wndWidth		:= 1000.00; // [mm] 
		UnwinderSysPara.lineUnits		:= 1000000; // [units/m] 
		UnwinderSysPara.wndUnits		:= pAxis.encoder_if.parameter.scaling.load.units; //gUnwinder.encoder_if.parameter.scaling.load.units; 	// [units] 
		UnwinderSysPara.revMotor		:= pAxis.encoder_if.parameter.scaling.load.rev_motor; // gUnwinder.encoder_if.parameter.scaling.load.rev_motor; // [units] 
		UnwinderSysPara.axisType		:= 1; // unwinder 
		// set estimation parameters
		UnwinderEstPara.cycEstTrig 		:= 1000; // [units]
		UnwinderEstPara.cycEstWindow 	:= 1000; // [units]
		UnwinderEstPara.filterMode 		:= 2; // LQ filter
		UnwinderEstPara.filterWindow 	:= 3000; // 3 times cycEstTrig
		WNCCalcDiam_Unwinder.startDiam 		:= 500; // estimation of start diameter in [mm]
		WNCCalcDiam_Unwinder.setStartDiam 	:= TRUE; // set startDiam when FB is enabled
		WNCCalcDiam_Unwinder.pSysPara		:= ADR(UnwinderSysPara);
		WNCCalcDiam_Unwinder.pEstPara		:= ADR(UnwinderEstPara);
		//**************************************************************
		//**************	speed and torque feed forward ****************	
		WNCCalcFFCtrl_Unwinder.uppTrqLimit		:= UDINT_TO_REAL (data.recipeData.maxDiamTension); (*.100;*)
		WNCCalcFFCtrl_Unwinder.lowTrqLimit		:= UDINT_TO_REAL (data.recipeData.minDiamTension); 
		WNCCalcFFCtrl_Unwinder.pSysPara			:= ADR(UnwinderSysPara);
		//****************************************************************
		//**************	set parameters for dancer controller ****************	
		UnwinderPidPara.Kp 						:= 0.1; // [1/s]
		UnwinderPidPara.Tn 						:= 1.0; // [s]
		UnwinderPidPara.Td 						:= 0.0; // [s]
		UnwinderPidPara.Tf 						:= 0.0; // [s]
		UnwinderPidPara.yi_max 					:= 500.0; // [mm/s]
		UnwinderPidPara.y_max 					:= 500.0; // [mm/s]
		UnwinderPidPara.y_min 					:= -500.0; // [mm/s]
		WNCProcessCtrl_Unwinder.gain 			:= 1.0; // [1]
		WNCProcessCtrl_Unwinder.setProcVar 		:= 12000.0; // [mm]
		WNCProcessCtrl_Unwinder.pSysPara		:= ADR(UnwinderSysPara);
		WNCProcessCtrl_Unwinder.pPidPara		:= ADR(UnwinderPidPara);
		//***********************************************************************
		//******** set parameters for linear interpolation of speed controller *************	
		vecD[0]		:= UnwinderSysPara.minDiam;		// [mm]
		vecD[1]		:= 1200.0;		// [mm]
		vecD[2]		:= 0.0;	
		vecKV[0]	:= 2.7;	// [As] 
		vecKV[1]	:= 80.0;	// [As] 
		vecKV[2]	:= 0.0;	
		vecTN[0]	:= 0.00;	// [s]
		vecTN[1]	:= 0.15;	// [s]
		vecTN[2]	:= 0.0;
		WNCLipSctrlPara_Unwinder.pSysPara		:= ADR(UnwinderSysPara);
		WNCLipSctrlPara_Unwinder.numPoints		:= 2;
		WNCLipSctrlPara_Unwinder.pVecDiam		:= ADR(vecD);
		WNCLipSctrlPara_Unwinder.pVecSctrlKV	:= ADR(vecKV);
		WNCLipSctrlPara_Unwinder.pVecSctrlTN	:= ADR(vecTN);
		//**********************************************************************************
		//**************	set parameters for speed controller **************	
		MC_BR_VelocityControl_Unwinder.Axis			:=  AxisREF;// ADR(gUnwinder);
		MC_BR_VelocityControl_Unwinder.Acceleration	:= 10000;
		MC_BR_VelocityControl_Unwinder.Deceleration	:= 10000;
		MC_BR_VelocityControl_Unwinder.TorqueMode	:= mcFF;
		//***********************************************************************
		firststart := FALSE;
	 END_IF 
	//***********************************************************************
	masteraxisREF ACCESS machineaxis.AxisREF;
	MC_ReadActualPosition_0.Enable := NOT(MC_ReadActualPosition_0.Error);
	MC_ReadActualPosition_0.Axis := AxisREF;
	MC_ReadActualPosition_0();
	
	MC_BR_ReadDriveStatus_0.Axis			:= AxisREF; 
	MC_BR_ReadDriveStatus_0.AdrDriveStatus	:= ADR(BasicControl.Status.DriveStatus); (*DriveStatus;*)
	MC_BR_ReadDriveStatus_0.Enable			:= NOT MC_BR_ReadDriveStatus_0.Error; (*MC_BR_ReadDriveStatus_0.Error;*)
	MC_BR_ReadDriveStatus_0();
	status.ready := NOT MC_BR_ReadDriveStatus_0.Error AND MC_BR_ReadDriveStatus_0.Valid AND NOT MC_BR_VelocityControl_Unwinder.Error;
	//**********	diameter estimation		****************
	WNCCalcDiam_Unwinder.enable			:= TRUE; 
	WNCCalcDiam_Unwinder.actLinePos 	:=  REAL_TO_DINT (masteraxisREF.monitor.s); (* Strecke der Masterachse (Virtuelle Achse*)
	WNCCalcDiam_Unwinder.actDcrPos		:= 0; // gMachine.IO.AIn.DancerPos.Value.RawInt; 
	WNCCalcDiam_Unwinder.actWndPos 		:= REAL_TO_DINT (MC_ReadActualPosition_0.Position);  (* Position der Abwicklerachse*)
	WNCCalcDiam_Unwinder.mode			:= TRUE;		// cyclic position based estimation mode
	WNCCalcDiam_Unwinder.setStartDiam	:= TRUE;(* BetrCtrl.enable; (*gMachine.Status.mAutoModeActive;*)
	WNCCalcDiam_Unwinder();
	//************   limit diameter ******************************
	LCRLimit_0.min_value				:= 76;
	LCRLimit_0.max_value				:= 1500;
	LCRLimit_0.in						:= WNCCalcDiam_Unwinder.actDiam;
	LCRLimit_0();
	//******************************************************** 

	//*********** torque feed forward ************************
	WNCCalcFFCtrl_Unwinder.enable			:= TRUE;
	WNCCalcFFCtrl_Unwinder.sync				:= TRUE;	// sync. winder set speed with line speed
	WNCCalcFFCtrl_Unwinder.setMatTension	:= 0.0;
	WNCCalcFFCtrl_Unwinder.setLineSpeed 	:= machineaxis.MC_ReadActualVelocity_0.Velocity; (*AxisIf.Status.ActMasterVelocity;*)
	WNCCalcFFCtrl_Unwinder.actDiam 			:= LCRLimit_0.out;
	WNCCalcFFCtrl_Unwinder.actInertia 		:= WNCCalcDiam_Unwinder.actInertia;
	WNCCalcFFCtrl_Unwinder();
	//********************************************************
	MC_BR_VelocityControl_Unwinder.CyclicVelocityCorrection	:= WNCProcessCtrl_Unwinder.actSpeedCorr;
	MC_BR_VelocityControl_Unwinder.CyclicTorque				:= WNCCalcFFCtrl_Unwinder.setMotorTrq;
	MC_BR_VelocityControl_Unwinder.CyclicVelocity			:= WNCCalcFFCtrl_Unwinder.setWndSpeed;
	MC_BR_VelocityControl_Unwinder.SctrlKv					:= WNCLipSctrlPara_Unwinder.actSctrlKV;
	MC_BR_VelocityControl_Unwinder.SctrlTn					:= WNCLipSctrlPara_Unwinder.actSctrlTN;
	MC_BR_VelocityControl_Unwinder();
	//*********** dancer controller **************************
	WNCProcessCtrl_Unwinder.enable			:= TRUE;
	WNCProcessCtrl_Unwinder.actProcVar		:= INT_TO_REAL (0);  (* Istposition des Tänzers*)
	WNCProcessCtrl_Unwinder.actDiam			:= LCRLimit_0.out;
	WNCProcessCtrl_Unwinder.setProcVar 		:= data.recipeData.dancersolPos;				(* soll Position des Tänzers*)
	WNCProcessCtrl_Unwinder();
	//********************************************************
	//************** linear interpolation of speed controller  *************************
	WNCLipSctrlPara_Unwinder.enable			:= TRUE;
	WNCLipSctrlPara_Unwinder.actDiam		:= LCRLimit_0.out;
	WNCLipSctrlPara_Unwinder();	
	//***********************************************************************************

	
	IF cmd = CONST.AXIS.POWER_ON THEN 
		MC_Power_0.Enable := TRUE;
		IF MC_Power_0.Status THEN 
			cmdtmp := cmd;
			cmd := CONST.AXIS.NOACTION;
		END_IF
	ELSIF cmd = CONST.AXIS.POWER_OFF THEN
		MC_Power_0.Enable := FALSE;
		MC_BR_VelocityControl_Unwinder.Enable := FALSE;
		IF NOT MC_Power_0.Status THEN
			cmdtmp := cmd;
			cmd:= CONST.AXIS.NOACTION;
		END_IF
	ELSIF cmd = CONST.AXIS.RESET THEN
		MC_Reset_0.Execute := TRUE;
		IF MC_Reset_0.Done THEN
			MC_Reset_0.Execute := FALSE;
			cmdtmp := cmd;
			cmd:= CONST.AXIS.NOACTION;
		END_IF
		
	END_IF

	IF cmd = CONST.AXIS.START THEN
		(*MC_Power_0.Enable := TRUE;*)
		(*IF MC_Power_0.Status AND NOT MC_Power_0.Error THEN *)
			MC_BR_VelocityControl_Unwinder.Enable := TRUE;
//			MC_BR_VelocityControl_Unwinder.CyclicVelocity			:= - WNCCalcFFCtrl_Unwinder.setWndSpeed;
//			MC_BR_VelocityControl_Unwinder.CyclicVelocityCorrection	:= - WNCProcessCtrl_Unwinder.actSpeedCorr;
//			MC_BR_VelocityControl_Unwinder.CyclicTorque				:= WNCCalcFFCtrl_Unwinder.setMotorTrq;
//		
//			MC_Stop_0.Execute := FALSE;
//		ELSIF NOT  MC_Power_0.Status THEN
//			MC_Power_0.Enable := TRUE;
//		END_IF
	(*	cmd := CONST.AXIS.NOACTION;*)
	ELSIF cmd = CONST.AXIS.STOP THEN
		(*MC_Power_0.Enable :=FALSE;*)
		(*MC_Power_0.Enable := FALSE;*)
		MC_BR_VelocityControl_Unwinder.Enable := FALSE;
		MC_BR_VelocityControl_Unwinder.CyclicVelocityCorrection := 0;
		MC_BR_VelocityControl_Unwinder.CyclicTorque				:= 0;
		MC_BR_VelocityControl_Unwinder.CyclicVelocity			:= 0;
	(*	MC_Stop_0.Execute := TRUE;*)
		
	(*	cmd := CONST.AXIS.NOACTION;*)
	END_IF

//	CASE AxisStep OF 	
//	(******************* WAIT *************************)
//	(*	STATE_WAIT:  (* STATE: Wait *)
//	STATE_WAIT:  (* STATE: Waiting FOR commands *)
//		IF cmd <> CONST.AXIS.NOACTION THEN
//					busy := TRUE;
//					cmdtmp:= cmd; 
//					IF cmd = CONST.AXIS.RESET THEN 
//						AxisStep := STATE_ERROR_RESET;
//					ELSIF cmd = CONST.AXIS.STOP THEN
//						MC_Stop_0( Execute := TRUE, Deceleration := verzoegerung);
//						AxisStep := STATE_STOP;
//					ELSIF cmd = CONST.AXIS.START THEN
//						AxisStep := STATE_MOVE_VELOCITY;
//					ELSIF   cmd = CONST.AXIS.POWER_OFF THEN   
//						AxisStep := STATE_POWER_OFF;  
//					ELSIF   cmd = CONST.AXIS.POWER_ON THEN   
//						AxisStep := STATE_POWER_ON;                                 
//					END_IF
//		ELSE
//			busy := FALSE;	
//		END_IF
//
//	STATE_POWER_ON:	
//		IF cmd = CONST.AXIS.POWER_ON AND NOT MC_Power_0.Error AND NOT
//			 MC_Power_0.Status AND NOT MC_ReadStatus_0.Error  AND NOT MC_ReadStatus_0.Errorstop  THEN  
//			MC_Power_0.Enable := TRUE;
//			cmd := cmdtmp;
////		ELSIF MC_Power_0.Error THEN 
////			MC_Power_0.Enable := FALSE;
////			cmd := cmdtmp;
////			AxisStep := STATE_ERROR_RESET;
//				(*	merker := TRUE;  *)
//		ELSIF MC_Power_0.Status AND NOT MC_Power_0.Error THEN 	
//				cmdtmp := cmd;
//				AxisStep := STATE_QUIT;
////		ELSIF MC_ReadStatus_0.Error  OR MC_ReadStatus_0.Errorstop OR MC_Power_0.Error THEN 
////			cmd := cmdtmp;
////			AxisStep := STATE_ERROR_RESET;
//	END_IF
////
//	STATE_POWER_OFF:
//		IF 	cmd = CONST.AXIS.POWER_OFF THEN 
//			MC_Power_0.Enable := FALSE;
//			cmd := cmdtmp;
//			AxisStep := STATE_QUIT;
//		END_IF
////
//	STATE_ERROR_RESET:
//			MC_Power_0.Enable := FALSE;
//			MC_BR_VelocityControl_Unwinder.Enable := FALSE;
//			IF MC_Power_0.Error OR MC_BR_VelocityControl_Unwinder.Error 
//				OR MC_ReadStatus_0.Error OR MC_ReadStatus_0.Errorstop  THEN
//				MC_Reset_0.Execute := TRUE;
//			ELSIF MC_Reset_0.Done THEN 
//				MC_Reset_0.Execute := FALSE;
//				cmd := cmdtmp;
//				AxisStep := STATE_QUIT;
//			ELSIF (MC_ReadStatus_0.Disabled OR MC_ReadStatus_0.StandStill OR MC_ReadStatus_0.ContinuousMotion ) AND (NOT  MC_Power_0.Error 
//				AND NOT  MC_BR_VelocityControl_Unwinder.Error AND NOT MC_ReadStatus_0.Error AND NOT  MC_ReadStatus_0.Errorstop) THEN (* axis is ok*)
//				MC_Reset_0.Execute := FALSE;
//				cmd := cmdtmp;
//				AxisStep := STATE_QUIT;	
//			END_IF 
////
//	STATE_QUIT: 
//		IF cmd = cmdtmp THEN 
//			cmd := CONST.AXIS.NOACTION;
//			AxisStep := STATE_WAIT;
//		ELSIF cmd <> CONST.AXIS.NOACTION THEN
//			AxisStep := STATE_WAIT;
//		END_IF
////
//	STATE_MOVE_VELOCITY:
//	//************************* speed controller  ************************************												    
//		IF cmd = CONST.AXIS.START AND NOT  MC_BR_VelocityControl_Unwinder.Error THEN
//			MC_BR_VelocityControl_Unwinder.Enable := TRUE;
//			MC_BR_VelocityControl_Unwinder.CyclicVelocityCorrection	:= WNCProcessCtrl_Unwinder.actSpeedCorr;
//			MC_BR_VelocityControl_Unwinder.CyclicTorque				:= WNCCalcFFCtrl_Unwinder.setMotorTrq;
//			MC_BR_VelocityControl_Unwinder.CyclicVelocity			:= WNCCalcFFCtrl_Unwinder.setWndSpeed;
//			MC_Stop_0.Execute := FALSE;
//			cmd := cmdtmp;
////		ELSIF MC_BR_VelocityControl_Unwinder.Error THEN 
////			AxisStep := STATE_ERROR_RESET;
//		ELSIF cmd <> CONST.AXIS.START THEN
//			AxisStep := STATE_QUIT;
//		END_IF 
////
//	STATE_STOP: 
//		IF cmd = CONST.AXIS.STOP OR  MC_BR_VelocityControl_Unwinder.Error THEN
//			MC_BR_VelocityControl_Unwinder.Enable := FALSE;
//			MC_BR_VelocityControl_Unwinder.CyclicVelocityCorrection := 0;
//			MC_BR_VelocityControl_Unwinder.CyclicTorque				:= 0;
//			MC_BR_VelocityControl_Unwinder.CyclicVelocity			:= 0;
//			MC_Stop_0.Execute := TRUE;
//			cmdtmp := cmd;
//			IF MC_Stop_0.Done THEN 
//				MC_Stop_0.Execute := FALSE;
//				AxisStep := STATE_QUIT;
//			END_IF
//		ELSIF MC_BR_VelocityControl_Unwinder.Error THEN 
//			AxisStep := STATE_ERROR_RESET;
//		END_IF
//
//	END_CASE 


	(************************ MC_READSTATUS *************************)
	MC_ReadStatus_0.Enable :=  NOT MC_ReadStatus_0.Error;
	MC_ReadStatus_0.Axis := AxisREF;
	MC_ReadStatus_0();  
	(************************** MC_POWER ****************************)
	MC_Power_0.Axis := AxisREF;  (* pointer to axis *)
	MC_Power_0();

	(************************** MC_STOP *****************************)
	MC_Stop_0.Axis := AxisREF;
	MC_Stop_0();
	(***************************MC_HALT******************************)
	(*MC_Halt_0.Axis := AxisREF;
	MC_Halt_0();
	(************************** MC_RESET ****************************)
	MC_Reset_0.Axis := AxisREF;
	MC_Reset_0();
END_FUNCTION_BLOCK