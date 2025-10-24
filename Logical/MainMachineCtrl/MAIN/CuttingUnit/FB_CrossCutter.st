//(********************************************************************
// * COPYRIGHT -- Microsoft
// ********************************************************************
// * Programm: MAIN
// * Datei: FB_CuttingAxis.st
// * Autor: Awalz
// * Erstellt: 19. Mai 2014
// ********************************************************************
// * Implementierung des Programms MAIN
// ********************************************************************) 
//
// (*<$Description$> TODO: Bitte Kommentar hier einzufügen </$Description$>*)
FUNCTION_BLOCK FB_CrossCutter
	SetupPar.Acceleration	:= 1000000.0;
	SetupPar.Deceleration	:= 1000000.0;
	SetupPar.Velocity		:= SLS_MASTER_VELO;
	RegMarkPar.WindowNegative	:= 30000.0;
	RegMarkPar.WindowPositive	:= 30000.0;

	MC_BR_ReadAxisError_0.Axis				:= SlaveREF;
	MC_BR_ReadAxisError_0.Enable			:= NOT MC_BR_ReadAxisError_0.Error;
	MC_BR_ReadAxisError_0();

	MC_ReadStatus_0.Axis					:= SlaveREF;
	MC_ReadStatus_0.Enable					:= NOT MC_ReadStatus_0.Error;
	MC_ReadStatus_0();
	MC_BR_ReadDriveStatus_0.Axis			:= SlaveREF;
	MC_BR_ReadDriveStatus_0.AdrDriveStatus	:= ADR(DriveStatus);
	MC_BR_ReadDriveStatus_0.Enable			:= NOT MC_BR_ReadDriveStatus_0.Error;
	MC_BR_ReadDriveStatus_0();
	
	MC_ReadActualPosition_0.Axis			:= SlaveREF;
	MC_ReadActualPosition_0.Enable			:= Enable;
	MC_ReadActualPosition_0();
	
	MC_Reset_0.Axis	:= SlaveREF;
	MC_Reset_0();

	MC_ReadParameter_AxisPeriod.Axis			:= SlaveREF;
	MC_ReadParameter_AxisPeriod.ParameterNumber	:= 1008;	//axis modulo period
	MC_ReadParameter_AxisPeriod.Enable			:= Enable;
	MC_ReadParameter_AxisPeriod();
	
//********************		CrossCutter			********************	
	MC_BR_CrossCutterControl_0.Master									:= machineMaster.AxisREF;
	MC_BR_CrossCutterControl_0.Slave									:= SlaveREF;
	MC_BR_CrossCutterControl_0.CutRangeMaster 							:= crosscuttpar.CutRangeMaster;
	MC_BR_CrossCutterControl_0.CutRangeSlave 							:= crosscuttpar.CutRangeSlave;
	MC_BR_CrossCutterControl_0.ProductLength 							:= crosscuttpar.ProductLength;	
	MC_BR_CrossCutterControl_0.AdvancedParameters.StartMode 			:= crosscuttpar.StartMode;
	MC_BR_CrossCutterControl_0.AdvancedParameters.StartInterval			:= crosscuttpar.StartInterval;
//    MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance	:= crosscuttpar.MasterStartDistance;
//	MC_BR_CrossCutterControl_0();

	IF (MC_ReadParameter_AxisPeriod.Value <> 0.0) THEN
		NeutralPosition	:= fmod( (MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition + MC_ReadParameter_AxisPeriod.Value / 2.0), MC_ReadParameter_AxisPeriod.Value);
//		IS.NeutralPosition	:= 0.0;			// Stanze ist nach Referenzfahrt in Position
	ELSE
		NeutralPosition	:= 0.0;
	END_IF;	
	
	//**********************	START OF STATE MACHINE	**************************
	//**********************	transitions from any state	**********************
	IF (NOT Enable) THEN	
		Error		:= FALSE;
		ErrorID		:= 0;
		State	:= STATE_DISABLED;
