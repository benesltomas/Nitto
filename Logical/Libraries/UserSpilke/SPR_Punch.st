(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserSpilke
 * File: SPR_Punch.st
 * Author: knausenbergl
 * Created: November 09, 2012
 ********************************************************************
 * Implementation of library UserSpilke
 ********************************************************************) 

(*<$Description$> Implements the punch operation in automatic mode </$Description$>*)
FUNCTION_BLOCK SPR_Punch
	
	IS.R_TRIG_Enable.CLK	:= Enable;
	IS.R_TRIG_Enable();
	
	IS.R_TRIG_Sync.CLK	:= Sync;
	IS.R_TRIG_Sync();

	EnableRestart	:= IS.EnableRestart;	
	
	//experimental!!!!!!!!!!!!!!!!!!!!!!!
//	IF (Master <> 0) THEN
//		pMaster	ACCESS Master;
	//	END_IF;
	
	IS.MC_ReadActualPosition_0.Axis			:= Slave;
	IS.MC_ReadActualPosition_0.Enable		:= Enable;
	IS.MC_ReadActualPosition_0();
	
	IS.MC_ReadParameter_AxisPeriod.Axis				:= Slave;
	IS.MC_ReadParameter_AxisPeriod.ParameterNumber	:= 1008;	//axis modulo period
	IS.MC_ReadParameter_AxisPeriod.Enable			:= Enable;
	IS.MC_ReadParameter_AxisPeriod();
	//	IS.MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance	:= DINT_TO_REAL(ProductLength);	
	
	IF (IS.MC_ReadParameter_AxisPeriod.Value <> 0.0) THEN
		IS.NeutralPosition	:= fmod( (IS.MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition + IS.MC_ReadParameter_AxisPeriod.Value / 2.0), IS.MC_ReadParameter_AxisPeriod.Value);
//		IS.NeutralPosition	:= 0.0;			// Stanze ist nach Referenzfahrt in Position
	ELSE
		IS.NeutralPosition	:= 0.0;
	END_IF;	
	
	//**********************	START OF STATE MACHINE	**************************
	//**********************	transitions from any state	**********************
	IF (NOT Enable) THEN	
		Error		:= FALSE;
		ErrorID		:= 0;
		IS.State	:= SPR_STATE_DISABLED;
	ELSIF (IS.SPR_RmCapture_0.Error) THEN
		ErrorID		:= IS.SPR_RmCapture_0.ErrorID;
		Error		:= TRUE;
		IS.State	:= SPR_STATE_ERROR;
	ELSIF (IS.MC_BR_CrossCutterControl_0.Error) THEN	
		ErrorID		:= IS.MC_BR_CrossCutterControl_0.ErrorID;
		Error		:= TRUE;
		IS.State	:= SPR_STATE_ERROR;
	ELSIF (IS.MC_BR_Phasing_0.Error) THEN
		ErrorID		:= IS.MC_BR_Phasing_0.ErrorID;
		Error		:= TRUE;
		IS.State	:= SPR_STATE_ERROR;
	ELSIF (IS.MC_BR_ReadAutPosition_0.Error) THEN
		ErrorID		:= IS.MC_BR_ReadAutPosition_0.ErrorID;
		Error		:= TRUE;
		IS.State	:= SPR_STATE_ERROR;
	ELSIF (IS.MC_MoveAbsolute_0.Error) THEN	
		ErrorID		:= IS.MC_MoveAbsolute_0.ErrorID;
		Error		:= TRUE;
		IS.State	:= SPR_STATE_ERROR;
	ELSIF (IS.MC_ReadParameter_AxisPeriod.Error) THEN
		ErrorID		:= IS.MC_ReadParameter_AxisPeriod.ErrorID;
		Error		:= TRUE;
		IS.State	:= SPR_STATE_ERROR;
