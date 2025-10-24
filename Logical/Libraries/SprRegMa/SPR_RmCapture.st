(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserRegMa
 * File: CalcPosError.st
 * Author: knausenbergl
 * Created: October 19, 2012
 ********************************************************************
 * Implementation of library UserRegMa
 ********************************************************************) 
(*<$Description$> Touchprobe with built-in FIFO for RegMark correction in cross-cutter applications </$Description$>*)
FUNCTION_BLOCK SPR_RmCapture		
	
	IS.R_TRIG_Enable.CLK	:= Enable;
	IS.R_TRIG_Enable();
	
	IS.R_TRIG_SearchRM.CLK	:= SearchRM;
	IS.R_TRIG_SearchRM();
	
	//Enable positive edge
	IF (IS.R_TRIG_Enable.Q) THEN
		IS.MC_BR_TouchProbe_0.Axis				:= Axis;
		IS.MC_BR_TouchProbe_0.Period			:= ProductLength;
		IS.MC_BR_TouchProbe_0.PeriodChange		:= 0.0;
		IS.MC_BR_TouchProbe_0.ExpectedValue		:= 0.0;
		IS.MC_BR_TouchProbe_0.Mode				:= mcSHIFT_FROM_RESULT + mcUSE_FIRST_TRIGGER_POS;
		IS.MC_BR_TouchProbe_0.TriggerInput		:= TriggerInput;
		IS.MC_BR_TouchProbe_0.WindowNegative	:= WindowNegative;
		IS.MC_BR_TouchProbe_0.WindowPositive	:= WindowPositive;
		IS.SPR_RmCalcPosError_0.DistanceToSensor	:= DistanceToSensor;
		IS.SPR_RmCalcPosError_0.ProductLength		:= REAL_TO_DINT(ProductLength);
		
	//SearchRM positive edge	
	ELSIF (Enable AND IS.R_TRIG_SearchRM.Q) THEN
		IS.MC_BR_TouchProbe_0.Axis				:= Axis;
		IS.MC_BR_TouchProbe_0.Period			:= ProductLength;
		IS.MC_BR_TouchProbe_0.PeriodChange		:= 0.0;
		IS.MC_BR_TouchProbe_0.ExpectedValue		:= 0.0;
		IS.MC_BR_TouchProbe_0.Mode				:= mcSHIFT_FROM_RESULT + mcUSE_FIRST_TRIGGER_POS;
		IS.MC_BR_TouchProbe_0.TriggerInput		:= TriggerInput;
		IS.MC_BR_TouchProbe_0.WindowNegative	:= WindowNegative;
		IS.MC_BR_TouchProbe_0.WindowPositive	:= WindowPositive;
		IS.SPR_RmCalcPosError_0.DistanceToSensor	:= DistanceToSensor;
		IS.SPR_RmCalcPosError_0.ProductLength		:= REAL_TO_DINT(ProductLength);
	END_IF;

	//disable TouchProbe on positive edge of "SearchRM" to re-initialize it
	IF (IS.R_TRIG_SearchRM.Q OR NOT Enable) THEN
		IS.MC_BR_TouchProbe_0.Enable	:= FALSE;
		IS.SPR_RmCalcPosError_0.Enable	:= FALSE;
	//wait until TouchProbe is inactive before restarting it
	ELSIF (Enable AND NOT IS.MC_BR_TouchProbe_0.Busy AND NOT IS.MC_BR_TouchProbe_0.Active) THEN
		IS.MC_BR_TouchProbe_0.Enable	:= TRUE;
		IS.SPR_RmCalcPosError_0.Enable	:= TRUE;
	END_IF;
	
	IS.MC_BR_TouchProbe_0();
	
	IS.SPR_RmCalcPosError_0.CutMasterPosition	:= CutMasterPosition;
	IS.SPR_RmCalcPosError_0.RecordedValue		:= IS.MC_BR_TouchProbe_0.RecordedValue;
	IS.SPR_RmCalcPosError_0.RecordedValueValid	:= IS.MC_BR_TouchProbe_0.Active AND (IS.MC_BR_TouchProbe_0.ProbeCounter <> IS.ProbeCounter_1);
	IS.SPR_RmCalcPosError_0.RegMarkPosition		:= RegMarkPosition;
	IS.SPR_RmCalcPosError_0.Enable				:= IS.MC_BR_TouchProbe_0.Busy;
	IS.SPR_RmCalcPosError_0();
	IS.ProbeCounter_1	:= IS.MC_BR_TouchProbe_0.ProbeCounter;
	
	//update FUB outputs
	RecordedValue		:= IS.MC_BR_TouchProbe_0.RecordedValue;
	ProbeCounter		:= IS.MC_BR_TouchProbe_0.ProbeCounter;
	MissedTriggers		:= IS.MC_BR_TouchProbe_0.MissedTriggers;
	CorrectionValue		:= IS.SPR_RmCalcPosError_0.PositionError;
	CorrectionValid		:= IS.SPR_RmCalcPosError_0.PositionErrorValid;
	Busy				:= Enable OR IS.MC_BR_TouchProbe_0.Busy;
	Active				:= IS.MC_BR_TouchProbe_0.Active;
	
	IF (IS.MC_BR_TouchProbe_0.Active) THEN
		ActProductLength	:= IS.MC_BR_TouchProbe_0.Period - IS.MC_BR_TouchProbe_0.DeltaExpectedValue;
	ELSE
		ActProductLength	:= 0.0;
	END_IF;
	
	IF (IS.MC_BR_TouchProbe_0.Enable) THEN
		Error	:= IS.MC_BR_TouchProbe_0.Error;
		ErrorID	:= IS.MC_BR_TouchProbe_0.ErrorID;
	ELSIF (NOT Enable) THEN
		Error	:= FALSE;
		ErrorID	:= FALSE;
	END_IF;
	
END_FUNCTION_BLOCK