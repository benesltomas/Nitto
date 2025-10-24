(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UserSpilke
 * File: SPR_MeterCounter.st
 * Author: knausenbergl
 * Created: December 06, 2012
 ********************************************************************
 * Implementation of library UserSpilke
 ********************************************************************) 

(*<$Description$> Counts length periods on an axis </$Description$>*)
FUNCTION_BLOCK SPR_MeterCounter
	MC_BR_DigitalCamSwitch_0.Switches.Master	:= Axis;
	MC_BR_DigitalCamSwitch_0.OutputOptions.Axis	:= Axis;
	MC_BR_DigitalCamSwitch_0.Switches.Period	:= Period;
	MC_BR_DigitalCamSwitch_0.Switches.Switches[0].FirstOnPosition[0]	:= Period / 2.0;
	MC_BR_DigitalCamSwitch_0.Switches.Switches[0].LastOnPosition[0]		:= Period;
	MC_BR_DigitalCamSwitch_0.EnableValue	:= TRUE;
	MC_BR_DigitalCamSwitch_0.Enable			:= Enable;
	MC_BR_DigitalCamSwitch_0();
	
	F_TRIG_Value.CLK	:= MC_BR_DigitalCamSwitch_0.Value;
	F_TRIG_Value();
	
	Error		:= MC_BR_DigitalCamSwitch_0.Error;
	ErrorID		:= MC_BR_DigitalCamSwitch_0.ErrorID;
	Busy		:= MC_BR_DigitalCamSwitch_0.Busy;
	InOperation	:= MC_BR_DigitalCamSwitch_0.InOperation;
	IF (F_TRIG_Value.Q AND MC_BR_DigitalCamSwitch_0.Busy) THEN
		PeriodCount	:= PeriodCount + 1;
	END_IF;	
END_FUNCTION_BLOCK