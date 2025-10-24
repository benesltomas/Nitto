(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserSpilke
 * File: SPR_LabelerAutVax.st
 * Author: knausenbergl
 * Created: February 02, 2013
 ********************************************************************
 * Implementation of library UserSpilke
 ********************************************************************) 

(*<$Description$> Cam automat configuration for an "ideal" labeler (no label position correction) </$Description$>*)
FUNCTION_BLOCK SPR_LabelerAutVax
	
	//the sum of acceleration distance, cam length and deceleration distance equals 1 label period
	IF ( (AccelerationBias >= 0.1) AND (AccelerationBias <= 10.0) ) THEN
		AccelerationDistance	:= (LabelPeriod - CamLength) * AccelerationBias / (AccelerationBias + 1.0);
	ELSE
		AccelerationDistance	:= (LabelPeriod - CamLength) / 2.0;	//default value
	END_IF;	
	DecelerationDistance	:= LabelPeriod - CamLength - AccelerationDistance;
	
	//********************	GLOBAL AUTOMAT CONFIGURATION ********************
	AutData.Master				:= Master;
	AutData.MaxMasterVelocity	:= MaxMasterVelocity;
	AutData.StartState			:= 0;
	//***********************************************************************
	
	//********************	STATE 0: INIT ********************
	//state transition
	AutData.State[0].Event[0].Type		:= ncST_END;
	AutData.State[0].Event[0].Attribute	:= ncAT_ONCE;
	AutData.State[0].Event[0].NextState	:= 1;
	//********************************************************
	
	//********************	STATE 1: STANDSTILL, WAIT FOR TRIGGER EVENT	********************
	//compensation
	AutData.State[1].CompMode	:= ncOFF;
	
	//cam profile
	AutData.State[1].CamProfileIndex	:= 16#FFFF;
	AutData.State[1].MasterFactor		:= REAL_TO_UDINT(ProductLengthMaster);
	AutData.State[1].SlaveFactor		:= REAL_TO_DINT(LabelPeriod);
	
	//state transition
	AutData.State[1].Event[0].Type		:= ncSIGNAL1;
	AutData.State[1].Event[0].Attribute	:= ncAT_ONCE;
	AutData.State[1].Event[0].NextState	:= 2;
	
	AutData.State[1].Event[1].Type		:= TriggerEvent;	//reg mark found
	AutData.State[1].Event[1].Attribute	:= ncAT_ONCE;
	AutData.State[1].Event[1].NextState	:= 2;
	//**************************************************************************************
	
	//********************	STATE 2: DISPENSE FIRST LABEL ********************
	//compensation
//	AutData.State[2].CompMode			:= ncMA_LATCHPOS;
//	AutData.State[2].SlaveCompDistance	:= AccelerationDistance + 0.5 * CamLength;
//	AutData.State[2].MasterCompDistance	:= fmod( (DistanceToRmSensor - RegMarkPosition), ProductLengthMaster) + ProductLengthMaster;	//distance from sensor to middle of label
	
	// okrebs 12.09.13
	AutData.State[2].CompMode			:= ncMA_LATCHPOS;
	AutData.State[2].SlaveCompDistance	:= AccelerationDistance + 0.5 * LabelPeriod;
	AutData.State[2].MasterCompDistance	:= fmod( (DistanceToRmSensor - RegMarkPosition), ProductLengthMaster) + ProductLengthMaster;	//distance from sensor to middle of label
	
	//	//cam profile
    AutData.State[2].CamProfileIndex	:= 16#FFFF;
//	AutData.State[2].MasterFactor		:= REAL_TO_UDINT(CamLength);
//	AutData.State[2].SlaveFactor		:= REAL_TO_DINT(CamLength);
	
	IF (ProductLengthMaster > 0.0) THEN
		AutData.State[2].SlaveFactor		:= REAL_TO_DINT(LabelPeriod * LabelPeriod / ProductLengthMaster);
		AutData.State[2].MasterFactor		:= REAL_TO_UDINT(LabelPeriod);
	ELSE
		// Invalid parameters, use fix values
		AutData.State[2].MasterFactor		:= REAL_TO_UDINT(CamLength);
		AutData.State[2].SlaveFactor		:= REAL_TO_DINT(CamLength);
	END_IF
	
	//state transition
	AutData.State[2].Event[0].Type		:= ncST_END;
	AutData.State[2].Event[0].Attribute	:= ncAT_ONCE;
	AutData.State[2].Event[0].NextState	:= 3;
	
	AutData.State[2].Event[1].Type		:= ncSIGNAL2;	//stop labelling
	AutData.State[2].Event[1].Attribute	:= ncST_END;
	AutData.State[2].Event[1].NextState	:= 5;
	//************************************************************************
	
	//********************	STATE 3: CYCLIC LABELING WITHOUT CORRECTION	********************
	//compensation
	// AutData.State[3].CompMode			:= ncWITH_CAM;
	
	// okrebs 12.09.13
	 AutData.State[3].CompMode			:= ncOFF;
	
	AutData.State[3].SlaveCompDistance	:= LabelPeriod;			//label period on slave
	AutData.State[3].MasterCompDistance	:= ProductLengthMaster;	//distance label to label on master
	
