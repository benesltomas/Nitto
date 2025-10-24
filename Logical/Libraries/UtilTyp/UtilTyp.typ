(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: UtilTyp
 * File: UtilTyp.typ
 * Author: schoenefeldr
 * Created: July 09, 2012
 ********************************************************************
 * Data types of library UtilTyp
 ********************************************************************)
(*Digital input and output data type*)

TYPE
	DiDo_Type : 	STRUCT 
		Config : DiDoCfg_Type; (*Analogue IO configuration*)
		Value : DiDoValue_Type;
	END_STRUCT;
	DiDoValue_Type : 	STRUCT 
		InVal : BOOL;
		ActOut : BOOL;
		IsBlinking : BOOL;
		State : BOOL;
	END_STRUCT;
	DiDoCfg_Type : 	STRUCT  (*Contains configuration data*)
		OptionPLC : UDINT; (*Options for PLC *)
	END_STRUCT;
END_TYPE

(*Analogue input and output data type*)

TYPE
	AiAo_Type : 	STRUCT  (*Universal analogue IO data type*)
		Config : AiAoCfg_Type; (*Analogue IO configuration*)
		Value : AiAoValue_Type; (*IO values*)
	END_STRUCT;
	AiAoCfg_Type : 	STRUCT  (*Contains configuration data*)
		OptionPLC : UDINT; (*Options for PLC *)
		OptionVisu : UDINT; (*Options for visu configuration*)
		RawMax : REAL; (*Maximum of raw value*)
		RawMin : REAL; (*Minimum of raw value*)
		ScaleGain : REAL; (*Gain for scaling*)
		ScaleOffset : REAL; (*Zero offset for scaling in application units*)
	END_STRUCT;
	AiAoValue_Type : 	STRUCT  (*Contains IO values*)
		RawInt : INT; (*Raw input or output value 16 Bit*)
		RawDInt : DINT; (*Raw input or output value 32 Bit*)
		Scaled : REAL; (*Scaled physical value*)
	END_STRUCT;
END_TYPE