//	ELSIF (IS.MC_ReadParameter_MasterPeriod.Error) THEN
//		ErrorID		:= IS.MC_ReadParameter_MasterPeriod.ErrorID;
//		Error		:= TRUE;
//		IS.State	:= SPR_STATE_ERROR;	
//	ELSIF (IS.MC_ReadActualPosition_Master.Error) THEN
//		ErrorID		:= IS.MC_ReadActualPosition_Master.ErrorID;
//		Error		:= TRUE;
//		IS.State	:= SPR_STATE_ERROR;		
	END_IF;
	//****************************************************************************
	
	CASE (IS.State) OF
		//**********************	FUB inactive	**********************
		SPR_STATE_DISABLED:
			IS.MC_BR_ReadAutPosition_0.Execute		:= FALSE;
			IS.MC_MoveAbsolute_0.Execute			:= FALSE;
			IS.MC_BR_CrossCutterControl_0.Enable	:= FALSE;
			IS.MC_BR_CrossCutterControl_0.EnableCut	:= FALSE;
			IS.EnableRestart						:= FALSE;
			SetupComplete	:= FALSE;
			
			IF (Enable) THEN
				IS.State	:= SPR_STATE_INIT;	
			END_IF;	
		//****************************************************************
		
		//**********************	Internal variables are initialized	**********************
		SPR_STATE_INIT:
			IS.State	:= SPR_STATE_IDLE;
		//************************************************************************************
		
		//**********************	Waiting for a movement command	**********************
		SPR_STATE_IDLE:
			IF RestartAllowed THEN
				IS.EnableRestart						:= TRUE;
			END_IF;
			IF (EnableMove) THEN
				IS.MC_BR_CrossCutterControl_0.Enable	:= TRUE;
				IS.MC_BR_CrossCutterControl_0.EnableCut	:= FALSE;
				IS.State	:= SPR_STATE_CHECK_STANDBY;
			END_IF;	
		//*********************************************************************************
		
		//**********************	Checking if automat restart is possible	**********************
		SPR_STATE_CHECK_STANDBY:
			IF (IS.MC_BR_CrossCutterControl_0.Active) THEN
				IS.MC_BR_CrossCutterControl_0.Enable	:= FALSE;
				IS.MC_BR_CrossCutterControl_0.EnableCut	:= FALSE;
				
				IF (IS.MC_BR_CrossCutterControl_0.StandBy AND IS.EnableRestart) THEN
					IS.MC_BR_ReadAutPosition_0.Execute		:= TRUE;
					IS.State	:= SPR_STATE_READ_AUT_POS;
				ELSE	
					SetupComplete						:= FALSE;
					IS.MC_MoveAbsolute_0.Direction		:= mcPOSITIVE_DIR;
					IS.MC_MoveAbsolute_0.Position		:= IS.NeutralPosition;
					//					IS.MC_MoveAbsolute_0.Execute		:= TRUE;							// Keine Bewegung mehr auf die NeutralPosition
					// 2013-08-22 /scoenefeldr/
					IS.MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance	:= IS.MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition - IS.MC_ReadActualPosition_0.Position;
					IF (IS.MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance < 0) THEN
						IS.MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance	:= IS.MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance + ProductLength;
					ELSIF (IS.MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance > ProductLength) THEN
						IS.MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance	:= IS.MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance - ProductLength;
					END_IF
					IS.State							:= SPR_STATE_MOVE_TO_NEUTRAL_POS;
				END_IF;	
			END_IF;
		
			IF (NOT EnableMove) THEN
				IS.MC_BR_ReadAutPosition_0.Execute		:= FALSE;
				IS.MC_BR_CrossCutterControl_0.Enable	:= FALSE;
				IS.MC_BR_CrossCutterControl_0.EnableCut	:= FALSE;
				IS.State	:= SPR_STATE_IDLE;
			END_IF;
		//****************************************************************************************
		
		//**********************	Reading automat position	**********************
		SPR_STATE_READ_AUT_POS:
			IF (IS.MC_BR_ReadAutPosition_0.Done) THEN
				IS.MC_BR_ReadAutPosition_0.Execute	:= FALSE;
	//			IS.MC_MoveAbsolute_0.Direction		:= mcSHORTEST_WAY + mcAUTOMAT_POS;
				IS.MC_MoveAbsolute_0.Direction		:= mcPOSITIVE_DIR + mcAUTOMAT_POS;

				IS.MC_MoveAbsolute_0.Position		:= IS.MC_BR_ReadAutPosition_0.AutPosition;
				IS.MC_MoveAbsolute_0.Execute		:= TRUE;
				IS.State							:= SPR_STATE_MOVE_TO_AUT_POS;	
			END_IF;
		
			IF (NOT EnableMove) THEN
				IS.MC_BR_ReadAutPosition_0.Execute	:= FALSE;
				IS.MC_MoveAbsolute_0.Execute		:= FALSE;
				IS.State	:= SPR_STATE_IDLE;
			END_IF;
		//*****************************************************************************
		
		//**********************	Moving to automat position	**********************
		SPR_STATE_MOVE_TO_AUT_POS:
			IF (IS.MC_MoveAbsolute_0.Done) THEN	
				IS.MC_MoveAbsolute_0.Execute	:= FALSE;
				IS.MC_BR_CrossCutterControl_0.AdvancedParameters.StartMode	:= mcRESTART + mcCORRECT_CURRENT_CYCLE;
				IS.MC_BR_CrossCutterControl_0.Enable	:= TRUE;
				IS.MC_BR_CrossCutterControl_0.EnableCut	:= TRUE;
				IS.MC_BR_CrossCutterControl_0.AdvancedParameters.MasterMaxVelocity	:= AutPar.MaxMasterVelocity;
				IS.State	:= SPR_STATE_START_AUTOMAT;
			ELSIF (IS.MC_MoveAbsolute_0.CommandAborted) THEN
				IS.MC_MoveAbsolute_0.Execute	:= FALSE;
				IS.State	:= SPR_STATE_W4_RESET;
			END_IF;
		
			IF (NOT EnableMove) THEN
				IS.MC_MoveAbsolute_0.Execute			:= FALSE;
				IS.MC_BR_CrossCutterControl_0.Enable	:= FALSE;
				IS.MC_BR_CrossCutterControl_0.EnableCut	:= FALSE;
				IS.State	:= SPR_STATE_IDLE;
			END_IF;
		//*****************************************************************************
		
		//**********************	Moving to neutral position	**********************
		SPR_STATE_MOVE_TO_NEUTRAL_POS:
