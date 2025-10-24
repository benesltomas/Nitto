(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: SprGeneral
 * File: SprGeneral.fun
 * Author: knausenbergl
 * Created: January 02, 2013
 ********************************************************************
 * Functions and function blocks of library SprGeneral
 ********************************************************************)

FUNCTION_BLOCK SPR_Mux (*Multiplexes pointers of any datatype*)
	VAR_INPUT
		Selector : USINT; (*Selects the channel*)
		pIn : ARRAY[0..15] OF UDINT; (*Addresses of input variables*)
	END_VAR
	VAR_OUTPUT
		Out_UDINT : UDINT; (*Output interpreted as UDINT*)
		Out_DINT : DINT; (*Output interpreted as DINT*)
		Out_REAL : REAL; (*Output interpreted as REAL*)
		Out_BOOL : BOOL;
		Out_USINT : USINT;
		Out_UINT : UINT;
		Out_INT : INT;
	END_VAR
	VAR
		C_Selector : USINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SPR_Fifo (*Implementation of a DINT Fifo*)
	VAR_INPUT
		Add : BOOL; (*add value to FIFO on positive edge*)
		Remove : BOOL; (*remove value from FIFO on positive edge*)
		InValue : DINT; (*input value for add command*)
		Reset : BOOL; (*reset FIFO on positive edge*)
	END_VAR
	VAR_OUTPUT
		Full : BOOL; (*FIFO is full*)
		ActElements : UINT; (*actual number of elements in FIFO*)
		OutValue : DINT; (*output value*)
	END_VAR
	VAR
		Add_1 : USINT; (*value in previous cycle*)
		Remove_1 : USINT; (*value in previous cycle*)
		Reset_1 : USINT; (*value in previous cycle*)
		RemoveIndex : USINT; (*remove index in value array*)
		AddIndex : USINT; (*add index in value array*)
		Value : ARRAY[0..255] OF DINT; (*value array*)
		MaxElements : UINT; (*maximum number of elements in FIFO*)
	END_VAR
END_FUNCTION_BLOCK
