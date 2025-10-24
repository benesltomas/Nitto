(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SwitchConf
 * File: SwitchConf.typ
 * Author: hagera
 * Created: March 01, 2010
 ********************************************************************
 * Data types of library SwitchConf
 ********************************************************************)

TYPE
	StepDescription_typ : 
		( (*STEP description typ*)
		WAIT := 0, (*wait for start command*)
		CHECK_INPUT_DATA, (*check input data for FB*)
		GET_OFFSET_POS_END_SWITCH, (*get offset for positive end switch*)
		GET_OFFSET_NEG_END_SWITCH, (*get offstet for negative end switch*)
		GET_OFFSET_REF_SWITCH, (*get offset for reference switch*)
		DEFINE_PARAMETER_LIST, (*define entries for parameter list*)
		WRITE_PARAMETER_LIST (*write parameter list to axis*)
		);
	SwitchConfiguration_typ : 	STRUCT  (*single switch configuration typ*)
		ioInformation : PLACTION_GET_CROSSLINK_INFO_typ; (*i/o information for switch*)
		Status : UINT; (*status of i/o information*)
		Offset : UINT; (*offset of i/o in data*)
		shiftBits : UINT; (*bits to shift*)
	END_STRUCT;
	SwitchesACPm_typ : 	STRUCT  (*switches for ACPm typ*)
		posEndSwitch : SwitchConfiguration_typ; (*positive end switch*)
		negEndSwitch : SwitchConfiguration_typ; (*negative end switch*)
		refSwitch : SwitchConfiguration_typ; (*reference switch*)
	END_STRUCT;
	ErrorNumbers_typ : 
		(
		OK := 0, (*no error*)
		INVALID_AXIS_REFERENCE := 50001, (*error number for invalid axis reference*)
		INVALID_DEVICE_NAME, (*error number for invalid device name*)
		INVALID_CHANNEL_NAME, (*error number for invalid channel name*)
		ERROR_GET_OFFSET_FOR_SWITCH, (*error number for getting offset for switch*)
		ERROR_WRITE_PARAMETER_LIST (*error number for writing parameter list*)
		);
	ParameterList_typ : 	STRUCT  (*parameter list typ*)
		List : ARRAY[0..30] OF ACP10PRB06_typ; (*parameter list*)
		listInfo : ACP10DATBL_typ; (*parameter list info*)
		configMaCyclicPos : ARRAY[0..1] OF UINT; (*MaCyclicPos*)
		ui2 : UINT; (*value data type UINT*)
		ui4 : UDINT; (*value data type UDINT*)
		Execute : BOOL; (*execute parameter list write*)
		Counter : USINT; (*parameter counter*)
	END_STRUCT;
END_TYPE