//			IF (IS.MC_MoveAbsolute_0.Done) THEN				//Keine Bewegung mehr auf die NeutralPosition
			IF (TRUE) THEN
				IS.MC_MoveAbsolute_0.Execute			:= FALSE;
				IS.MC_BR_CrossCutterControl_0.AdvancedParameters.StartMode	:=	mcIMMEDIATE + mcCORRECT_CURRENT_CYCLE;
				IS.MC_BR_CrossCutterControl_0.Enable	:= TRUE;
				IS.MC_BR_CrossCutterControl_0.EnableCut	:= TRUE;
				IS.MC_BR_CrossCutterControl_0.AdvancedParameters.MasterMaxVelocity	:= AutPar.StartMasterVelocity;
				IS.State	:= SPR_STATE_START_AUTOMAT;
				//experimental!!!!!!!!!!
//				IF (RegMarkPar.EnableRmCorrection) THEN
//					IS.MC_MoveAbsolute_0.Execute	:= FALSE;
//					IS.State						:= SPR_STATE_W4_REG_MARK;
//				ELSE
//					IS.MC_MoveAbsolute_0.Execute			:= FALSE;
//					IS.MC_BR_CrossCutterControl_0.AdvancedParameters.StartMode	:= mcIMMEDIATE + mcCORRECT_CURRENT_CYCLE;
//					IS.MC_BR_CrossCutterControl_0.Enable	:= TRUE;
//					IS.MC_BR_CrossCutterControl_0.EnableCut	:= TRUE;
//					IS.MC_BR_CrossCutterControl_0.AdvancedParameters.MasterMaxVelocity	:= AutPar.StartMasterVelocity;
//					IS.State	:= SPR_STATE_START_AUTOMAT;
//				END_IF;	
			ELSIF (IS.MC_MoveAbsolute_0.CommandAborted) THEN
				IS.MC_MoveAbsolute_0.Execute	:= FALSE;
				IS.State	:= SPR_STATE_W4_RESET;
			END_IF;
		
			IF (NOT EnableMove) THEN
				IS.MC_MoveAbsolute_0.Execute			:= FALSE;
				IS.MC_BR_CrossCutterControl_0.Enable	:= FALSE;
				IS.MC_BR_CrossCutterControl_0.EnableCut	:= FALSE;
				IS.State	:= SPR_STATE_IDLE;
			END_IF;
		//*****************************************************************************
	
	//**********************	Starting cam automat	**********************
		SPR_STATE_START_AUTOMAT:
			IF (IS.MC_BR_CrossCutterControl_0.Active) THEN
				IS.EnableRestart	:= TRUE;
				IS.State			:= SPR_STATE_RUNNING;
			ELSIF (IS.MC_BR_CrossCutterControl_0.CommandAborted) THEN
				IS.MC_BR_CrossCutterControl_0.Enable	:= FALSE;
				IS.MC_BR_CrossCutterControl_0.EnableCut	:= FALSE;
				IS.State	:= SPR_STATE_W4_RESET;	
			END_IF;	
			
			IF (NOT EnableMove) THEN
				IS.MC_BR_CrossCutterControl_0.Enable	:= FALSE;
				IS.MC_BR_CrossCutterControl_0.EnableCut	:= FALSE;
				IS.State	:= SPR_STATE_IDLE;
			END_IF;
		//************************************************************************
		
		//**********************	Cam automat is running	**********************
		SPR_STATE_RUNNING:
			IF (IS.MC_BR_CrossCutterControl_0.CommandAborted) THEN
				IS.MC_BR_CrossCutterControl_0.Enable	:= FALSE;
				IS.MC_BR_CrossCutterControl_0.EnableCut	:= FALSE;
				IS.State	:= SPR_STATE_W4_RESET;
			END_IF;	
		
			//cam automat synchronization movement is complete
			IF ( (IS.MC_BR_CrossCutterControl_0.IS.AutActStIdx >= 2) AND (IS.MC_BR_CrossCutterControl_0.IS.AutActStIdx <= 6) ) THEN
				SetupComplete	:= TRUE;
			END_IF;
			
			//set master speed to maximum velocity after start movement is complete
			IF (IS.MC_BR_CrossCutterControl_0.InCompensation) THEN
				IS.MC_BR_CrossCutterControl_0.AdvancedParameters.MasterMaxVelocity	:= AutPar.MaxMasterVelocity;
			END_IF;
			
			IF (NOT EnableMove) THEN
				IS.MC_BR_CrossCutterControl_0.Enable	:= FALSE;
				IS.MC_BR_CrossCutterControl_0.EnableCut	:= FALSE;
				IS.State	:= SPR_STATE_IDLE;
			END_IF;
		//************************************************************************
		
		//**********************	Command aborted, wait until "EnableMove" is reset	**********************
		SPR_STATE_W4_RESET:
			IF (NOT EnableMove) THEN
				IS.State	:= SPR_STATE_IDLE;	
			END_IF;
		//************************************************************************
		
		//**********************	FUB Error	**********************
		SPR_STATE_ERROR:
		//************************************************************
			
		ELSE	
			
	END_CASE;
	//**********************	END OF STATE MACHINE	************************
	
	//********************		Read automat position			********************
	IS.MC_BR_ReadAutPosition_0.Axis		:= Slave;
	IS.MC_BR_ReadAutPosition_0();
	//******************************************************************************
	
	//********************		Move absolute			********************
	IS.MC_MoveAbsolute_0.Axis			:= Slave;
	IS.MC_MoveAbsolute_0.Velocity		:= SetupPar.Velocity;
	IS.MC_MoveAbsolute_0.Acceleration	:= SetupPar.Acceleration;
	IS.MC_MoveAbsolute_0.Deceleration	:= SetupPar.Deceleration;
	IS.MC_MoveAbsolute_0();
	//**********************************************************************
	
	//********************		Reg mark detection			********************
	IS.SPR_RmCapture_0.Axis					:= RegMarkPar.Axis;
	IS.SPR_RmCapture_0.DistanceToSensor		:= RegMarkPar.DistanceToSensor;
	IS.SPR_RmCapture_0.ProductLength		:= ProductLength;
	IS.SPR_RmCapture_0.RegMarkPosition		:= RegMarkPar.RegMarkPosition;
	IS.SPR_RmCapture_0.TriggerInput			:= RegMarkPar.TriggerInput;
	IS.SPR_RmCapture_0.WindowNegative		:= RegMarkPar.WindowNegative;
	IS.SPR_RmCapture_0.WindowPositive		:= RegMarkPar.WindowPositive;
	
	IS.SPR_RmCapture_0.CutMasterPosition	:= IS.MC_BR_CrossCutterControl_0.CutMasterPosition - REAL_TO_DINT(IS.MC_BR_Phasing_0.Shift);
	IS.SPR_RmCapture_0.Enable				:= (IS.SPR_RmCapture_0.Enable OR Active) AND Enable AND RegMarkPar.EnableRmCorrection AND NOT RegMarkPar.EnableVRegMark;
	IS.SPR_RmCapture_0.SearchRM				:= SearchRM;
	IS.SPR_RmCapture_0();
	//**************************************************************************	
	
	//*******************	Virtual Reg marks	********************
	IF RegMarkPar.EnableOffsetCorr THEN
 
		IS.SPR_RmCalcPosError_Virtual.RecordedValueValid	:= (IS.SPR_RmCalcPosError_Virtual.RecordedValue <> VRmRecordedPosition);
		IF (IS.MC_BR_CrossCutterControl_0.Active AND Enable AND RegMarkPar.EnableRmCorrection AND RegMarkPar.EnableVRegMark) THEN
			IF (IS.CutCount_1 > (IS.CutCntOld + 2)) AND NOT IS.OffsetErrorValid THEN 
				IS.OffsetErrorValid		:= TRUE;
			END_IF
			IF IS.OffsetErrorValid THEN
				IF (IS.SPR_RmCalcPosError_Virtual.RecordedValue <> VRmRecordedPosition) THEN
					IS.OffsetValue := IS.OffsetValue + (VRmRecordedPosition - IS.SPR_RmCalcPosError_Virtual.RecordedValue) - ProductLength;
					IS.PositionError		:= RegMarkPar.RegMarkPosition - IS.OffsetValue;
	//				IS.PositionError		:= 0;
					IS.OffsetValue1		:= RegMarkPar.RegMarkPosition - IS.OffsetValue;
					IS.PositionErrorValid		:= TRUE;
				ELSE
					IS.PositionErrorValid		:= FALSE;
				END_IF
				IS.CutCntOld		:= IS.CutCount_1;
			ELSE
				IS.PositionError		:= 0;
			END_IF
		ELSE
	//		IS.OffsetValue := 0;
			IS.OffsetErrorValid := FALSE;
			IS.CutCntOld		:= IS.CutCount_1;
		END_IF
		
		IS.SPR_RmCalcPosError_Virtual.RecordedValue			:= VRmRecordedPosition;
		IS.SPR_RmCalcPosError_Virtual.CutMasterPosition		:= IS.MC_BR_CrossCutterControl_0.CutMasterPosition - REAL_TO_DINT(IS.MC_BR_Phasing_0.Shift);
	ELSE
		IS.SPR_RmCalcPosError_Virtual.Enable				:= (IS.SPR_RmCalcPosError_Virtual.Enable OR IS.MC_BR_CrossCutterControl_0.Active) AND Enable AND RegMarkPar.EnableRmCorrection AND RegMarkPar.EnableVRegMark;
		IS.SPR_RmCalcPosError_Virtual.DistanceToSensor		:= RegMarkPar.DistanceToSensor;
		IS.SPR_RmCalcPosError_Virtual.ProductLength			:= ProductLength;
		IS.SPR_RmCalcPosError_Virtual.RegMarkPosition		:= RegMarkPar.RegMarkPosition + VRmCorrection; // Änderung 05.06.13
		IS.SPR_RmCalcPosError_Virtual.RecordedValueValid	:= (IS.SPR_RmCalcPosError_Virtual.RecordedValue <> VRmRecordedPosition);
		IS.SPR_RmCalcPosError_Virtual.RecordedValue			:= VRmRecordedPosition;
		IS.SPR_RmCalcPosError_Virtual.CutMasterPosition		:= IS.MC_BR_CrossCutterControl_0.CutMasterPosition - REAL_TO_DINT(IS.MC_BR_Phasing_0.Shift);
		IS.SPR_RmCalcPosError_Virtual();

		IS.PositionError			:= IS.SPR_RmCalcPosError_Virtual.PositionError;
		IS.PositionErrorValid		:= IS.SPR_RmCalcPosError_Virtual.PositionErrorValid;
	
		IS.CutCntOld		:= IS.CutCount_1;
		IS.OffsetErrorValid		:= FALSE;
	END_IF
	//***************************************************************
	
	//limit correction value
	IS.LCRLimit_Correction.max_value	:= AutPar.MaxCorrection;
	IS.LCRLimit_Correction.min_value	:= - AutPar.MaxCorrection;
	
	//choose source of reg mark correction
	IF (RegMarkPar.EnableRmCorrection) THEN
		IF (RegMarkPar.EnableVRegMark) THEN
			IS.LCRLimit_Correction.in	:= IS.PositionError;
		ELSE
			IS.LCRLimit_Correction.in	:= IS.SPR_RmCapture_0.CorrectionValue;
		END_IF;
	ELSE
		IS.LCRLimit_Correction.in	:= 0.0;
	END_IF;
	IS.LCRLimit_Correction();	
	
	//********************		CrossCutter			********************	
	IS.MC_BR_CrossCutterControl_0.Master	:= Master;
	IS.MC_BR_CrossCutterControl_0.Slave		:= Slave;
	
	//calculate cut position within tool segment period
	IF (IS.MC_ReadParameter_AxisPeriod.Value <> 0.0) THEN
		IS.MC_BR_CrossCutterControl_0.CutRangeSlave		:= DINT_TO_REAL( (AutPar.CutEndPos - AutPar.CutStartPos) MOD REAL_TO_DINT(IS.MC_ReadParameter_AxisPeriod.Value) );
		IF (IS.MC_BR_CrossCutterControl_0.CutRangeSlave < 0.0) THEN
			IS.MC_BR_CrossCutterControl_0.CutRangeSlave	:= IS.MC_BR_CrossCutterControl_0.CutRangeSlave + IS.MC_ReadParameter_AxisPeriod.Value;
		END_IF;
		IS.MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition	:= DINT_TO_REAL( ( (AutPar.CutEndPos + AutPar.CutStartPos) / 2) MOD REAL_TO_DINT(IS.MC_ReadParameter_AxisPeriod.Value) );
		IF (IS.MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition < 0.0) THEN
			IS.MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition	:= IS.MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition + IS.MC_ReadParameter_AxisPeriod.Value;
		END_IF;
		
		//limit cut range of slave to avoid ACOPOS errors on wrong user input
		IF ( (AutPar.MinCutRangeSlave > 0.0) AND (AutPar.MinCutRangeSlave < IS.MC_ReadParameter_AxisPeriod.Value) ) THEN
			IS.MC_BR_CrossCutterControl_0.CutRangeSlave	:= MAX(IS.MC_BR_CrossCutterControl_0.CutRangeSlave, AutPar.MinCutRangeSlave);
		END_IF;
		IF ( (AutPar.MinCompRangeSlave > 0.0) AND (AutPar.MinCompRangeSlave < IS.MC_ReadParameter_AxisPeriod.Value) ) THEN
			IS.MC_BR_CrossCutterControl_0.CutRangeSlave := MIN(IS.MC_BR_CrossCutterControl_0.CutRangeSlave, (IS.MC_ReadParameter_AxisPeriod.Value - AutPar.MinCompRangeSlave) );
		END_IF;
		
		//scale cut range of master
		IS.LCRLimScal_CutRangeMaster.x1	:= 0.0;
		IS.LCRLimScal_CutRangeMaster.y1	:= IS.MC_BR_CrossCutterControl_0.CutRangeSlave;
		IS.LCRLimScal_CutRangeMaster.x2	:= 100.0;
		IS.LCRLimScal_CutRangeMaster.y2	:= (IS.MC_BR_CrossCutterControl_0.CutRangeSlave * ProductLength) / IS.MC_ReadParameter_AxisPeriod.Value; 	
		IS.LCRLimScal_CutRangeMaster.x	:= AutPar.Insetting;
		IS.LCRLimScal_CutRangeMaster();
		IS.MC_BR_CrossCutterControl_0.CutRangeMaster	:= IS.LCRLimScal_CutRangeMaster.y;
	ELSE	
		IS.MC_BR_CrossCutterControl_0.CutRangeSlave						:= 0.0;
		IS.MC_BR_CrossCutterControl_0.CutRangeMaster					:= 0.0;
		IS.MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition	:= 0.0;
	END_IF;
	
	//init max. master velocity after start
	IS.R_TRIG_InCompensation.CLK	:= IS.MC_BR_CrossCutterControl_0.InCompensation;
	IS.R_TRIG_InCompensation();
	IS.CccInitMasterMaxVel	:= (IS.R_TRIG_InCompensation.Q AND (IS.MC_BR_CrossCutterControl_0.IS.AutActStIdx = 1) );
	
	IS.MC_BR_CrossCutterControl_0.ProductLength				:= ProductLength;
	IS.MC_BR_CrossCutterControl_0.ProductLengthCorrection	:= IS.LCRLimit_Correction.out;
	IS.MC_BR_CrossCutterControl_0.InitData					:= 
	(IS.CccTriggerInit AND NOT RegMarkPar.EnableRmCorrection)
	OR IS.CccInitMasterMaxVel
	OR
	(
		RegMarkPar.EnableRmCorrection AND
		(
			(IS.SPR_RmCapture_0.CorrectionValid AND NOT RegMarkPar.EnableVRegMark)
//			OR (IS.SPR_RmCalcPosError_Virtual.PositionErrorValid AND RegMarkPar.EnableVRegMark) 
			OR (IS.PositionErrorValid AND RegMarkPar.EnableVRegMark) 
		)
	);
	
	IS.CutCount_1	:= IS.MC_BR_CrossCutterControl_0.CutCount;	 //save old value for change detection
	IS.MC_BR_CrossCutterControl_0();
	IS.CccTriggerInit	:= (IS.CutCount_1 <> IS.MC_BR_CrossCutterControl_0.CutCount);	//cut complete, trigger initialization
	//******************************************************************
	
	//********************	Phasing for synchronization movement	********************
	//TO DO: Shift value on the drive is not reset, even if phasing is disabled. ActualShiftValue may therefore lose resolution, as it is a REAL.
	IS.MC_BR_Phasing_0.Slave			:= Slave;
	IS.MC_BR_Phasing_0.Velocity			:= SyncPar.Velocity;
	IS.MC_BR_Phasing_0.Acceleration		:= SyncPar.Acceleration;
	IS.MC_BR_Phasing_0.ApplicationMode	:= mcTIME_BASED;
	IS.MC_BR_Phasing_0.ShiftMode		:= mcABSOLUTE_NO_RESET;
	
	IS.MC_BR_Phasing_0.Enable	:= (IS.MC_BR_Phasing_0.Enable OR IS.MC_BR_CrossCutterControl_0.Active) AND Enable;
	IS.MC_BR_Phasing_0.InitData	:= IS.R_TRIG_Sync.Q AND NOT IS.ShiftInProgress;
	
	IF (IS.MC_BR_Phasing_0.InitData) THEN
		IF (RegMarkPar.EnableVRegMark) THEN
			IF (RegMarkPar.EnableOffsetCorr) THEN
				IS.OffsetValue          := IS.OffsetValue + (VRmRecordedPosition - IS.SPR_RmCalcPosError_Virtual.RecordedValue) (*- ProductLength*);
				IS.PositionError        := RegMarkPar.RegMarkPosition - IS.OffsetValue;
				IS.RelativeShift        := - IS.PositionError MOD ProductLength;
				IS.OffsetValue			:= IS.OffsetValue - IS.RelativeShift;
				IS.PositionError		:= 0;  //PositionError wird durch MC_BR_Phasing korrigiert
			ELSE
				IS.RelativeShift        := - IS.SPR_RmCalcPosError_Virtual.PositionError MOD ProductLength;
			END_IF
		ELSE
			IS.RelativeShift        := - IS.SPR_RmCapture_0.CorrectionValue MOD ProductLength;
		END_IF;
		IF (IS.RelativeShift < 0) THEN
			IS.RelativeShift        := IS.RelativeShift + ProductLength;
		END_IF;
		IS.MC_BR_Phasing_0.Shift        := IS.MC_BR_Phasing_0.ActualShiftValue + DINT_TO_REAL(IS.RelativeShift);
	END_IF;

	IS.MC_BR_Phasing_0();
	
	//set a flag when a phase shift is in progress
	IF (IS.MC_BR_Phasing_0.ShiftAttained OR NOT IS.MC_BR_Phasing_0.Active) THEN
		IS.ShiftInProgress	:= FALSE;
	ELSIF (IS.MC_BR_Phasing_0.InitData) THEN
		IS.ShiftInProgress	:= TRUE;
	END_IF;	
	//**********************************************************************************
	
	Active				:= IS.MC_BR_CrossCutterControl_0.Active (*OR (IS.State = SPR_STATE_W4_REG_MARK) OR (IS.State = SPR_STATE_START_AUTOMAT)*);
	CutMasterPosition	:= IS.MC_BR_CrossCutterControl_0.CutMasterPosition;	
	
	//probe counter
	IF (Enable AND RegMarkPar.EnableRmCorrection) THEN
		IF (RegMarkPar.EnableVRegMark) THEN
			ProbeCounter		:= ProbeCounter + BOOL_TO_UDINT(IS.SPR_RmCalcPosError_Virtual.RecordedValueValid);
			MissedTriggers		:= 0;
			ActPositionError	:= IS.PositionError;
		ELSE
			ProbeCounter		:= IS.SPR_RmCapture_0.ProbeCounter;
			MissedTriggers		:= IS.SPR_RmCapture_0.MissedTriggers;
			ActPositionError	:= IS.SPR_RmCapture_0.CorrectionValue;
		END_IF;
	ELSE
		ProbeCounter		:= 0;
		MissedTriggers		:= 0;
		ActPositionError	:= 0;
	END_IF;
	
END_FUNCTION_BLOCK