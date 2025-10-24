(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SwitchConf
 * File: SwitchConf.fun
 * Author: hagera
 * Created: March 01, 2010
 ********************************************************************
 * Functions and function blocks of library SwitchConf
 ********************************************************************)

FUNCTION_BLOCK SwitchConfiguration (*FUB to configure end-switches and ref-switch for AcoposMulti*)
	VAR_INPUT
		Axis : UDINT; (*axis reference*)
		Execute : BOOL; (*start initialization at rising edge*)
		posEndSwitchDeviceName : UDINT; (*device name of module where positive end switch is connected*)
		posEndSwitchChannelName : UDINT; (*channel name of i/o where positive end switch is connected*)
		negEndSwitchDeviceName : UDINT; (*device name of module where negative end switch is connected*)
		negEndSwitchChannelName : UDINT; (*channel name of i/o where negative end switch is connected*)
		refSwitchDeviceName : UDINT; (*device name of module where reference switch is connected*)
		refSwitchChannelName : UDINT; (*channel name of i/o where reference switch is connected*)
	END_VAR
	VAR_OUTPUT
		Done : BOOL; (*initialization complete*)
		Busy : BOOL; (*initialization active*)
		Error : BOOL; (*error occured in FB*)
		ErrorID : ErrorNumbers_typ; (*error number*)
		ErrorInitparalist :UINT;
	END_VAR
	VAR
		zzEdge00000 :BOOL;
		Step : StepDescription_typ; (*intern variable*)
		Switches : SwitchesACPm_typ; (*intern variable*)
		Parameter : ParameterList_typ; (*intern variable*)
		MC_BR_InitParList_Switch : MC_BR_InitParList; (*intern variable*)
	END_VAR
END_FUNCTION_BLOCK