//	//cam profile
//	AutData.State[3].CamProfileIndex	:= 16#FFFF;
//	AutData.State[3].MasterFactor		:= REAL_TO_UDINT(CamLength);
//	AutData.State[3].SlaveFactor		:= REAL_TO_DINT(CamLength);
	

	// okrebs / schoenefeldr 13.09.13
	AutData.State[3].CamProfileIndex	:= 16#FFFF;
	// Original:          SlaveFactor         Label period
	//            Gear = -------------- = -----------------------    
	//                    MasterFactor      ProductLengthMaster
	// Use label period for the master cam length as it will be significantly 
	// shorter than ProductLengthMaster -> so there is enough master distance 
	// left for compensation:
	//           Label period                  Label period * (Label period / ProductLengthMaster)
	//   Gear = -----------------------  =   -------------------------
	//           ProductLengthMaster           Label period
	IF (ProductLengthMaster > 0.0) THEN
		AutData.State[3].SlaveFactor		:= REAL_TO_DINT(LabelPeriod * LabelPeriod / ProductLengthMaster);
		AutData.State[3].MasterFactor		:= REAL_TO_UDINT(LabelPeriod);
	ELSE
		// Invalid parameters, use fix values
		AutData.State[3].MasterFactor		:= REAL_TO_UDINT(CamLength);
		AutData.State[3].SlaveFactor		:= REAL_TO_DINT(CamLength);
	END_IF
	
	//state transition
	AutData.State[3].Event[0].Type		:= TriggerEvent;
	AutData.State[3].Event[0].Attribute	:= ncST_END;
	AutData.State[3].Event[0].NextState	:= 4;
	
	AutData.State[3].Event[1].Type		:= ncSIGNAL2;	//stop labelling
	AutData.State[3].Event[1].Attribute	:= ncST_END;
	AutData.State[3].Event[1].NextState	:= 5;
	
	//***************************************************************************************
	
	//********************	STATE 4: CYCLIC LABELING WITH CORRECTION	********************
	//compensation
	AutData.State[4].CompMode			:= ncMA_LATCHPOS;
	AutData.State[4].SlaveCompDistance	:= LabelPeriod;								//label period on slave
	AutData.State[4].MasterCompDistance	:= fmod( (DistanceToRmSensor - RegMarkPosition), ProductLengthMaster) + ProductLengthMaster;	//distance from sensor to middle of label
	
//	//cam profile
//	AutData.State[4].CamProfileIndex	:= 16#FFFF;
//	AutData.State[4].MasterFactor		:= REAL_TO_UDINT(CamLength);
//	AutData.State[4].SlaveFactor		:= REAL_TO_DINT(CamLength);
	
	// okrebs 12.09.13
	AutData.State[4].CamProfileIndex	:= 16#FFFF;
	AutData.State[4].MasterFactor		:= REAL_TO_UDINT(ProductLengthMaster);
	AutData.State[4].SlaveFactor		:= REAL_TO_DINT(LabelPeriod);
	
	IF (ProductLengthMaster > 0.0) THEN
		AutData.State[4].SlaveFactor		:= REAL_TO_DINT(LabelPeriod * LabelPeriod / ProductLengthMaster);
		AutData.State[4].MasterFactor		:= REAL_TO_UDINT(LabelPeriod);
	ELSE
		// Invalid parameters, use fix values
		AutData.State[4].MasterFactor		:= REAL_TO_UDINT(CamLength);
		AutData.State[4].SlaveFactor		:= REAL_TO_DINT(CamLength);
	END_IF
	
	//state transition
	AutData.State[4].Event[0].Type		:= TriggerEvent;
	AutData.State[4].Event[0].Attribute	:= ncST_END;
	AutData.State[4].Event[0].NextState	:= 4;
	
	AutData.State[4].Event[1].Type		:= ncSIGNAL2;	//stop labelling
	AutData.State[4].Event[1].Attribute	:= ncST_END;
	AutData.State[4].Event[1].NextState	:= 5;
	
	AutData.State[4].Event[2].Type		:= ncST_END;
	AutData.State[4].Event[2].Attribute	:= ncAT_ONCE;
	AutData.State[4].Event[2].NextState	:= 3;

	//***************************************************************************************
	
	//********************	STATE 5: DECELERATE TO STANDSTILL	********************
	//compensation
	AutData.State[5].CompMode			:= ncV_COMP_S_SL;
	AutData.State[5].SlaveCompDistance	:= DecelerationDistance;								
	
	//cam profile
	AutData.State[5].CamProfileIndex	:= 16#FFFE;
	AutData.State[5].MasterFactor		:= REAL_TO_UDINT(CamLength);
	AutData.State[5].SlaveFactor		:= 0;
	
	//state transition	
	AutData.State[5].Event[0].Type		:= ncST_END;
	AutData.State[5].Event[0].Attribute	:= ncAT_ONCE;
	AutData.State[5].Event[0].NextState	:= 1;
	//***************************************************************************************
	
	//ignore other states
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