//	ELSIF (markpoints.Error) THEN
//		ErrorID		:= markpoints.ErrorID;
//		Error		:= TRUE;
//		State	:= STATE_ERROR;
	ELSIF (MC_BR_CrossCutterControl_0.Error) THEN	
		ErrorID		:= MC_BR_CrossCutterControl_0.ErrorID;
		Error		:= TRUE;
		State	:= STATE_ERROR;
//	ELSIF (MC_BR_Phasing_0.Error) THEN
//		ErrorID		:= MC_BR_Phasing_0.ErrorID;
//		Error		:= TRUE;
//		State	:= STATE_ERROR;
//	ELSIF (MC_BR_ReadAutPosition_0.Error) THEN
//		ErrorID		:= MC_BR_ReadAutPosition_0.ErrorID;
//		Error		:= TRUE;
//		State	:= STATE_ERROR;
	ELSIF (MC_MoveAbsolute_0.Error) THEN	
		ErrorID		:= MC_MoveAbsolute_0.ErrorID;
		Error		:= TRUE;
		State	:= STATE_ERROR;
	ELSIF (MC_ReadParameter_AxisPeriod.Error) THEN
		ErrorID		:= MC_ReadParameter_AxisPeriod.ErrorID;
		Error		:= TRUE;
		State	:= STATE_ERROR;
	END_IF;
	//****************************************************************************
	
	CASE State OF
		//**********************	FUB inactive	**********************
		STATE_DISABLED:
			MC_BR_ReadAutPosition_0.Execute		:= FALSE;
			MC_MoveAbsolute_0.Execute			:= FALSE;
			MC_BR_CrossCutterControl_0.Enable	:= FALSE;
			MC_BR_CrossCutterControl_0.EnableCut:= FALSE;
			EnableRestart						:= FALSE;
			SetupComplete						:= FALSE;
			
			IF Enable  (*OR RestartAllowed *)THEN
				State	:= STATE_INIT;	
			END_IF;	
	//****************************************************************
		
	//**********************	Internal variables are initialized	**********************
		STATE_INIT:
			GetNextCuttPos.reset := TRUE;
			State	:= STATE_IDLE;
	//************************************************************************************
		
	//**********************	Waiting for a movement command	**********************
		STATE_IDLE:
			GetNextCuttPos.reset := FALSE;
			IF RestartAllowed THEN
				EnableRestart						:= TRUE;
			END_IF;
			IF (EnableMove) THEN
				MC_BR_CrossCutterControl_0.Enable	:= TRUE;
				MC_BR_CrossCutterControl_0.EnableCut:= FALSE;
				State	:= STATE_CHECK_STANDBY;
			END_IF;	
	//*********************************************************************************
		
	//**********************	Checking if automat restart is possible	**********************
		STATE_CHECK_STANDBY:
			IF (MC_BR_CrossCutterControl_0.Active) THEN
				MC_BR_CrossCutterControl_0.Enable		:= FALSE;
				MC_BR_CrossCutterControl_0.EnableCut	:= FALSE;
				IF (MC_BR_CrossCutterControl_0.StandBy AND EnableRestart) THEN
					MC_BR_ReadAutPosition_0.Execute		:= TRUE;
					State	:= STATE_READ_AUT_POS;
				ELSE	
					SetupComplete					:= FALSE;
					MC_MoveAbsolute_0.Direction		:= mcPOSITIVE_DIR;
					MC_MoveAbsolute_0.Position		:= NeutralPosition;
					//IS.MC_MoveAbsolute_0.Execute		:= TRUE;	// Keine Bewegung mehr auf die NeutralPosition
					// 2013-08-22 /scoenefeldr/
				(*	MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance	:= MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition - MC_ReadActualPosition_0.Position;*)
						MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance	:= MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition + MC_ReadActualPosition_0.Position;
					IF (MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance < 0 OR MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance < data.general.periodLength) THEN
						MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance	:= (*MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance + *)data.general.periodLength;
					ELSIF (MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance > data.general.periodLength) THEN
						MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance	:=(* MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance - data.general.periodLength;*) scalePerimeter.realperimeter;
					END_IF
					State							:= STATE_MOVE_TO_NEUTRAL_POS;
				END_IF;	
			END_IF;
			IF (NOT EnableMove) THEN
				MC_BR_ReadAutPosition_0.Execute		:= FALSE;
				MC_BR_CrossCutterControl_0.Enable	:= FALSE;
				MC_BR_CrossCutterControl_0.EnableCut:= FALSE;
				State	:= STATE_IDLE;
			END_IF;
	//****************************************************************************************
		
	//**********************	Reading automat position	**********************
		STATE_READ_AUT_POS:
			IF (MC_BR_ReadAutPosition_0.Done) THEN
				MC_BR_ReadAutPosition_0.Execute	:= FALSE;
				MC_MoveAbsolute_0.Direction		:= mcPOSITIVE_DIR + mcAUTOMAT_POS;
				MC_MoveAbsolute_0.Position		:= MC_BR_ReadAutPosition_0.AutPosition;
				MC_MoveAbsolute_0.Execute		:= TRUE;
				State							:= STATE_MOVE_TO_AUT_POS;	
			END_IF;
		
			IF (NOT EnableMove) THEN
				MC_BR_ReadAutPosition_0.Execute	:= FALSE;
				MC_MoveAbsolute_0.Execute		:= FALSE;
				State	:= STATE_IDLE;
			END_IF;
	//*****************************************************************************
		
	//**********************	Moving to automat position	**********************
		STATE_MOVE_TO_AUT_POS:
			IF MC_MoveAbsolute_0.Done THEN	
				MC_MoveAbsolute_0.Execute			:= FALSE;
				MC_BR_CrossCutterControl_0.AdvancedParameters.StartMode	:= mcRESTART + mcCORRECT_CURRENT_CYCLE;
				MC_BR_CrossCutterControl_0.Enable	:= TRUE;
				MC_BR_CrossCutterControl_0.EnableCut:= TRUE;
				MC_BR_CrossCutterControl_0.AdvancedParameters.MasterMaxVelocity	:= SetupPar.Velocity; (*data.general.maxVelocity;*)
				State	:= STATE_START_AUTOMAT;
			ELSIF MC_MoveAbsolute_0.CommandAborted THEN
				MC_MoveAbsolute_0.Execute			:= FALSE;
				State	:= STATE_W4_RESET;
			END_IF;
		
			IF NOT EnableMove THEN
				MC_MoveAbsolute_0.Execute			:= FALSE;
				MC_BR_CrossCutterControl_0.Enable	:= FALSE;
				MC_BR_CrossCutterControl_0.EnableCut:= FALSE;
				State	:= STATE_IDLE;
			END_IF;
	//*****************************************************************************
		
	//**********************	Moving to neutral position	**********************
		STATE_MOVE_TO_NEUTRAL_POS:
			IF (TRUE) THEN
				MC_MoveAbsolute_0.Execute			:= FALSE;
				MC_BR_CrossCutterControl_0.AdvancedParameters.StartMode	:= mcIMMEDIATE + mcCORRECT_CURRENT_CYCLE;
				MC_BR_CrossCutterControl_0.Enable	:= TRUE;
				MC_BR_CrossCutterControl_0.EnableCut:= TRUE;
				MC_BR_CrossCutterControl_0.AdvancedParameters.MasterMaxVelocity	:= SetupPar.Velocity; (*data.general.maxVelocity;*)
				State	:= STATE_START_AUTOMAT;

			ELSIF (MC_MoveAbsolute_0.CommandAborted) THEN
				MC_MoveAbsolute_0.Execute	:= FALSE;
				State	:= STATE_W4_RESET;
			END_IF;
		
			IF NOT EnableMove THEN
				MC_MoveAbsolute_0.Execute			:= FALSE;
				MC_BR_CrossCutterControl_0.Enable	:= FALSE;
				MC_BR_CrossCutterControl_0.EnableCut:= FALSE;
				State	:= STATE_IDLE;
			END_IF;
	//*****************************************************************************
	
	//**********************	Starting cam automat	**********************
		STATE_START_AUTOMAT:
			IF (MC_BR_CrossCutterControl_0.Active) THEN
				EnableRestart	:= TRUE;
				State			:= STATE_RUNNING;
			ELSIF (MC_BR_CrossCutterControl_0.CommandAborted) THEN
				MC_BR_CrossCutterControl_0.Enable	:= FALSE;
				MC_BR_CrossCutterControl_0.EnableCut:= FALSE;
				State	:= STATE_W4_RESET;	
			END_IF;	
			
			IF (NOT EnableMove) THEN
				MC_BR_CrossCutterControl_0.Enable	:= FALSE;
				MC_BR_CrossCutterControl_0.EnableCut:= FALSE;
				State	:= STATE_IDLE;
			END_IF;
	//************************************************************************
		
	//**********************	Cam automat is running	**********************
		STATE_RUNNING:
			IF (MC_BR_CrossCutterControl_0.CommandAborted) THEN
				MC_BR_CrossCutterControl_0.Enable	:= FALSE;
				MC_BR_CrossCutterControl_0.EnableCut:= FALSE;
				State	:= STATE_W4_RESET;
			END_IF;	
