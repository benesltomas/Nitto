(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserSpilke
 * File: SPR_LabelerAut.st
 * Author: knausenbergl
 * Created: January 30, 2013
 ********************************************************************
 * Implementation of library UserSpilke
 ********************************************************************) 

(*<$Description$> Cam automat configuration for labeling unit </$Description$>*)
FUNCTION_BLOCK SPR_LabelerAut
	
	//********************	GLOBAL AUTOMAT CONFIGURATION ********************
	AutData.Master				:= Master;
	AutData.MaxMasterVelocity	:= MaxMasterVelocity;
	AutData.SlaveLatchParID		:= ACP10PAR_AUT_SL_S;
	AutData.StartState			:= 0;
	//***********************************************************************
	
	//********************	STATE 0: INIT ********************
	//state transition
	AutData.State[0].Event[0].Type		:= ncST_END;
	AutData.State[0].Event[0].Attribute	:= ncAT_ONCE;
	AutData.State[0].Event[0].NextState	:= 1;
	//********************************************************
	
	//********************	STATE 1: ALIGN MIDDLE OF CAM WITH REG MARK	********************
	//compensation
	AutData.State[1].CompMode	:= ncOFF;
	
	//cam profile
	AutData.State[1].CamProfileIndex	:= 16#FFFF;
//	AutData.State[1].MasterFactor		:= REAL_TO_UDINT(fmod( (LabelPeriod / 2.0 - DistanceToLabelSensor) , LabelPeriod) + 2.0 * LabelPeriod);
	AutData.State[1].MasterFactor		:= REAL_TO_UDINT(fmod( ABS(LabelPeriod / 2.0 - DistanceToLabelSensor) , LabelPeriod) + 2.0 * LabelPeriod);

	AutData.State[1].SlaveFactor		:= UDINT_TO_DINT(AutData.State[1].MasterFactor);
	
	//state transition
	AutData.State[1].Event[0].Type		:= ncST_END;
	AutData.State[1].Event[0].Attribute	:= ncAT_ONCE;
	AutData.State[1].Event[0].NextState	:= 2;
	//**************************************************************************************
	
	//********************	STATE 2: STANDARD CAM WITHOUT CORRECTION ********************
	//compensation
	AutData.State[2].CompMode			:= ncOFF;
	
	//cam profile
	AutData.State[2].CamProfileIndex	:= 16#FFFF;
	AutData.State[2].MasterFactor		:= REAL_TO_UDINT(LabelPeriod);
	AutData.State[2].SlaveFactor		:= REAL_TO_DINT(LabelPeriod);
	
	//state transition
	AutData.State[2].Event[0].Type		:= TriggerEvent;
	AutData.State[2].Event[0].Attribute	:= ncAT_ONCE;
	AutData.State[2].Event[0].NextState	:= 3;
	//************************************************************************
	
	//********************	STATE 3: LABEL POSITION CORRECTION	********************
	//compensation
	AutData.State[3].CompMode			:= ncSL_LATCHPOS;
	AutData.State[3].SlaveCompDistance	:= LabelPeriod;
	AutData.State[3].MasterCompDistance	:= LabelPeriod;
	
	//cam profile
	AutData.State[3].CamProfileIndex	:= 16#FFFE;
	AutData.State[3].MasterFactor		:= REAL_TO_UDINT(LabelPeriod);
	AutData.State[3].SlaveFactor		:= REAL_TO_DINT(LabelPeriod);
	
	//state transition
	AutData.State[3].Event[0].Type		:= TriggerEvent;
	AutData.State[3].Event[0].Attribute	:= ncAT_ONCE;
	AutData.State[3].Event[0].NextState	:= 3;
	
	AutData.State[3].Event[1].Type		:= ncST_END;
	AutData.State[3].Event[1].Attribute	:= ncAT_ONCE;
	AutData.State[3].Event[1].NextState	:= 4;
	//******************************************************************************
	
	//********************	STATE 4: POINT-TO-POINT CAM  WITHOUT CORRECTION	********************
	//compensation
	AutData.State[4].CompMode			:= ncWITH_CAM;
	AutData.State[4].SlaveCompDistance	:= LabelPeriod;
	AutData.State[4].MasterCompDistance	:= LabelPeriod;
	
	//cam profile
	AutData.State[4].CamProfileIndex	:= 16#FFFE;
	AutData.State[4].MasterFactor		:= REAL_TO_UDINT(LabelPeriod);
	AutData.State[4].SlaveFactor		:= REAL_TO_DINT(LabelPeriod);
	
	//state transition
	AutData.State[4].Event[0].Type		:= TriggerEvent;
	AutData.State[4].Event[0].Attribute	:= ncAT_ONCE;
	AutData.State[4].Event[0].NextState	:= 3;
	//*******************************************************************************************
	
	//ignore other states
	AutData.State[0].DisableStateInit	:= ncOFF;
	AutData.State[1].DisableStateInit	:= ncOFF;
	AutData.State[2].DisableStateInit	:= ncOFF;
	AutData.State[3].DisableStateInit	:= ncOFF;
	AutData.State[4].DisableStateInit	:= ncOFF;
	AutData.State[5].DisableStateInit	:= ncON;
	AutData.State[6].DisableStateInit	:= ncON;
	AutData.State[7].DisableStateInit	:= ncON;
	AutData.State[8].DisableStateInit	:= ncON;
	AutData.State[9].DisableStateInit	:= ncON;
	AutData.State[10].DisableStateInit	:= ncON;
	AutData.State[11].DisableStateInit	:= ncON;
	AutData.State[12].DisableStateInit	:= ncON;
	AutData.State[13].DisableStateInit	:= ncON;
	AutData.State[14].DisableStateInit	:= ncON;
	
	
	adrAutData	:= ADR(AutData);
	
END_FUNCTION_BLOCK