//			IF RestartAllowed THEN (* um die Achse wieder zu koppeln*)
//				RestartAllowed := FALSE;
//				EnableRestart						:= TRUE;
//				MC_BR_CrossCutterControl_0.Enable	:= FALSE;
//				MC_BR_CrossCutterControl_0.EnableCut:= FALSE;
//				State	:= STATE_W4_RESET;
//			END_IF
			//cam automat synchronization movement is complete
			IF ( (MC_BR_CrossCutterControl_0.IS.AutActStIdx >= 2) AND (MC_BR_CrossCutterControl_0.IS.AutActStIdx <= 6) ) THEN
				SetupComplete	:= TRUE;
			END_IF;
			//set master speed to maximum velocity after start movement is complete
			IF (MC_BR_CrossCutterControl_0.InCompensation) THEN
				MC_BR_CrossCutterControl_0.AdvancedParameters.MasterMaxVelocity	:= SetupPar.Velocity; (*data.general.maxVelocity;;*)
			END_IF;
			IF (NOT EnableMove) THEN
				MC_BR_CrossCutterControl_0.Enable	:= FALSE;
				MC_BR_CrossCutterControl_0.EnableCut	:= FALSE;
			State	:= STATE_IDLE;
			END_IF;
	//************************************************************************
		
	//**********************	Command aborted, wait until "EnableMove" is reset	**********************
		STATE_W4_RESET:
			IF  EnableMove THEN
				State	:= STATE_IDLE;	
			END_IF;
	//************************************************************************
		
	//**********************	FUB Error	**********************
		STATE_ERROR:
			(*MC_BR_CrossCutterControl_0.AdvancedParameters.MasterStartDistance	:= 0;*)
			MC_BR_CrossCutterControl_0.Enable := FALSE;
			State := STATE_CHECK_STANDBY;
	//************************************************************
			
		ELSE	
			
	END_CASE;
	//**********************	END OF STATE MACHINE	************************
	
	(*********************		Read automat position	********************)
	MC_BR_ReadAutPosition_0.Axis		:= SlaveREF;
	MC_BR_ReadAutPosition_0();
	//******************************************************************************
	//********************		Move absolute			********************
	MC_MoveAbsolute_0.Axis			:= SlaveREF;
	MC_MoveAbsolute_0.Velocity		:= 40000;
	MC_MoveAbsolute_0.Acceleration	:= 60000;
	MC_MoveAbsolute_0.Deceleration	:= 60000;
	MC_MoveAbsolute_0();
	//*********************************************************************

	//**************************************************************************//
	//limit correction value
	LCRLimit_Correction.max_value	:= REAL_TO_DINT (data.recipe.MaxCorr);  (*AutPar.MaxCorrection;*)
	LCRLimit_Correction.min_value	:= - REAL_TO_DINT (data.recipe.MaxCorr); (* AutPar.MaxCorrection;*)

	//calculate cut position within tool segment period
	IF (MC_ReadParameter_AxisPeriod.Value <> 0.0) THEN
		MC_BR_CrossCutterControl_0.CutRangeSlave		:= DINT_TO_REAL( (crosscuttpar.CutEndPos - crosscuttpar.CutStartPos) MOD REAL_TO_DINT(MC_ReadParameter_AxisPeriod.Value) );
		IF (MC_BR_CrossCutterControl_0.CutRangeSlave < 0.0) THEN
			MC_BR_CrossCutterControl_0.CutRangeSlave	:= MC_BR_CrossCutterControl_0.CutRangeSlave + MC_ReadParameter_AxisPeriod.Value;
		END_IF
		IF 	crosscuttpar.CutStartPos > crosscuttpar.CutEndPos THEN 
			MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition	:= DINT_TO_REAL((crosscuttpar.CutEndPos + crosscuttpar.CutStartPos + REAL_TO_DINT(MC_ReadParameter_AxisPeriod.Value)) / 2 MOD REAL_TO_DINT(MC_ReadParameter_AxisPeriod.Value));
		ELSE
			MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition	:= DINT_TO_REAL((crosscuttpar.CutEndPos + crosscuttpar.CutStartPos) /2 MOD REAL_TO_DINT(MC_ReadParameter_AxisPeriod.Value));
		END_IF
			IF (MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition < 0.0) THEN
			MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition	:= MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition + MC_ReadParameter_AxisPeriod.Value;
			END_IF;
		//limit cut range of slave to avoid ACOPOS errors on wrong user input
		IF ((crosscuttpar.MinCutRangeSlave > 0.0) AND (crosscuttpar.MinCutRangeSlave < MC_ReadParameter_AxisPeriod.Value)) THEN
			MC_BR_CrossCutterControl_0.CutRangeSlave	:= MAX(MC_BR_CrossCutterControl_0.CutRangeSlave, crosscuttpar.MinCutRangeSlave);
		END_IF;
		IF ((crosscuttpar.MinCompRangeSlave > 0.0) AND (crosscuttpar.MinCompRangeSlave < MC_ReadParameter_AxisPeriod.Value) ) THEN
			MC_BR_CrossCutterControl_0.CutRangeSlave := MIN(MC_BR_CrossCutterControl_0.CutRangeSlave, (MC_ReadParameter_AxisPeriod.Value - crosscuttpar.MinCompRangeSlave));
		END_IF;
		
		//scale cut range of master
		LCRLimScal_CutRangeMaster.x1	:= 0.0;
		LCRLimScal_CutRangeMaster.y1	:= MC_BR_CrossCutterControl_0.CutRangeSlave;
		LCRLimScal_CutRangeMaster.x2	:= 100.0;
		LCRLimScal_CutRangeMaster.y2	:= (MC_BR_CrossCutterControl_0.CutRangeSlave * crosscuttpar.ProductLength) / MC_ReadParameter_AxisPeriod.Value; 	
		LCRLimScal_CutRangeMaster.x		:= crosscuttpar.Insetting;
		LCRLimScal_CutRangeMaster();
		MC_BR_CrossCutterControl_0.CutRangeMaster	:= LCRLimScal_CutRangeMaster.y;
	ELSE	
		MC_BR_CrossCutterControl_0.CutRangeSlave					:= 0.0;
		MC_BR_CrossCutterControl_0.CutRangeMaster					:= 0.0;
		MC_BR_CrossCutterControl_0.AdvancedParameters.CutPosition	:= 0.0;
	END_IF;
	//******************************************************************
	//choose source of reg mark correction
	GetNextCuttPos( scalePerimeter := scalePerimeter, markpoints := markpoints, machinemaster := machineMaster);
	
	IF (RegMarkPar.EnableRmCorrection) THEN
		IF (RegMarkPar.EnableVRegMark) THEN
			LCRLimit_Correction.in	:= GetNextCuttPos.setCutOffset.setOffset_o; 
			syncFtrig(CLK := MC_BR_CrossCutterControl_0.InCut); 
			IF syncFtrig.Q THEN 
				initdata := TRUE;
			END_IF
			(*Steckung bzw. Stauchung der Länge;*)
			IF MC_BR_CrossCutterControl_0.CutCount  <>  CutCount_1 AND initdata THEN
				CutCount_1 := MC_BR_CrossCutterControl_0.CutCount;
				MC_BR_CrossCutterControl_0.InitData	:= TRUE;
				initdata := FALSE;
			END_IF
		ELSE
			LCRLimit_Correction.in	:= GetNextCuttPos.PositionError;
//			syncFtrig(CLK := MC_BR_CrossCutterControl_0.InCut); 
//			IF syncFtrig.Q THEN 
//				initdata := TRUE;
//			END_IF

			syncRtrig(CLK := MC_BR_CrossCutterControl_0.InCut); 
			IF MC_BR_CrossCutterControl_0.CutCount <> CutCntOld THEN 
				initdata := TRUE;
				CutCntOld := MC_BR_CrossCutterControl_0.CutCount;
			END_IF
			IF  markpoints.ProbeCounter  <>  CutCount_1 AND markpoints.ProbeCounter < 1 AND initdata THEN
				CutCount_1 := markpoints.ProbeCounter;
				MC_BR_CrossCutterControl_0.InitData	:= TRUE;
				initdata := FALSE;
			ELSIF markpoints.ProbeCounter > 1 AND initdata THEN
				MC_BR_CrossCutterControl_0.InitData	:= TRUE;
				initdata := FALSE;
			END_IF	
//			R_TRIG_InCompensation(CLK := MC_BR_CrossCutterControl_0.InCompensation); 
//			IF R_TRIG_InCompensation.Q THEN 
//				initdata := TRUE;
//			END_IF
//			IF  GetNextCuttPos.newdata <>  CutCount_1 AND  NOT MC_BR_CrossCutterControl_0.InCut(*AND initdata*) THEN
//				CutCount_1 := GetNextCuttPos.newdata;
//				MC_BR_CrossCutterControl_0.InitData	:= TRUE;
//				initdata := FALSE;
//			END_IF
		END_IF;
	ELSE
		LCRLimit_Correction.in	:= 0.0;
	END_IF;
	LCRLimit_Correction();	(*markpoints.CorrectionValid *)
	MC_BR_CrossCutterControl_0.ProductLengthCorrection	:= LCRLimit_Correction.out;
	IF MC_BR_CrossCutterControl_0.InitData THEN
		(*MC_BR_CrossCutterControl_0.ProductLengthCorrection	:= LCRLimit_Correction.out;*)
		OffsetValue1 := REAL_TO_DINT (MC_BR_CrossCutterControl_0.ProductLengthCorrection);
	END_IF
	MC_BR_CrossCutterControl_0();
	markpoints();
	IF MC_BR_CrossCutterControl_0.DataInitialized THEN 
		MC_BR_CrossCutterControl_0.InitData	:= FALSE;
	END_IF 
	Active				:= MC_BR_CrossCutterControl_0.Active;
	CutMasterPosition	:= MC_BR_CrossCutterControl_0.CutMasterPosition;	
	RegMarkPar.Axis 	:= SlaveREF;
	//probe counter
	(*markpoints();*)
	ProbeCounter		:= markpoints.ProbeCounter;
	MissedTriggers		:= markpoints.MissedTriggers;
	ActPositionError	:= markpoints.CorrectionValue;
	IF (Enable AND RegMarkPar.EnableRmCorrection) THEN
		IF (RegMarkPar.EnableVRegMark) THEN
			ProbeCounter		:= ProbeCounter + BOOL_TO_UDINT(SPR_RmCalcPosError_Virtual.RecordedValueValid);
			MissedTriggers		:= 0;
			ActPositionError	:= PositionError;
		ELSE
		
		
		END_IF;
	ELSE
		ProbeCounter		:= 0;
		MissedTriggers		:= 0;
		ActPositionError	:= 0;
	END_IF;
END_FUNCTION_BLOCK